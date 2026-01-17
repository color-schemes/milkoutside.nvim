# Discord Theme Installer for Windows

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Install-Discord {
    try {
        Write-Log "INFO" "Installing Discord theme..."
        
        $discordDir = $null
        $themeFile = Join-Path $script:RepoRoot "extras\discord\milkoutside.theme.css"
        
        if (!(Test-Path $themeFile)) {
            Write-Log "ERROR" "Discord theme file not found at: $themeFile"
            return $false
        }
        
        # Check Discord installation locations
        $possiblePaths = @(
            "$env:LOCALAPPDATA\Discord",
            "$env:PROGRAMFILES\Discord",
            "$env:PROGRAMFILES (x86)\Discord",
            "$env:APPDATA\Discord"
        )
        
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $discordDir = $path
                break
            }
        }
        
        if (!$discordDir) {
            Write-Log "ERROR" "Discord installation not found"
            return $false
        }
        
        Write-Log "INFO" "Found Discord installation: $discordDir"
        
        # Check for BetterDiscord
        $betterDiscordDir = $null
        $bdPaths = @(
            "$env:APPDATA\BetterDiscord",
            "$env:LOCALAPPDATA\BetterDiscord"
        )
        
        foreach ($path in $bdPaths) {
            if (Test-Path $path) {
                $betterDiscordDir = $path
                break
            }
        }
        
        if (!$betterDiscordDir) {
            Write-Log "WARN" "BetterDiscord not found. Please install BetterDiscord first from https://betterdiscord.app"
            return $false
        }
        
        $themesDir = Join-Path $betterDiscordDir "themes"
        if (!(Test-Path $themesDir)) {
            New-Item -ItemType Directory -Path $themesDir -Force | Out-Null
        }
        
        $themeDest = Join-Path $themesDir "milkoutside.theme.css"
        if (Install-File -Source $themeFile -Destination $themeDest -Description "Discord theme") {
            Write-Log "INFO" "Discord theme installed successfully"
            Write-Log "INFO" "Enable the theme in Discord settings (User Settings > BetterDiscord > Themes)"
            
            # Restart Discord if running
            $discordProcess = Get-Process -Name "Discord" -ErrorAction SilentlyContinue
            if ($discordProcess) {
                Write-Log "INFO" "Restarting Discord to apply theme..."
                Stop-Process -Name "Discord" -Force
                Start-Sleep -Seconds 2
                Start-Process -FilePath "$discordDir\Update.exe" -ArgumentList "--processStart", "Discord.exe"
            }
            
            return $true
        }
        
        return $false
    }
    catch {
        Write-Log "ERROR" "Failed to install Discord theme: $($_.Exception.Message)"
        return $false
    }
}

# Run installation
Install-Discord