# General App Installer PowerShell Script

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Install-SimpleConfig {
    param(
        [string]$AppName,
        [string]$SourceFile,
        [string]$DestFile,
        [string]$Description = "$AppName theme"
    )
    
    if (!(Test-Path $SourceFile)) {
        Write-Log "WARN" "Source file not found: $SourceFile"
        return $false
    }
    
    $destDir = Split-Path -Parent $DestFile
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    return Install-File -Source $SourceFile -Destination $DestFile -Description $Description
}

# Get app name from script
$appName = Split-Path -Leaf $MyInvocation.MyCommand.Definition -LeafBase

switch ($appName) {
    "alacritty" {
        Install-SimpleConfig -AppName $appName -SourceFile "$script:RepoRoot\extras\alacritty\milkoutside.yml" -DestFile "$env:USERPROFILE\.config\alacritty\milkoutside.yml"
    }
    "kitty" {
        Install-SimpleConfig -AppName $appName -SourceFile "$script:RepoRoot\extras\kitty\milkoutside.conf" -DestFile "$env:USERPROFILE\.config\kitty\milkoutside.conf"
    }
    "wezterm" {
        Install-SimpleConfig -AppName $appName -SourceFile "$script:RepoRoot\extras\wezterm\milkoutside.lua" -DestFile "$env:USERPROFILE\.config\wezterm\milkoutside.lua"
    }
    "fish" {
        Install-SimpleConfig -AppName $appName -SourceFile "$script:RepoRoot\extras\fish\milkoutside.fish" -DestFile "$env:USERPROFILE\.config\fish\functions\milkoutside.fish"
    }
    "lazygit" {
        Install-SimpleConfig -AppName $appName -SourceFile "$script:RepoRoot\extras\lazygit\milkoutside.yml" -DestFile "$env:USERPROFILE\.config\lazygit\config.yml" -Description "LazyGit theme"
    }
    "btop" {
        Install-SimpleConfig -AppName $appName -SourceFile "$script:RepoRoot\extras\btop\milkoutside.theme" -DestFile "$env:USERPROFILE\.config\btop\themes\milkoutside.theme"
    }
    "yazi" {
        Install-SimpleConfig -AppName $appName -SourceFile "$script:RepoRoot\extras\yazi\milkoutside.toml" -DestFile "$env:USERPROFILE\.config\yazi\theme.toml" -Description "Yazi theme"
    }
    "helix" {
        # Helix has more complex installation, so delegate to dedicated script if available
        $helixScript = Join-Path $ScriptDir "helix.ps1"
        if (Test-Path $helixScript) {
            & $helixScript
        } else {
            Install-SimpleConfig -AppName $appName -SourceFile "$script:RepoRoot\extras\helix\milkoutside.toml" -DestFile "$env:USERPROFILE\.config\helix\themes\milkoutside.toml"
        }
    }
    default {
        Write-Log "WARN" "No specific installation logic for $appName"
        
        # Try to find matching files in extras directory
        $extrasDir = Join-Path $script:RepoRoot "extras\$appName"
        if (Test-Path $extrasDir) {
            Write-Log "INFO" "Found extras directory for $appName: $extrasDir"
            $configDir = "$env:USERPROFILE\.config\$appName"
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
            
            Get-ChildItem -Path $extrasDir -File | ForEach-Object {
                $destFile = Join-Path $configDir $_.Name
                Install-File -Source $_.FullName -Destination $destFile -Description "$appName theme file"
            }
        } else {
            Write-Log "ERROR" "Unknown application: $appName"
            exit 1
        }
    }
}