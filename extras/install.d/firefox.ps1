# Firefox Theme Installer for Windows

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Get-FirefoxProfile {
    try {
        $firefoxDir = $null
        
        # Check common Firefox profile locations on Windows
        $possiblePaths = @(
            "$env:APPDATA\Mozilla\Firefox\Profiles",
            "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles",
            "$env:PROGRAMFILES\Mozilla Firefox\browser",
            "$env:PROGRAMFILES (x86)\Mozilla Firefox\browser"
        )
        
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $firefoxDir = $path
                break
            }
        }
        
        if (!$firefoxDir) {
            Write-Log "ERROR" "Firefox profile directory not found"
            return ""
        }
        
        # Look for default profile
        $profiles = Get-ChildItem -Path $firefoxDir -Directory | Where-Object { $_.Name -like "*.default*" -or $_.Name -like "*default-release*" }
        
        if ($profiles.Count -gt 0) {
            return Join-Path $firefoxDir $profiles[0].Name
        }
        
        # Fallback to first profile directory
        $firstProfile = Get-ChildItem -Path $firefoxDir -Directory | Select-Object -First 1
        if ($firstProfile) {
            return Join-Path $firefoxDir $firstProfile.Name
        }
        
        return ""
    }
    catch {
        Write-Log "ERROR" "Error finding Firefox profile: $($_.Exception.Message)"
        return ""
    }
}

function Install-Firefox {
    try {
        Write-Log "INFO" "Installing Firefox theme..."
        
        $themeFile = Join-Path $script:RepoRoot "extras\firefox\userChrome.css"
        
        if (!(Test-Path $themeFile)) {
            Write-Log "ERROR" "Firefox theme file not found at: $themeFile"
            return $false
        }
        
        $firefoxProfile = Get-FirefoxProfile
        
        if ([string]::IsNullOrEmpty($firefoxProfile)) {
            Write-Log "ERROR" "Firefox profile not found. Make sure Firefox is installed and has been run at least once."
            return $false
        }
        
        Write-Log "INFO" "Found Firefox profile: $firefoxProfile"
        
        $chromeDir = Join-Path $firefoxProfile "chrome"
        if (!(Test-Path $chromeDir)) {
            New-Item -ItemType Directory -Path $chromeDir -Force | Out-Null
        }
        
        $userChromeFile = Join-Path $chromeDir "userChrome.css"
        if (Install-File -Source $themeFile -Destination $userChromeFile -Description "Firefox theme") {
            # Create or update user.js
            $userJsFile = Join-Path $firefoxProfile "user.js"
            
            $prefs = @(
                'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);',
                'user_pref("svg.context-properties.content.enabled", true);',
                'user_pref("layout.css.color-mix.enabled", true);',
                'user_pref("browser.compactmode.show", true);',
                'user_pref("browser.uidensity", 0);',
                'user_pref("ui.systemUsesDarkTheme", 1);'
            )
            
            if (!(Test-Path $userJsFile)) {
                Write-Log "INFO" "Creating user.js to enable custom stylesheets"
                Set-Content -Path $userJsFile -Value "// Firefox user preferences for MilkOutside theme`r`n"
                Add-Content -Path $userJsFile -Value $prefs
            } else {
                $content = Get-Content $userJsFile -Raw
                foreach ($pref in $prefs) {
                    if ($content -notmatch [regex]::Escape($pref.Split('(')[0])) {
                        Add-Content -Path $userJsFile -Value $pref
                    }
                }
            }
            
            Write-Log "INFO" "Firefox theme installed successfully"
            Write-Log "INFO" "Restart Firefox to see changes"
            
            # Restart Firefox if running
            $firefoxProcess = Get-Process -Name "firefox" -ErrorAction SilentlyContinue
            if ($firefoxProcess) {
                Write-Log "INFO" "Firefox is running. Please restart Firefox manually to apply the theme."
            }
            
            return $true
        }
        
        return $false
    }
    catch {
        Write-Log "ERROR" "Failed to install Firefox theme: $($_.Exception.Message)"
        return $false
    }
}

# Run installation
Install-Firefox