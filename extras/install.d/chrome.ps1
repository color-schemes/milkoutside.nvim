# Chrome Theme Installer for Windows

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Get-ChromeProfile {
    try {
        $chromeDir = $null
        
        # Check Chrome installation locations
        $possiblePaths = @(
            "$env:LOCALAPPDATA\Google\Chrome\User Data",
            "$env:PROGRAMFILES\Google\Chrome\Application",
            "$env:PROGRAMFILES (x86)\Google\Chrome\Application"
        )
        
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $chromeDir = $path
                break
            }
        }
        
        if (!$chromeDir -or !(Test-Path "$chromeDir\Default")) {
            Write-Log "ERROR" "Chrome profile directory not found"
            return ""
        }
        
        return Join-Path $chromeDir "Default"
    }
    catch {
        Write-Log "ERROR" "Error finding Chrome profile: $($_.Exception.Message)"
        return ""
    }
}

function Install-ChromeTheme {
    try {
        Write-Log "INFO" "Installing Chrome theme..."
        
        $chromeProfile = Get-ChromeProfile
        
        if ([string]::IsNullOrEmpty($chromeProfile)) {
            Write-Log "ERROR" "Chrome profile not found. Make sure Chrome is installed and has been run at least once."
            return $false
        }
        
        Write-Log "INFO" "Found Chrome profile: $chromeProfile"
        
        # Create Chrome extension
        $extDir = Join-Path $script:BackupDir "milkoutside-chrome-extension"
        New-Item -ItemType Directory -Path $extDir -Force | Out-Null
        
        # Create manifest.json
        $manifestContent = @{
            manifest_version = 3
            name = "MilkOutside Chrome Theme"
            version = "1.0.0"
            description = "Dark, cosmic-inspired theme based on milkoutside.nvim colorscheme"
            author = "milkoutside.nvim"
            homepage_url = "https://github.com/milkoutside/milkoutside.nvim"
            theme = @{
                colors = @{
                    frame = @(0, 0, 0)
                    frame_inactive = @(0, 0, 0)
                    toolbar = @(13, 13, 13)
                    tab_text = @(232, 232, 232)
                    tab_background_text = @(232, 232, 232)
                    bookmark_text = @(232, 232, 232)
                    ntp_background = @(0, 0, 0)
                    ntp_text = @(232, 232, 232)
                    ntp_link = @(253, 161, 160)
                    button_background = @(38, 38, 38)
                    toolbar_button_icon = @(232, 232, 232)
                    address_bar = @(15, 15, 15)
                    address_bar_text = @(232, 232, 232)
                }
            }
        }
        
        $manifestJson = $manifestContent | ConvertTo-Json -Depth 10
        Set-Content -Path (Join-Path $extDir "manifest.json") -Value $manifestJson -Encoding UTF8
        
        # Create extension CSS for web pages
        $cssContent = @'
/* MilkOutside Chrome Theme - Web Page CSS */

html, body {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
}

a, a:link, a:visited {
    color: #fda1a0 !important;
}

a:hover {
    color: #e45555 !important;
}

::selection {
    background-color: #e45555 !important;
    color: #000000 !important;
}

input, textarea, select {
    background-color: #0d0d0d !important;
    color: #e8e8e8 !important;
    border: 1px solid #262626 !important;
}

input:focus, textarea:focus, select:focus {
    border-color: #fda1a0 !important;
    outline: 1px solid #fda1a0 !important;
}
'@
        
        Set-Content -Path (Join-Path $extDir "styles.css") -Value $cssContent -Encoding UTF8
        
        # Create content script
        $contentScript = @'
// MilkOutside Chrome Theme content script
function injectStyles() {
    if (document.getElementById('milkoutside-styles')) return;
    
    const style = document.createElement('link');
    style.id = 'milkoutside-styles';
    style.rel = 'stylesheet';
    style.type = 'text/css';
    style.href = chrome.runtime.getURL('styles.css');
    document.head.appendChild(style);
}

injectStyles();
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', injectStyles);
}
'@
        
        Set-Content -Path (Join-Path $extDir "content.js") -Value $contentScript -Encoding UTF8
        
        # Update manifest for content scripts
        $manifestContent.permissions = @("activeTab", "storage")
        $manifestContent.content_scripts = @(
            @{
                matches = @("<all_urls>")
                css = @("styles.css")
                js = @("content.js")
                run_at = "document_start"
            }
        )
        
        $manifestJson = $manifestContent | ConvertTo-Json -Depth 10
        Set-Content -Path (Join-Path $extDir "manifest.json") -Value $manifestJson -Encoding UTF8
        
        Write-Log "INFO" "Chrome extension created at: $extDir"
        Write-Log "INFO" "To install Chrome theme:"
        Write-Log "INFO" "1. Open Chrome"
        Write-Log "INFO" "2. Go to chrome://extensions"
        Write-Log "INFO" "3. Enable 'Developer mode'"
        Write-Log "INFO" "4. Click 'Load unpacked'"
        Write-Log "INFO" "5. Select the extension directory: $extDir"
        Write-Log "INFO" "6. Enable the extension"
        
        # Also create user CSS file for Chrome
        $chromeUserCSS = Join-Path $chromeProfile "User StyleSheets"
        if (!(Test-Path $chromeUserCSS)) {
            New-Item -ItemType Directory -Path $chromeUserCSS -Force | Out-Null
        }
        
        $userCSSFile = Join-Path $chromeUserCSS "milkoutside.css"
        Set-Content -Path $userCSSFile -Value $cssContent -Encoding UTF8
        
        Write-Log "INFO" "User CSS file created: $userCSSFile"
        Write-Log "INFO" "Enable custom CSS in Chrome flags: chrome://flags#enable-css-stylesheets"
        
        return $true
    }
    catch {
        Write-Log "ERROR" "Failed to install Chrome theme: $($_.Exception.Message)"
        return $false
    }
}

# Run installation
Install-ChromeTheme