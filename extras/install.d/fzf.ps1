# FZF Theme Installer for Windows

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Install-FZFTheme {
    try {
        Write-Log "INFO" "Installing FZF theme..."
        
        $fzfConfigDir = "$env:USERPROFILE\.config\fzf"
        $themeFile = Join-Path $fzfConfigDir "milkoutside.sh"
        $sourceThemeFile = Join-Path $script:RepoRoot "extras\fzf\milkoutside.sh"
        
        if (!(Test-Path $sourceThemeFile)) {
            Write-Log "ERROR" "FZF theme file not found at: $sourceThemeFile"
            return $false
        }
        
        # Create config directory
        New-Item -ItemType Directory -Path $fzfConfigDir -Force | Out-Null
        
        # Install theme file
        if (Install-File -Source $sourceThemeFile -Destination $themeFile -Description "FZF theme") {
            # Check for shell configuration files and source the theme
            $shellConfigs = @(
                "$env:USERPROFILE\.bashrc",
                "$env:USERPROFILE\.zshrc",
                "$env:USERPROFILE\.profile",
                "$env:USERPROFILE\.bash_profile"
            )
            
            $sourceLine = "source ~/.config/fzf/milkoutside.sh 2>/dev/null || true"
            
            foreach ($configFile in $shellConfigs) {
                if (Test-Path $configFile) {
                    $content = Get-Content $configFile -Raw
                    if ($content -notmatch "milkoutside.sh") {
                        Write-Log "INFO" "Adding FZF theme to $(Split-Path $configFile -Leaf)"
                        Add-Content -Path $configFile -Value "`r`n`" MilkOutside FZF theme`r`n$sourceLine`""
                    }
                }
            }
            
            # For PowerShell, add to profile if it exists
            $psProfile = $PROFILE.CurrentUserAllHosts
            if (Test-Path $psProfile) {
                $content = Get-Content $psProfile -Raw
                if ($content -notmatch "milkoutside") {
                    Write-Log "INFO" "Adding FZF theme to PowerShell profile"
                    $psConfig = @'

# MilkOutside FZF theme for PowerShell
$env:FZF_DEFAULT_OPTS = '--color=bg:#000000,fg:#e8e8e8,hl:#e45555,fg+:#e8e8e8,bg+:#1a1a1a,hl+:#fda1a0,info:#63c3dd,prompt:#e45555,pointer:#fda1a0,marker:#e45555,spinner:#f8e063,header:#5dd48c'
'@
                    Add-Content -Path $psProfile -Value $psConfig
                }
            } else {
                Write-Log "INFO" "PowerShell profile not found. FZF theme will be loaded when you restart your shell."
            }
            
            # Set environment variable for current session
            $env:FZF_DEFAULT_OPTS = '--color=bg:#000000,fg:#e8e8e8,hl:#e45555,fg+:#e8e8e8,bg+:#1a1a1a,hl+:#fda1a0,info:#63c3dd,prompt:#e45555,pointer:#fda1a0,marker:#e45555,spinner:#f8e063,header:#5dd48c'
            
            Write-Log "INFO" "FZF theme installed successfully"
            Write-Log "INFO" "Restart your shell to apply the theme"
            return $true
        }
        
        return $false
    }
    catch {
        Write-Log "ERROR" "Failed to install FZF theme: $($_.Exception.Message)"
        return $false
    }
}

# Run installation
Install-FZFTheme