# Tmux Theme Installer for Windows (WSL)

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Test-WSLCommand {
    param([string]$Command)
    
    try {
        $result = wsl -- bash -c "command -v $Command" 2>$null
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function Install-TmuxTheme {
    try {
        Write-Log "INFO" "Installing Tmux theme for Windows WSL..."
        
        if (!(Test-WSLCommand "tmux")) {
            Write-Log "ERROR" "Tmux not found in WSL. Please install Tmux in your WSL distribution first."
            Write-Log "INFO" "Install with: sudo apt-get install tmux (Ubuntu/Debian) or sudo dnf install tmux (Fedora)"
            return $false
        }
        
        $tmuxConfigDir = "$env:USERPROFILE\.config\tmux"
        $themeFile = Join-Path $tmuxConfigDir "milkoutside.tmux"
        $sourceThemeFile = Join-Path $script:RepoRoot "extras\tmux\milkoutside.tmux"
        
        if (!(Test-Path $sourceThemeFile)) {
            Write-Log "ERROR" "Tmux theme file not found at: $sourceThemeFile"
            return $false
        }
        
        # Create config directory
        New-Item -ItemType Directory -Path $tmuxConfigDir -Force | Out-Null
        
        # Install theme file
        if (Install-File -Source $sourceThemeFile -Destination $themeFile -Description "Tmux theme") {
            # Update .tmux.conf to source the theme
            $tmuxConf = "$env:USERPROFILE\.tmux.conf"
            
            $tmuxConfContent = @'
# Tmux configuration

# MilkOutside theme
source-file ~/.config/tmux/milkoutside.tmux

# Basic settings
set -g mouse on
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"
'@
            
            if (Test-Path $tmuxConf) {
                $content = Get-Content $tmuxConf -Raw
                if ($content -notmatch "milkoutside.tmux") {
                    Write-Log "INFO" "Adding theme to .tmux.conf"
                    Add-Content -Path $tmuxConf -Value "`r`n`" MilkOutside theme`r`nsource-file ~/.config/tmux/milkoutside.tmux`""
                }
            } else {
                Write-Log "INFO" "Creating .tmux.conf"
                Set-Content -Path $tmuxConf -Value $tmuxConfContent -Encoding UTF8
            }
            
            # Copy theme to WSL home directory
            $wslHome = wsl -- bash -c 'echo $HOME' 2>$null
            if ($wslHome) {
                try {
                    $wslTmuxDir = "$wslHome\.config\tmux"
                    $wslThemeFile = "$wslTmuxDir\milkoutside.tmux"
                    
                    # Copy to WSL using wsl command
                    $themeContent = Get-Content $themeFile -Raw
                    $themeContent | wsl -- bash -c "cat > '$wslThemeFile'"
                    
                    $tmuxConfContent = Get-Content $tmuxConf -Raw
                    $tmuxConfContent | wsl -- bash -c "cat > '$wslHome/.tmux.conf'"
                    
                    Write-Log "INFO" "Tmux theme copied to WSL successfully"
                }
                catch {
                    Write-Log "WARN" "Failed to copy theme to WSL. Manual setup may be required."
                    Write-Log "INFO" "Copy these files to your WSL home directory:"
                    Write-Log "INFO" "  - $themeFile -> ~/.config/tmux/milkoutside.tmux"
                    Write-Log "INFO" "  - $tmuxConf -> ~/.tmux.conf"
                }
            }
            
            Write-Log "INFO" "Tmux theme installed successfully"
            Write-Log "INFO" "Reload Tmux configuration with: tmux source-file ~/.tmux.conf"
            return $true
        }
        
        return $false
    }
    catch {
        Write-Log "ERROR" "Failed to install Tmux theme: $($_.Exception.Message)"
        return $false
    }
}

# Run installation
Install-TmuxTheme