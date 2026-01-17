# Windows Terminal Theme Installer (Enhanced)

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Install-WindowsTerminalTheme {
    try {
        Write-Log "INFO" "Installing Windows Terminal theme..."
        
        # Find Windows Terminal settings file
        $wtSettingsPath = $null
        $localAppData = $env:LOCALAPPDATA
        
        # Check different Windows Terminal package names
        $packageNames = @(
            "Microsoft.WindowsTerminal_8wekyb3d8bbwe",
            "Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe",
            "WindowsTerminal"
        )
        
        foreach ($packageName in $packageNames) {
            $testPath = Join-Path $localAppData "Packages\$packageName\Settings\settings.json"
            if (Test-Path $testPath) {
                $wtSettingsPath = $testPath
                break
            }
        }
        
        if (!$wtSettingsPath) {
            Write-Log "ERROR" "Windows Terminal settings not found. Please install Windows Terminal first."
            return $false
        }
        
        $themeFile = Join-Path $script:RepoRoot "extras\windows_terminal\milkoutside.json"
        
        if (!(Test-Path $themeFile)) {
            Write-Log "ERROR" "Windows Terminal theme file not found at: $themeFile"
            return $false
        }
        
        # Read current settings
        $settings = Get-Content $wtSettingsPath -Raw | ConvertFrom-Json
        
        # Backup current settings
        $backupPath = Join-Path $script:BackupDir "windows-terminal-settings-$(Get-Date -Format 'HHmmss').json"
        Copy-Item -Path $wtSettingsPath -Destination $backupPath
        Write-Log "INFO" "Backed up Windows Terminal settings"
        
        # Add MilkOutside theme
        $themeContent = Get-Content $themeFile -Raw | ConvertFrom-Json
        
        if (!$settings.schemes) {
            $settings | Add-Member -Type NoteProperty -Name "schemes" -Value @()
        }
        
        # Check if theme already exists and remove it
        $settings.schemes = $settings.schemes | Where-Object { $_.name -ne "MilkOutside" }
        
        # Add the new theme
        $settings.schemes += $themeContent
        
        # Set default color scheme for all profiles if they don't have one
        if ($settings.profiles) {
            if ($settings.profiles.defaults) {
                if (!$settings.profiles.defaults.PSObject.Properties.Name -contains "colorScheme") {
                    $settings.profiles.defaults | Add-Member -Type NoteProperty -Name "colorScheme" -Value "MilkOutside"
                } else {
                    $settings.profiles.defaults.colorScheme = "MilkOutside"
                }
            } else {
                $settings | Add-Member -Type NoteProperty -Name "profiles" -Value @{
                    defaults = @{
                        colorScheme = "MilkOutside"
                    }
                }
            }
            
            # Set theme for existing profiles
            foreach ($profile in $settings.profiles.PSObject.Properties | Where-Object { $_.Name -ne "defaults" }) {
                if ($profile.Value -and $profile.Value.PSObject.Properties.Name -notcontains "colorScheme") {
                    $profile.Value | Add-Member -Type NoteProperty -Name "colorScheme" -Value "MilkOutside"
                }
            }
        }
        
        # Save updated settings
        $updatedSettings = $settings | ConvertTo-Json -Depth 10
        Set-Content -Path $wtSettingsPath -Value $updatedSettings -Encoding UTF8
        
        Write-Log "INFO" "Windows Terminal theme installed successfully"
        Write-Log "INFO" "Restart Windows Terminal to apply theme"
        
        # Try to refresh Windows Terminal
        try {
            Get-Process -Name "WindowsTerminal" -ErrorAction SilentlyContinue | Stop-Process -Force
            Start-Sleep -Seconds 1
            Start-Process "wt.exe"
        } catch {
            Write-Log "INFO" "Please restart Windows Terminal manually to apply the theme"
        }
        
        return $true
    }
    catch {
        Write-Log "ERROR" "Failed to install Windows Terminal theme: $($_.Exception.Message)"
        return $false
    }
}

# Run installation
Install-WindowsTerminalTheme