# Windows High Contrast Theme Installer

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Install-WindowsTheme {
    try {
        Write-Log "INFO" "Installing Windows high contrast theme..."
        
        # Create the registry hive for custom theme
        $themeRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $colorsRegPath = "HKCU:\Control Panel\Colors"
        
        # Backup current settings
        reg export "$themeRegPath" "$BackupDir\windows-personalize-$(Get-Date -Format 'HHmmss').reg" /y | Out-Null
        reg export "$colorsRegPath" "$BackupDir\windows-colors-$(Get-Date -Format 'HHmmss').reg" /y | Out-Null
        
        # Set system to dark mode
        Set-ItemProperty -Path $themeRegPath -Name "AppsUseLightTheme" -Value 0
        Set-ItemProperty -Path $themeRegPath -Name "SystemUsesLightTheme" -Value 0
        
        # Set high contrast colors to match MilkOutside
        $colors = @{
            "Background" = "0 0 0"  # Pure black
            "Hilight" = "253 161 160"  # MilkOutside red #fda1a0
            "HilightText" = "0 0 0"  # Black on red
            "WindowText" = "232 232 232"  # Light gray text
            "Window" = "26 26 26"  # Dark gray
            "WindowFrame" = "15 15 15"  # Darker gray
            "Menu" = "20 20 20"  # Very dark
            "MenuText" = "232 232 232"  # Light gray
            "ActiveTitle" = "228 85 85"  # Darker MilkOutside red #e45555
            "InactiveTitle" = "26 26 26"  # Dark gray
            "TitleText" = "232 232 232"  # Light gray
            "ActiveBorder" = "228 85 85"  # MilkOutside red
            "InactiveBorder" = "64 64 64"  # Medium gray
            "ButtonDkShadow" = "0 0 0"  # Black
            "ButtonFace" = "38 38 38"  # Dark
            "ButtonHilight" = "253 161 160"  # MilkOutside red
            "ButtonLight" = "64 64 64"  # Medium gray
            "ButtonShadow" = "20 20 20"  # Dark gray
            "ButtonText" = "232 232 232"  # Light gray
            "GrayText" = "128 128 128"  # Muted gray
            "HotTrackingColor" = "253 161 160"  # MilkOutside red
            "InfoText" = "232 232 232"  # Light gray
            "InfoWindow" = "26 26 26"  # Dark gray
            "MenuHilight" = "228 85 85"  # MilkOutside red
            "Scrollbar" = "64 64 64"  # Medium gray
            "WindowTextColor" = "232 232 232"  # Light gray
        }
        
        # Apply colors
        foreach ($color in $colors.GetEnumerator()) {
            Set-ItemProperty -Path $colorsRegPath -Name $color.Key -Value $color.Value
        }
        
        # Set accent color
        $accentRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
        Set-ItemProperty -Path $accentRegPath -Name "AccentPalette" -Value ([byte[]](253,161,160,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
        Set-ItemProperty -Path $accentRegPath -Name "StartColorMenu" -Value 0xFFE45555
        Set-ItemProperty -Path $accentRegPath -Name "AccentColorMenu" -Value 0xFFFDA1A0
        
        # Refresh system
        Start-Sleep -Seconds 1
        $null = Get-Process explorer | Where-Object { $_.MainWindowHandle -ne 0 } | ForEach-Object { $_.Refresh() }
        
        Write-Log "INFO" "Windows high contrast theme applied successfully"
        Write-Log "INFO" "You may need to restart your PC to see all changes"
        Write-Log "INFO" "To enable high contrast: Settings > Ease of Access > High contrast > Select 'High Contrast Black'"
        
        return $true
    }
    catch {
        Write-Log "ERROR" "Failed to install Windows theme: $($_.Exception.Message)"
        return $false
    }
}

# Run installation
Install-WindowsTheme