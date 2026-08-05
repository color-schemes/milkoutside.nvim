<#
.SYNOPSIS
    Forces window border, caption and caption-text colours via DwmSetWindowAttribute,
    bypassing the accent colorization that contrast themes disable.

.DESCRIPTION
    Windows 11 (build 22000+) exposes three per-window DWM attributes:

        DWMWA_BORDER_COLOR   34   the 1px ring around the window
        DWMWA_CAPTION_COLOR  35   the title bar fill
        DWMWA_TEXT_COLOR     36   the title bar text

    These are set directly on an HWND and do not consult AccentColor,
    ColorPrevalence, or ColorizationColor. That is why they still work while a
    contrast theme is active, when the registry route is ignored.

    Colours here are COLORREF, which is 0x00BBGGRR - blue in the high byte,
    red in the low byte. Not the same order as ColorizationColor. The script
    takes #RRGGBB and packs it.

    LIMITATION: the attribute lives on the window, not in any persistent store.
    A window created after this runs gets the system default. Use -Watch to
    reapply on an interval, or rerun manually after opening apps.

.PARAMETER Border
    Window border colour as #RRGGBB.

.PARAMETER Caption
    Title bar fill. Defaults to black to match the theme.

.PARAMETER CaptionText
    Title bar text colour.

.PARAMETER Watch
    Reapply every -Interval seconds until Ctrl+C. Catches new windows.

.PARAMETER Interval
    Seconds between passes in -Watch mode.

.PARAMETER Reset
    Restore DWM defaults (DWMWA_COLOR_DEFAULT) on all windows.

.EXAMPLE
    .\Set-DwmBorders.ps1
    .\Set-DwmBorders.ps1 -Border '#FF0000' -Watch
    .\Set-DwmBorders.ps1 -Reset
#>

[CmdletBinding(DefaultParameterSetName = 'Apply')]
param(
    [Parameter(ParameterSetName = 'Apply')]
    [ValidatePattern('^#?[0-9A-Fa-f]{6}$')]
    [string] $Border = '#CC0000',

    [Parameter(ParameterSetName = 'Apply')]
    [ValidatePattern('^#?[0-9A-Fa-f]{6}$')]
    [string] $Caption = '#000000',

    [Parameter(ParameterSetName = 'Apply')]
    [ValidatePattern('^#?[0-9A-Fa-f]{6}$')]
    [string] $CaptionText = '#FFFFFF',

    [Parameter(ParameterSetName = 'Apply')]
    [switch] $Watch,

    [Parameter(ParameterSetName = 'Apply')]
    [ValidateRange(1, 60)]
    [int] $Interval = 3,

    [Parameter(ParameterSetName = 'Reset', Mandatory)]
    [switch] $Reset
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not ([System.Management.Automation.PSTypeName]'Dwm').Type) {
Add-Type @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

public static class Dwm {
    public const int BORDER_COLOR  = 34;
    public const int CAPTION_COLOR = 35;
    public const int TEXT_COLOR    = 36;

    // DWMWA_COLOR_DEFAULT - hands the attribute back to the system
    public const uint COLOR_DEFAULT = 0xFFFFFFFF;

    [DllImport("dwmapi.dll", PreserveSig = true)]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref uint value, int size);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool EnumWindows(EnumWindowsProc cb, IntPtr lParam);
    private delegate bool EnumWindowsProc(IntPtr hwnd, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern bool IsWindowVisible(IntPtr hwnd);

    [DllImport("user32.dll")]
    private static extern int GetWindowTextLength(IntPtr hwnd);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int GetWindowText(IntPtr hwnd, StringBuilder s, int max);

    public static List<IntPtr> TopLevelWindows() {
        var found = new List<IntPtr>();
        EnumWindows((h, l) => {
            // Skip hidden windows and untitled shell helpers; they have no
            // visible frame and setting attributes on them is wasted work.
            if (IsWindowVisible(h) && GetWindowTextLength(h) > 0) found.Add(h);
            return true;
        }, IntPtr.Zero);
        return found;
    }

    public static string TitleOf(IntPtr hwnd) {
        int len = GetWindowTextLength(hwnd);
        if (len == 0) return "";
        var sb = new StringBuilder(len + 1);
        GetWindowText(hwnd, sb, sb.Capacity);
        return sb.ToString();
    }
}
"@
}


# COLORREF is 0x00BBGGRR. Red ends up in the LOW byte, unlike ColorizationColor.
function ConvertTo-ColorRef {
    param([Parameter(Mandatory)][string] $Hex)
    $h = $Hex.TrimStart('#')
    $r = [Convert]::ToUInt32($h.Substring(0, 2), 16)
    $g = [Convert]::ToUInt32($h.Substring(2, 2), 16)
    $b = [Convert]::ToUInt32($h.Substring(4, 2), 16)
    return [uint32](($b -shl 16) -bor ($g -shl 8) -bor $r)
}


function Set-Attributes {
    param([uint32] $BorderRef, [uint32] $CaptionRef, [uint32] $TextRef)

    $applied = 0
    $failed  = 0

    foreach ($hwnd in [Dwm]::TopLevelWindows()) {
        $b = $BorderRef; $c = $CaptionRef; $t = $TextRef

        $h1 = [Dwm]::DwmSetWindowAttribute($hwnd, [Dwm]::BORDER_COLOR,  [ref]$b, 4)
        $h2 = [Dwm]::DwmSetWindowAttribute($hwnd, [Dwm]::CAPTION_COLOR, [ref]$c, 4)
        $h3 = [Dwm]::DwmSetWindowAttribute($hwnd, [Dwm]::TEXT_COLOR,    [ref]$t, 4)

        # S_OK is 0. Non-zero usually means the window belongs to a process
        # this session cannot touch, or it is not a real framed window.
        if ($h1 -eq 0) { $applied++ } else { $failed++ }
    }

    return [pscustomobject]@{ Applied = $applied; Failed = $failed }
}


if ($Reset) {
    $d = [Dwm]::COLOR_DEFAULT
    $r = Set-Attributes -BorderRef $d -CaptionRef $d -TextRef $d
    Write-Host "Reset to DWM defaults on $($r.Applied) windows ($($r.Failed) skipped)." -ForegroundColor Green
    return
}

$borderRef  = ConvertTo-ColorRef $Border
$captionRef = ConvertTo-ColorRef $Caption
$textRef    = ConvertTo-ColorRef $CaptionText

Write-Host ("Border      {0} -> COLORREF 0x{1:X8}" -f $Border,      $borderRef)
Write-Host ("Caption     {0} -> COLORREF 0x{1:X8}" -f $Caption,     $captionRef)
Write-Host ("CaptionText {0} -> COLORREF 0x{1:X8}" -f $CaptionText, $textRef)
Write-Host ""

if ($Watch) {
    Write-Host "Watching every ${Interval}s. Ctrl+C to stop." -ForegroundColor Cyan
    while ($true) {
        $r = Set-Attributes -BorderRef $borderRef -CaptionRef $captionRef -TextRef $textRef
        Write-Host ("`r{0:HH:mm:ss}  {1} windows styled, {2} skipped   " -f (Get-Date), $r.Applied, $r.Failed) -NoNewline
        Start-Sleep -Seconds $Interval
    }
}
else {
    $r = Set-Attributes -BorderRef $borderRef -CaptionRef $captionRef -TextRef $textRef
    Write-Host "$($r.Applied) windows styled, $($r.Failed) skipped." -ForegroundColor Green
    Write-Host "New windows get system defaults. Rerun, or use -Watch." -ForegroundColor DarkGray
}
