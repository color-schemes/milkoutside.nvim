# MilkOutside Extras Installer - PowerShell Version
# Automatically installs and configures MilkOutside themes across all Windows applications

param(
    [string[]]$Apps,
    [switch]$All,
    [switch]$List,
    [string]$Category,
    [switch]$Interactive,
    [switch]$Force,
    [switch]$Rollback,
    [switch]$Deps,
    [switch]$Debug,
    [switch]$KeepBackup,
    [switch]$Help
)

# Set strict mode for better error handling
Set-StrictMode -Version Latest

# Import required modules
Add-Type -AssemblyName System.Windows.Forms

# Global variables
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RepoRoot = Split-Path -Parent $ScriptDir
$BackupDir = "$env:USERPROFILE\.config\milkoutside-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$LogFile = "$env:TEMP\milkoutside-install.log"

# Colors for console output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Magenta = "Magenta"
    Cyan = "Cyan"
    White = "White"
}

# Logging function
function Write-Log {
    param(
        [string]$Level,
        [string]$Message
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logEntry
    
    $color = switch ($Level) {
        "INFO" { $Colors.Green }
        "WARN" { $Colors.Yellow }
        "ERROR" { $Colors.Red }
        "DEBUG" { if ($Debug) { $Colors.Blue } else { $Colors.White } }
        default { $Colors.White }
    }
    
    Write-Host "[$Level] $Message" -ForegroundColor $color
}

# Progress indicator
function Show-Progress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Description
    )
    
    $percent = [math]::Round(($Current / $Total) * 100)
    $filled = [math]::Floor($percent / 2)
    $empty = 50 - $filled
    
    $progressBar = "[" + ("=" * $filled) + ("-" * $empty) + "]"
    Write-Host -NoNewline "`r$percent% $progressBar $Description"
    
    if ($Current -eq $Total) {
        Write-Host ""
    }
}

# Application descriptions
function Get-AppDescription {
    param([string]$AppName)
    
    $descriptions = @{
        "alacritty" = "Alacritty terminal emulator"
        "aerc" = "Aerc email client"
        "aider" = "Aider AI assistant"
        "btop" = "Btop system monitor"
        "delta" = "Git delta pager"
        "discord" = "Discord client"
        "dunst" = "Dunst notification daemon"
        "eza" = "Eza file lister"
        "fish" = "Fish shell"
        "foot" = "Foot terminal emulator"
        "fuzzel" = "Fuzzel launcher"
        "fzf" = "Fuzzy finder"
        "ghostty" = "Ghostty terminal"
        "gitui" = "Git UI"
        "helix" = "Helix editor"
        "ish" = "iSH shell"
        "iterm" = "iTerm2 terminal"
        "kitty" = "Kitty terminal emulator"
        "konsole" = "Konsole terminal"
        "lazygit" = "LazyGit UI"
        "obsidian" = "Obsidian note-taking app"
        "opencode" = "OpenCode AI assistant"
        "process_compose" = "Process Compose"
        "prism" = "Prism syntax highlighter"
        "qterminal" = "QTerminal"
        "slack" = "Slack client"
        "spotify_player" = "Spotify player"
        "st" = "Suckless Simple Terminal"
        "sublime" = "Sublime Text"
        "tailwindv4" = "Tailwind CSS"
        "termux" = "Termux terminal"
        "terminator" = "Terminator terminal"
        "tilix" = "Tilix terminal"
        "tmux" = "Tmux terminal multiplexer"
        "vim" = "Vim editor"
        "vimium" = "Vimium browser extension"
        "vivaldi" = "Vivaldi browser"
        "wezterm" = "WezTerm terminal emulator"
        "windows_terminal" = "Windows Terminal"
        "xfceterm" = "XFCE Terminal"
        "xresources" = "Xresources"
        "yazi" = "Yazi file manager"
        "zathura" = "Zathura PDF viewer"
        "zellij" = "Zellij terminal multiplexer"
        "firefox" = "Mozilla Firefox"
        "chrome" = "Google Chrome"
        "safari" = "Apple Safari"
        "opera" = "Opera browser"
        "windows" = "Windows system interface"
        "powershell" = "PowerShell console"
        "cmd" = "Command Prompt"
    }
    
    return $descriptions[$AppName] ?? "Unknown application"
}

# Available applications list
$AllApps = @(
    "alacritty", "aerc", "aider", "btop", "delta", "discord", "dunst", "eza", "fish",
    "foot", "fuzzel", "fzf", "ghostty", "gitui", "helix", "ish", "iterm", "kitty",
    "konsole", "lazygit", "obsidian", "opencode", "process_compose", "prism",
    "qterminal", "slack", "spotify_player", "st", "sublime", "tailwindv4", "termux",
    "terminator", "tilix", "tmux", "vim", "vimium", "vivaldi", "wezterm",
    "windows_terminal", "xfceterm", "xresources", "yazi", "zathura", "zellij",
    "firefox", "chrome", "safari", "opera", "windows", "powershell", "cmd"
)

# Windows-specific applications
$WindowsApps = @(
    "windows_terminal", "powershell", "cmd", "discord", "firefox", "chrome", "opera",
    "vim", "helix", "sublime", "wezterm", "alacritty", "windows"
)

# Create backup directory
function Initialize-Backup {
    if (!(Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    Write-Log "INFO" "Created backup directory: $BackupDir"
}

# Function to create backup and install file
function Install-File {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description = "Installing file"
    )
    
    Write-Log "INFO" "$Description`: $Destination"
    
    try {
        $destDir = Split-Path -Parent $Destination
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        # Backup existing file if it exists
        if (Test-Path $Destination) {
            $backupPath = Join-Path $BackupDir "$(Split-Path $Destination -Leaf)-$(Get-Date -Format 'HHmmss')"
            Copy-Item -Path $Destination -Destination $backupPath -Recurse -Force
            Write-Log "INFO" "Backed up existing file: $Destination"
        }
        
        # Copy file
        Copy-Item -Path $Source -Destination $Destination -Force
        Write-Log "INFO" "Successfully installed: $Destination"
        return $true
    }
    catch {
        Write-Log "ERROR" "Failed to install: $Destination - $($_.Exception.Message)"
        return $false
    }
}

# Function to create backup and install directory
function Install-Directory {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description = "Installing directory"
    )
    
    Write-Log "INFO" "$Description`: $Destination"
    
    try {
        # Backup existing directory if it exists
        if (Test-Path $Destination) {
            $backupPath = Join-Path $BackupDir "$(Split-Path $Destination -Leaf)-$(Get-Date -Format 'HHmmss')"
            Copy-Item -Path $Destination -Destination $backupPath -Recurse -Force
            Write-Log "INFO" "Backed up existing directory: $Destination"
        }
        
        # Copy directory
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        Write-Log "INFO" "Successfully installed: $Destination"
        return $true
    }
    catch {
        Write-Log "ERROR" "Failed to install: $Destination - $($_.Exception.Message)"
        return $false
    }
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Check if app should be installed
function Should-InstallApp {
    param([string]$App)
    
    if ($Force) {
        return $true
    }
    
    switch ($App) {
        "windows_terminal" {
            Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsTerminal"
        }
        "powershell" {
            $true # PowerShell is always available
        }
        "cmd" {
            $true # CMD is always available
        }
        "firefox" {
            Test-Command "firefox" -or Test-Path "$env:PROGRAMFILES\Mozilla Firefox" -or Test-Path "$env:PROGRAMFILES (x86)\Mozilla Firefox"
        }
        "chrome" {
            Test-Command "chrome" -or Test-Command "google-chrome" -or Test-Path "$env:PROGRAMFILES\Google\Chrome\Application" -or Test-Path "$env:PROGRAMFILES (x86)\Google\Chrome\Application"
        }
        "opera" {
            Test-Command "opera" -or Test-Path "$env:PROGRAMFILES\Opera" -or Test-Path "$env:PROGRAMFILES (x86)\Opera"
        }
        "discord" {
            Test-Path "$env:LOCALAPPDATA\Discord" -or Test-Path "$env:PROGRAMFILES\Discord" -or Test-Path "$env:PROGRAMFILES (x86)\Discord"
        }
        "windows" {
            $true # Windows theme can always be applied
        }
        default {
            Test-Command $App -or Test-Path "$env:USERPROFILE\.config\$App"
        }
    }
}

# Install specific application
function Install-App {
    param([string]$AppName)
    
    $scriptPath = Join-Path $ScriptDir "install.d" "$AppName.ps1"
    
    if (Test-Path $scriptPath) {
        Write-Log "INFO" "Installing $AppName using PowerShell script"
        try {
            & $scriptPath
            Write-Log "INFO" "Successfully installed $AppName"
            return $true
        }
        catch {
            Write-Log "ERROR" "Failed to install $AppName - $($_.Exception.Message)"
            return $false
        }
    }
    else {
        Write-Log "WARN" "No install script found for $AppName - skipping"
        return $false
    }
}

# Install all applications
function Install-AllApps {
    Write-Log "INFO" "Installing all MilkOutside extras..."
    Initialize-Backup
    
    $total = $AllApps.Length
    $current = 0
    
    foreach ($app in $AllApps) {
        $current++
        Show-Progress -Current $current -Total $total -Description $app
        
        if (Should-InstallApp $app) {
            Install-App $app | Out-Null
        }
        else {
            Write-Log "INFO" "Skipping $app (not detected)"
        }
    }
}

# List available applications
function Show-AppList {
    Write-Host "Available applications:" -ForegroundColor $Colors.Blue
    Write-Host ""
    
    foreach ($app in $AllApps) {
        Write-Host ("  {0,-15} {1}" -f $app, (Get-AppDescription $app)) -ForegroundColor $Colors.Yellow
    }
    
    Write-Host ""
    Write-Host "Usage: .\install.ps1 [-App] app1 [app2] ... [-All]" -ForegroundColor $Colors.Green
    Write-Host "       .\install.ps1 -All (install all detected apps)" -ForegroundColor $Colors.Green
    Write-Host "       .\install.ps1 -List (show available)" -ForegroundColor $Colors.Green
}

# Show help
function Show-Help {
    Write-Host "MilkOutside Extras Installer - PowerShell Version" -ForegroundColor $Colors.Blue
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor $Colors.Green
    Write-Host "  .\install.ps1 [options] [applications...]"
    Write-Host ""
    Write-Host "Options:" -ForegroundColor $Colors.Green
    Write-Host "  -Help                   Show this help message"
    Write-Host "  -List                   List all available applications"
    Write-Host "  -All                    Install all detected applications"
    Write-Host "  -App <name>             Install specific application"
    Write-Host "  -Force                  Force install even if app not detected"
    Write-Host "  -Rollback               Rollback to previous configuration"
    Write-Host "  -Deps                   Install dependencies only"
    Write-Host "  -Debug                  Enable debug output"
    Write-Host "  -KeepBackup             Don't delete backup after successful installation"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Colors.Green
    Write-Host "  .\install.ps1 -All                           # Install all detected apps"
    Write-Host "  .\install.ps1 -App windows_terminal,powershell   # Install specific apps"
    Write-Host "  .\install.ps1 -App discord -Force           # Force install Discord theme"
    Write-Host ""
}

# Cleanup function
function Invoke-Cleanup {
    if (!$KeepBackup -and (Test-Path $BackupDir)) {
        Write-Log "INFO" "Cleaning up backup directory: $BackupDir"
        Remove-Item -Path $BackupDir -Recurse -Force
    }
}

# Set up cleanup on exit
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Invoke-Cleanup
} | Out-Null

# Main execution
try {
    if ($Help -or (!$Apps -and !$All -and !$List -and !$Rollback -and !$Deps)) {
        Show-Help
        exit 0
    }
    
    if ($List) {
        Show-AppList
        exit 0
    }
    
    if ($Rollback) {
        Write-Log "WARN" "Rollback functionality not yet implemented in PowerShell version"
        exit 1
    }
    
    if ($Deps) {
        Write-Log "INFO" "Installing dependencies..."
        # Add dependency installation logic here
        exit 0
    }
    
    if ($All) {
        Install-AllApps
    }
    elseif ($Apps.Count -gt 0) {
        Initialize-Backup
        foreach ($app in $Apps) {
            if (Should-InstallApp $app -or $Force) {
                Install-App $app | Out-Null
            }
            else {
                Write-Log "INFO" "Skipping $app (not detected)"
            }
        }
    }
    
    Write-Log "INFO" "Installation complete!"
    Write-Log "INFO" "Backups saved to: $BackupDir"
    Write-Log "INFO" "Log file: $LogFile"
    Write-Log "INFO" "You may need to restart applications or reload their configurations."
}
catch {
    Write-Log "ERROR" "Installation failed: $($_.Exception.Message)"
    exit 1
}