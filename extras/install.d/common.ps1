# Common PowerShell functions for MilkOutside installer

# Colors for output
$script:Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Magenta = "Magenta"
    Cyan = "Cyan"
    White = "White"
}

# Global variables
$script:RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:BackupDir = "$env:USERPROFILE\.config\milkoutside-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$script:LogFile = "$env:TEMP\milkoutside-install.log"

# Logging function
function Write-Log {
    param(
        [string]$Level,
        [string]$Message
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $script:LogFile -Value $logEntry
    
    $color = switch ($Level) {
        "INFO" { $script:Colors.Green }
        "WARN" { $script:Colors.Yellow }
        "ERROR" { $script:Colors.Red }
        "DEBUG" { if ($script:Debug) { $script:Colors.Blue } else { $script:Colors.White } }
        default { $script:Colors.White }
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
            $backupPath = Join-Path $script:BackupDir "$(Split-Path $Destination -Leaf)-$(Get-Date -Format 'HHmmss')"
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
            $backupPath = Join-Path $script:BackupDir "$(Split-Path $Destination -Leaf)-$(Get-Date -Format 'HHmmss')"
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
    
    if ($script:Force) {
        return $true
    }
    
    switch ($App) {
        "windows_terminal" {
            Test-Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\Settings\settings.json"
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
            Test-Path "$env:LOCALAPPDATA\Discord" -or Test-Path "$env:APPDATA\Discord"
        }
        "windows" {
            $true # Windows theme can always be applied
        }
        default {
            Test-Command $App -or Test-Path "$env:USERPROFILE\.config\$App"
        }
    }
}

# Export functions
Export-ModuleMember -Function Write-Log, Show-Progress, Install-File, Install-Directory, Test-Command, Should-InstallApp