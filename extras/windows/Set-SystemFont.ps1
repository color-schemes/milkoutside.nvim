<#
.SYNOPSIS
    Repairs blanked font registrations, then applies a custom Windows shell UI
    font via FontSubstitutes and WindowMetrics. Reverts cleanly on demand.

.DESCRIPTION
    Three independent concerns, in dependency order:

      1. REPAIR  HKLM\...\CurrentVersion\Fonts
         The "blank the value" trick for changing the system font deletes the
         mapping between a font's display name and its file on disk. Doing that
         to Segoe UI Emoji costs you all colour emoji; doing it to Segoe UI
         Symbol or Segoe UI Historic costs you large swaths of Unicode coverage
         and produces tofu boxes in unrelated apps. This step restores any
         registration that is currently blank but whose file still exists in
         C:\Windows\Fonts.

      2. SUBSTITUTE  HKLM\...\CurrentVersion\FontSubstitutes
         GDI-level alias, "Segoe UI" -> $FontName. Catches Win32 apps that ask
         for Segoe UI by name.

      3. METRICS  HKCU\Control Panel\Desktop\WindowMetrics
         Six REG_BINARY LOGFONTW structures defining the shell's own non-client
         fonts: icon labels, title bars, menus, dialogs, status bars.

    Steps 2 and 3 never delete font registrations, so the worst case after a
    Windows feature update is that the change reverts, not that fonts vanish.
    Rerun to reapply.

    None of this affects WinUI/XAML surfaces (Settings, Start, taskbar,
    notification centre). Those render through DirectWrite, which ignores
    FontSubstitutes entirely, and they request Segoe UI Variable rather than
    Segoe UI. There is no supported way to change them.

.PARAMETER FontName
    Font family name exactly as registered. Max 31 characters (LOGFONT limit).

.PARAMETER PointSize
    Base point size. Windows default is 9.

.PARAMETER Weight
    LOGFONT weight: 400 = normal, 700 = bold. Fonts with no bold cut get a
    synthesised bold from GDI, which usually looks worse than staying at 400.

.PARAMETER RepairOnly
    Run step 1 and stop. Use this first if emoji or symbols are already broken.

.PARAMETER SkipRepair
    Skip step 1. Only do this if you know the Fonts key is intact.

.PARAMETER Revert
    Restores WindowMetrics from backup and removes the Segoe UI substitute.
    Repairs are never undone: a blanked registration is a bug, not a preference.

.EXAMPLE
    .\Set-SystemFont.ps1 -RepairOnly
    .\Set-SystemFont.ps1
    .\Set-SystemFont.ps1 -FontName 'Cascadia Mono' -PointSize 10
    .\Set-SystemFont.ps1 -Revert
#>

#Requires -RunAsAdministrator
[CmdletBinding(DefaultParameterSetName = 'Apply')]
param(
    [Parameter(ParameterSetName = 'Apply')]
    [ValidateLength(1, 31)]
    [string] $FontName  = 'ShureTechMono Nerd Font Mono',

    [Parameter(ParameterSetName = 'Apply')]
    [ValidateRange(6, 48)]
    [int]    $PointSize = 9,

    [Parameter(ParameterSetName = 'Apply')]
    [ValidateSet(100, 200, 300, 400, 500, 600, 700, 800, 900)]
    [int]    $Weight    = 400,

    [Parameter(ParameterSetName = 'Apply')]
    [switch] $SkipRepair,

    [Parameter(ParameterSetName = 'RepairOnly', Mandatory)]
    [switch] $RepairOnly,

    [Parameter(ParameterSetName = 'Revert', Mandatory)]
    [switch] $Revert
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$FontsKey      = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
$FontsKeyReg   = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
$SubKey        = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes'
$SubKeyReg     = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes'
$MetricsKey    = 'HKCU:\Control Panel\Desktop\WindowMetrics'
$MetricsKeyReg = 'HKCU\Control Panel\Desktop\WindowMetrics'

$FontsDir      = Join-Path $env:WINDIR 'Fonts'
$BackupDir     = Join-Path $env:LOCALAPPDATA 'SystemFontTweak'
$MetricsBackup = Join-Path $BackupDir 'WindowMetrics.original.reg'
$SubBackup     = Join-Path $BackupDir 'FontSubstitutes.original.reg'
$FontsBackup   = Join-Path $BackupDir 'Fonts.prerepair.reg'


# ---------------------------------------------------------------------------
# Canonical registration name -> filename, for the families most commonly
# blanked by system-font tweaks. Every entry is verified against disk before
# it is written, so a wrong guess here produces a warning, not a broken value.
#
# The Segoe UI block is the one that matters. Emoji, Symbol and Historic are
# not stylistic choices: they are the fallback fonts the whole system leans on
# for anything outside basic Latin.
# ---------------------------------------------------------------------------
$KnownFonts = [ordered]@{
    # --- Segoe UI family and the critical fallback fonts --------------------
    'Segoe UI (TrueType)'                    = 'segoeui.ttf'
    'Segoe UI Black (TrueType)'              = 'seguibl.ttf'
    'Segoe UI Black Italic (TrueType)'       = 'seguibli.ttf'
    'Segoe UI Bold (TrueType)'               = 'segoeuib.ttf'
    'Segoe UI Bold Italic (TrueType)'        = 'segoeuiz.ttf'
    'Segoe UI Italic (TrueType)'             = 'segoeuii.ttf'
    'Segoe UI Light (TrueType)'              = 'segoeuil.ttf'
    'Segoe UI Light Italic (TrueType)'       = 'seguili.ttf'
    'Segoe UI Semibold (TrueType)'           = 'seguisb.ttf'
    'Segoe UI Semibold Italic (TrueType)'    = 'seguisbi.ttf'
    'Segoe UI Semilight (TrueType)'          = 'segoeuisl.ttf'
    'Segoe UI Semilight Italic (TrueType)'   = 'seguisli.ttf'
    'Segoe UI Emoji (TrueType)'              = 'seguiemj.ttf'   # colour emoji, system wide
    'Segoe UI Symbol (TrueType)'             = 'seguisym.ttf'   # symbol fallback
    'Segoe UI Historic (TrueType)'           = 'seguihis.ttf'   # historic scripts fallback
    'Segoe UI Variable (TrueType)'           = 'SegUIVar.ttf'   # the actual Win11 UI font

    # --- Core web/UI families ------------------------------------------------
    'Arial (TrueType)'                       = 'arial.ttf'
    'Arial Black (TrueType)'                 = 'ariblk.ttf'
    'Arial Bold (TrueType)'                  = 'arialbd.ttf'
    'Arial Bold Italic (TrueType)'           = 'arialbi.ttf'
    'Arial Italic (TrueType)'                = 'ariali.ttf'
    'Arial Narrow (TrueType)'                = 'ARIALN.TTF'
    'Arial Narrow Bold (TrueType)'           = 'ARIALNB.TTF'
    'Arial Narrow Bold Italic (TrueType)'    = 'ARIALNBI.TTF'
    'Arial Narrow Italic (TrueType)'         = 'ARIALNI.TTF'
    'Arial Rounded MT Bold (TrueType)'       = 'ARLRDBD.TTF'

    'Consolas (TrueType)'                    = 'consola.ttf'
    'Consolas Bold (TrueType)'               = 'consolab.ttf'
    'Consolas Bold Italic (TrueType)'        = 'consolaz.ttf'
    'Consolas Italic (TrueType)'             = 'consolai.ttf'

    'Courier New (TrueType)'                 = 'cour.ttf'
    'Courier New Bold (TrueType)'            = 'courbd.ttf'
    'Courier New Bold Italic (TrueType)'     = 'courbi.ttf'
    'Courier New Italic (TrueType)'          = 'couri.ttf'

    'Times New Roman (TrueType)'             = 'times.ttf'
    'Times New Roman Bold (TrueType)'        = 'timesbd.ttf'
    'Times New Roman Bold Italic (TrueType)' = 'timesbi.ttf'
    'Times New Roman Italic (TrueType)'      = 'timesi.ttf'

    'Trebuchet MS (TrueType)'                = 'trebuc.ttf'
    'Trebuchet MS Bold (TrueType)'           = 'trebucbd.ttf'
    'Trebuchet MS Bold Italic (TrueType)'    = 'trebucbi.ttf'
    'Trebuchet MS Italic (TrueType)'         = 'trebucit.ttf'

    'Verdana (TrueType)'                     = 'verdana.ttf'
    'Verdana Bold (TrueType)'                = 'verdanab.ttf'
    'Verdana Bold Italic (TrueType)'         = 'verdanaz.ttf'
    'Verdana Italic (TrueType)'              = 'verdanai.ttf'
}


# ---------------------------------------------------------------------------
# LOGFONTW packing
#
# typedef struct tagLOGFONTW {
#   LONG  lfHeight;          offset  0   4 bytes
#   LONG  lfWidth;                   4   4
#   LONG  lfEscapement;              8   4
#   LONG  lfOrientation;            12   4
#   LONG  lfWeight;                 16   4
#   BYTE  lfItalic;                 20   1
#   BYTE  lfUnderline;              21   1
#   BYTE  lfStrikeOut;              22   1
#   BYTE  lfCharSet;                23   1
#   BYTE  lfOutPrecision;           24   1
#   BYTE  lfClipPrecision;          25   1
#   BYTE  lfQuality;                26   1
#   BYTE  lfPitchAndFamily;         27   1
#   WCHAR lfFaceName[32];           28  64
# } LOGFONTW;                            = 92 bytes total
# ---------------------------------------------------------------------------
function New-LogFont {
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory)][string] $FaceName,
        [int]  $PointSize = 9,
        [int]  $Weight    = 400,
        [int]  $Dpi       = 96,
        [bool] $Italic    = $false
    )

    # 31 WCHARs plus a mandatory null terminator.
    if ($FaceName.Length -gt 31) {
        throw "Face name '$FaceName' is $($FaceName.Length) characters. LOGFONT allows 31."
    }

    $buffer = New-Object byte[] 92
    $stream = New-Object System.IO.MemoryStream(, $buffer)
    $writer = New-Object System.IO.BinaryWriter($stream)

    try {
        # Negative lfHeight requests a character height (ascender to descender)
        # rather than a full cell height including internal leading. Windows
        # stores negative; a positive value gives noticeably larger text.
        $height = -[int][Math]::Round(($PointSize * $Dpi) / 72.0)

        $writer.Write([int]  $height)                           # lfHeight
        $writer.Write([int]  0)                                 # lfWidth: 0 = keep aspect ratio
        $writer.Write([int]  0)                                 # lfEscapement
        $writer.Write([int]  0)                                 # lfOrientation
        $writer.Write([int]  $Weight)                           # lfWeight
        $writer.Write([byte] $(if ($Italic) { 1 } else { 0 }))  # lfItalic
        $writer.Write([byte] 0)                                 # lfUnderline
        $writer.Write([byte] 0)                                 # lfStrikeOut
        $writer.Write([byte] 0)                                 # lfCharSet:        ANSI_CHARSET
        $writer.Write([byte] 0)                                 # lfOutPrecision:   OUT_DEFAULT_PRECIS
        $writer.Write([byte] 0)                                 # lfClipPrecision:  CLIP_DEFAULT_PRECIS
        $writer.Write([byte] 5)                                 # lfQuality:        CLEARTYPE_QUALITY
        $writer.Write([byte] 0)                                 # lfPitchAndFamily: DEFAULT_PITCH | FF_DONTCARE

        # lfFaceName: UTF-16LE, null terminated, zero padded to exactly 64 bytes.
        # Written as raw bytes rather than via Write([string]), which would emit
        # a 7-bit encoded length prefix and corrupt the struct.
        $face = [System.Text.Encoding]::Unicode.GetBytes($FaceName)
        $writer.Write($face)
        $writer.Write((New-Object byte[] (64 - $face.Length)))
    }
    finally {
        $writer.Dispose()
        $stream.Dispose()
    }

    if ($buffer.Length -ne 92) { throw "Packed LOGFONT is $($buffer.Length) bytes, expected 92." }
    return $buffer
}


function Backup-Once {
    param([string] $Path, [string] $SourceKey, [string] $Label)

    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }

    # Only ever write a backup once. Overwriting after the tweak is applied
    # would capture the modified state and destroy the only route back, which
    # is the failure mode that makes these edits feel unrecoverable.
    if (Test-Path $Path) {
        Write-Host "  $Label backup already present, leaving it alone." -ForegroundColor DarkGray
        return
    }

    & reg.exe export $SourceKey $Path /y | Out-Null
    Write-Host "  $Label backed up." -ForegroundColor DarkGray
}


function Invoke-Repair {
    Write-Host "`n[1/3] Repairing blanked font registrations" -ForegroundColor Cyan
    Backup-Once -Path $FontsBackup -SourceKey $FontsKeyReg -Label 'Fonts key'

    $current  = Get-ItemProperty -Path $FontsKey
    $restored = 0
    $intact   = 0
    $missing  = @()

    foreach ($name in $KnownFonts.Keys) {
        $file = $KnownFonts[$name]

        # Only touch values that exist and are empty. A populated value is
        # either untouched or deliberately customised; either way, leave it.
        if ($current.PSObject.Properties.Name -notcontains $name) { continue }
        if (-not [string]::IsNullOrEmpty($current.$name))         { $intact++; continue }

        if (Test-Path (Join-Path $FontsDir $file)) {
            Set-ItemProperty -Path $FontsKey -Name $name -Value $file
            Write-Host ("  restored  {0,-42} -> {1}" -f $name, $file) -ForegroundColor Green
            $restored++
        }
        else {
            $missing += [pscustomobject]@{ Name = $name; File = $file }
        }
    }

    foreach ($m in $missing) {
        Write-Warning ("{0}: '{1}' not found in {2}. Verify the real filename there, or run 'sfc /scannow'." -f $m.Name, $m.File, $FontsDir)
    }

    Write-Host "  $restored restored, $intact already intact, $($missing.Count) unresolved." -ForegroundColor DarkGray

    if ($restored -gt 0) {
        Write-Host "  Emoji and symbol fallback returns after the next sign in." -ForegroundColor DarkGray
    }
}


function Get-AppliedDpi {
    # WindowMetrics LOGFONT heights are interpreted against AppliedDPI, not the
    # live DPI. Using the wrong baseline gives text at the wrong size, and it
    # silently breaks when display scaling changes.
    try {
        $dpi = (Get-ItemProperty -Path $MetricsKey -Name 'AppliedDPI' -ErrorAction Stop).AppliedDPI
        if ($dpi -is [int] -and $dpi -gt 0) { return $dpi }
    }
    catch { }
    return 96
}


function Invoke-Apply {
    Add-Type -AssemblyName System.Drawing

    $installed = [System.Drawing.FontFamily]::Families.Name
    if ($installed -notcontains $FontName) {
        throw "'$FontName' is not installed. Check the exact family name in Settings > Personalization > Fonts."
    }

    Write-Host "`n[2/3] Writing font substitute" -ForegroundColor Cyan
    Backup-Once -Path $SubBackup -SourceKey $SubKeyReg -Label 'FontSubstitutes'
    Set-ItemProperty -Path $SubKey -Name 'Segoe UI' -Value $FontName
    Write-Host "  Segoe UI -> $FontName" -ForegroundColor Green

    Write-Host "`n[3/3] Writing WindowMetrics LOGFONTs" -ForegroundColor Cyan
    Backup-Once -Path $MetricsBackup -SourceKey $MetricsKeyReg -Label 'WindowMetrics'

    $dpi = Get-AppliedDpi
    Write-Host "  AppliedDPI = $dpi" -ForegroundColor DarkGray

    # Per-element plan. Adjust sizes and weights here rather than in the loop.
    # SmCaptionFont at full size in a monospace face tends to clip on tool
    # windows, so it starts one point down.
    $plan = [ordered]@{
        IconFont      = @{ Size = $PointSize;     Weight = $Weight }  # desktop and Explorer icon labels
        CaptionFont   = @{ Size = $PointSize;     Weight = $Weight }  # window title bars
        SmCaptionFont = @{ Size = $PointSize - 1; Weight = $Weight }  # small title bars, tool windows
        MenuFont      = @{ Size = $PointSize;     Weight = $Weight }  # menu bars and context menus
        MessageFont   = @{ Size = $PointSize;     Weight = $Weight }  # dialog and message box body
        StatusFont    = @{ Size = $PointSize;     Weight = $Weight }  # status bars and tooltips
    }

    foreach ($name in $plan.Keys) {
        $spec  = $plan[$name]
        $bytes = New-LogFont -FaceName $FontName -PointSize $spec.Size -Weight $spec.Weight -Dpi $dpi
        Set-ItemProperty -Path $MetricsKey -Name $name -Value $bytes -Type Binary
        Write-Host ("  {0,-14} {1} {2}pt weight {3}" -f $name, $FontName, $spec.Size, $spec.Weight) -ForegroundColor Green
    }

    Write-Host "`nApplied. Sign out and back in to take effect." -ForegroundColor Green
    Write-Host "Explorer reads NONCLIENTMETRICS once at logon, so restarting explorer.exe is not enough." -ForegroundColor DarkGray
}


function Invoke-Revert {
    if (-not (Test-Path $MetricsBackup)) {
        throw "No backup found at $MetricsBackup. Nothing to restore from."
    }

    & reg.exe import $MetricsBackup | Out-Null
    Write-Host "WindowMetrics restored from backup." -ForegroundColor Green

    # Delete rather than reimport the substitutes backup: reimporting adds
    # values back but cannot remove ones added since, so it would look like a
    # full restore while silently leaving extra substitutions in place.
    if ($null -ne (Get-ItemProperty -Path $SubKey -Name 'Segoe UI' -ErrorAction SilentlyContinue)) {
        Remove-ItemProperty -Path $SubKey -Name 'Segoe UI'
        Write-Host "FontSubstitutes: 'Segoe UI' entry removed." -ForegroundColor Green
    }

    Write-Host "Font registrations left as repaired, by design." -ForegroundColor DarkGray
    Write-Host "`nReverted. Sign out and back in." -ForegroundColor Green
}


switch ($PSCmdlet.ParameterSetName) {
    'RepairOnly' { Invoke-Repair }
    'Revert'     { Invoke-Revert }
    'Apply'      {
        if (-not $SkipRepair) { Invoke-Repair }
        Invoke-Apply
    }
}
