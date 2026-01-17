# PowerShell Console Theme Installer

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Install-PowerShellTheme {
    try {
        Write-Log "INFO" "Installing PowerShell theme..."
        
        # Create PowerShell profile directory if it doesn't exist
        $profileDir = Split-Path -Parent $PROFILE.CurrentUserAllHosts
        if (!(Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        
        # Create theme content
        $themeContent = @"
# MilkOutside PowerShell Theme Configuration

# Set console colors
`$Host.UI.RawUI.BackgroundColor = "Black"
`$Host.UI.RawUI.ForegroundColor = "White"

# Custom colors using MilkOutside palette
`$colors = @{
    Black = 0x000000
    DarkBlue = 0x000080
    DarkGreen = 0x008000
    DarkCyan = 0x008080
    DarkRed = 0xE45555
    DarkMagenta = 0x800080
    DarkYellow = 0xF8E063
    Gray = 0x808080
    DarkGray = 0x1A1A1A
    Blue = 0x63C3DD
    Green = 0x5DD48C
    Cyan = 0x7DCFFF
    Red = 0xFDA1A0
    Magenta = 0x9D7CD8
    Yellow = 0xFDDC40
    White = 0xE8E8E8
}

# Set console color table
for (`$i = 0; `$i -lt 16; `$i++) {
    `$colorName = [System.ConsoleColor]`$i.ToString()
    if (`$colors.ContainsKey(`$colorName)) {
        `$Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]`$i
        `$Host.UI.RawUI.BackgroundColor = [System.ConsoleColor]::Black
    }
}

# Custom prompt with MilkOutside colors
function prompt {
    `$currentPath = `$PWD.Path
    `$gitBranch = `$null
    
    # Check if we're in a git repository
    if (Get-Command git -ErrorAction SilentlyContinue) {
        `$gitBranch = git rev-parse --abbrev-ref HEAD 2`>`$null
        if (`$LASTEXITCODE -ne 0) { `$gitBranch = `$null }
    }
    
    # Build prompt
    `$prompt = ""
    
    # Current directory in light gray
    `$prompt += "`e[37m$currentPath"
    
    # Git branch if available
    if (`$gitBranch) {
        `$prompt += " `e[95m[`$gitBranch]`e[0m"
    }
    
    # Prompt symbol in MilkOutside red
    `$prompt += "`e[91m>`e[0m "
    
    return `$prompt
}

# Set window title
`$Host.UI.RawUI.WindowTitle = "PowerShell - MilkOutside Theme"

Write-Host "MilkOutside PowerShell theme loaded" -ForegroundColor Magenta
"@
        
        # Install theme to profile
        if (Test-Path $PROFILE.CurrentUserAllHosts) {
            $backupPath = Join-Path $script:BackupDir "powershell-profile-$(Get-Date -Format 'HHmmss').ps1"
            Copy-Item -Path $PROFILE.CurrentUserAllHosts -Destination $backupPath
            Write-Log "INFO" "Backed up existing PowerShell profile"
        }
        
        Set-Content -Path $PROFILE.CurrentUserAllHosts -Value $themeContent -Encoding UTF8
        Write-Log "INFO" "PowerShell theme installed successfully"
        Write-Log "INFO" "Restart PowerShell to apply the theme"
        
        return $true
    }
    catch {
        Write-Log "ERROR" "Failed to install PowerShell theme: $($_.Exception.Message)"
        return $false
    }
}

function Install-CMDTheme {
    try {
        Write-Log "INFO" "Installing Command Prompt theme..."
        
        # Registry path for CMD colors
        $cmdRegPath = "HKCU:\Console"
        
        # Backup current settings
        reg export "$cmdRegPath" "$script:BackupDir\cmd-settings-$(Get-Date -Format 'HHmmss').reg" /y | Out-Null
        
        # Set colors to MilkOutside theme (color table order)
        $colorTable = @(
            0x000000,  # Black
            0xE45555,  # DarkRed - MilkOutside red
            0x5DD48C,  # DarkGreen - MilkOutside green
            0xF8E063,  # DarkYellow - MilkOutside yellow
            0x63C3DD,  # DarkBlue - MilkOutside blue
            0x9D7CD8,  # DarkMagenta - MilkOutside purple
            0x7DCFFF,  # DarkCyan - MilkOutside cyan
            0xE8E8E8,  # Gray
            0x1A1A1A,  # DarkGray
            0xFDA1A0,  # Red - Light MilkOutside red
            0x92CF9C,  # Green - Light MilkOutside green
            0xFDDC40,  # Yellow - Light MilkOutside yellow
            0xA7E3FF,  # Blue - Light MilkOutside blue
            0xE79CFB,  # Magenta - Light MilkOutside purple
            0xDAFFFF,  # Cyan - Light MilkOutside cyan
            0xFFFFFF   # White
        )
        
        for ($i = 0; $i -lt $colorTable.Length; $i++) {
            Set-ItemProperty -Path $cmdRegPath -Name "ColorTable$i" -Value $colorTable[$i] -Type DWORD
        }
        
        # Set default colors
        Set-ItemProperty -Path $cmdRegPath -Name "ScreenColors" -Value 0x0F -Type DWORD  # White on Black
        Set-ItemProperty -Path $cmdRegPath -Name "PopupColors" -Value 0x0F -Type DWORD   # White on Black
        
        # Apply to all CMD windows
        Set-ItemProperty -Path "$cmdRegPath\Command Prompt" -Name "ScreenColors" -Value 0x0F -Type DWORD
        Set-ItemProperty -Path "$cmdRegPath\Command Prompt" -Name "PopupColors" -Value 0x0F -Type DWORD
        
        Write-Log "INFO" "Command Prompt theme installed successfully"
        Write-Log "INFO" "Open new Command Prompt window to see the theme"
        
        return $true
    }
    catch {
        Write-Log "ERROR" "Failed to install Command Prompt theme: $($_.Exception.Message)"
        return $false
    }
}

# Run installation based on script name
$scriptName = Split-Path -Leaf $MyInvocation.MyCommand.Definition -LeafBase

switch ($scriptName) {
    "powershell" {
        Install-PowerShellTheme
    }
    "cmd" {
        Install-CMDTheme
    }
    default {
        Install-PowerShellTheme
        Install-CMDTheme
    }
}