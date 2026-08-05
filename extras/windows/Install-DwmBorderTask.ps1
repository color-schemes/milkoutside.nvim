<#
.SYNOPSIS
    Installs a logon scheduled task that keeps Set-DwmBorders.ps1 running in
    -Watch mode, so window borders stay red across reboots and new windows.

.DESCRIPTION
    DWMWA_BORDER_COLOR lives on the HWND, not in any persistent store, so it is
    lost on logoff and never applied to windows created later. This registers a
    task that starts at logon and reapplies on an interval.

    The task runs in the interactive user session deliberately. Do NOT change it
    to "run whether user is logged on or not" - that executes in session 0, which
    has no DWM windows to style, and the task will appear to succeed while doing
    nothing.

    A VBScript shim launches PowerShell so there is no console flash at logon.
    powershell.exe -WindowStyle Hidden still shows a brief window; wscript.exe
    with a 0-visibility Run call does not.

.EXAMPLE
    .\Install-DwmBorderTask.ps1
    .\Install-DwmBorderTask.ps1 -Border '#800000' -Interval 5
    .\Install-DwmBorderTask.ps1 -Uninstall
#>

[CmdletBinding(DefaultParameterSetName = 'Install')]
param(
    [Parameter(ParameterSetName = 'Install')]
    [string] $SourceScript = "$PSScriptRoot\Set-DwmBorders.ps1",

    [Parameter(ParameterSetName = 'Install')]
    [string] $InstallDir = "$env:LOCALAPPDATA\DwmBorders",

    [Parameter(ParameterSetName = 'Install')]
    [ValidatePattern('^#?[0-9A-Fa-f]{6}$')]
    [string] $Border = '#CC0000',

    [Parameter(ParameterSetName = 'Install')]
    [ValidateRange(1, 60)]
    [int] $Interval = 3,

    [Parameter(ParameterSetName = 'Uninstall', Mandatory)]
    [switch] $Uninstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$TaskName = 'DwmBorderColour'

if ($Uninstall) {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Task '$TaskName' removed." -ForegroundColor Green
    }
    else {
        Write-Host "No task named '$TaskName' found." -ForegroundColor DarkGray
    }

    if (Test-Path $InstallDir) {
        Remove-Item $InstallDir -Recurse -Force
        Write-Host "Removed $InstallDir" -ForegroundColor Green
    }

    Write-Host "`nBorders revert on next sign in, or run Set-DwmBorders.ps1 -Reset now." -ForegroundColor DarkGray
    return
}

if (-not (Test-Path $SourceScript)) {
    throw "Cannot find Set-DwmBorders.ps1 at '$SourceScript'. Pass -SourceScript with its path."
}

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

$targetScript = Join-Path $InstallDir 'Set-DwmBorders.ps1'
Copy-Item $SourceScript $targetScript -Force

# Downloaded files carry a Zone.Identifier stream that blocks execution.
Unblock-File $targetScript -ErrorAction SilentlyContinue

$shim = Join-Path $InstallDir 'launch.vbs'

$psCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""$targetScript"" -Border ""$Border"" -Watch -Interval $Interval"

# VBScript escapes a quote by doubling it. Without this the inner quotes
# terminate the Run argument early and wscript throws 800A0401.
$psCommandVbs = $psCommand -replace '"', '""'

@"
CreateObject("WScript.Shell").Run "$psCommandVbs", 0, False
"@ | Set-Content -Path $shim -Encoding ASCII

$action    = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument "`"$shim`""
$trigger   = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -Hidden

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Register-ScheduledTask -TaskName $TaskName `
    -Action $action -Trigger $trigger -Principal $principal -Settings $settings `
    -Description 'Reapplies DWMWA_BORDER_COLOR so window borders survive logon and new windows.' | Out-Null

Write-Host "Installed." -ForegroundColor Green
Write-Host "  Script   $targetScript"
Write-Host "  Shim     $shim"
Write-Host "  Task     $TaskName (at logon, hidden)"
Write-Host "  Border   $Border every ${Interval}s"
Write-Host "`nStarting it now so you don't have to sign out:" -ForegroundColor DarkGray

Start-ScheduledTask -TaskName $TaskName
Write-Host "Running." -ForegroundColor Green
