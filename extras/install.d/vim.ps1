# Vim/Neovim Theme Installer for Windows

$ErrorActionPreference = "Stop"

# Import common functions
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "common.ps1")

function Install-VimTheme {
    try {
        Write-Log "INFO" "Installing Vim theme..."
        
        $vimConfigDir = "$env:USERPROFILE\vimfiles"
        $colorsDir = Join-Path $vimConfigDir "colors"
        $sourceColorsDir = Join-Path $script:RepoRoot "extras\vim\colors"
        
        if (!(Test-Path $sourceColorsDir)) {
            Write-Log "WARN" "Vim colors directory not found at: $sourceColorsDir"
        } else {
            if (!(Test-Path $colorsDir)) {
                New-Item -ItemType Directory -Path $colorsDir -Force | Out-Null
            }
            
            if (Install-Directory -Source $sourceColorsDir -Destination $colorsDir -Description "Vim colors") {
                Write-Log "INFO" "Vim colors installed successfully"
            }
        }
        
        # Update _vimrc if it exists
        $vimrc = "$env:USERPROFILE\_vimrc"
        if (Test-Path $vimrc) {
            $content = Get-Content $vimrc -Raw
            if ($content -notmatch "colorscheme milkoutside") {
                Write-Log "INFO" "Adding colorscheme to _vimrc"
                Add-Content -Path $vimrc -Value "`r`n`" MilkOutside theme`r`n`colorscheme milkoutside`""
            }
        } else {
            Write-Log "INFO" "Creating basic _vimrc"
            $vimrcContent = @'
" Basic Vim configuration
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab

" MilkOutside theme
colorscheme milkoutside
'@
            Set-Content -Path $vimrc -Value $vimrcContent -Encoding UTF8
        }
        
        return $true
    }
    catch {
        Write-Log "ERROR" "Failed to install Vim theme: $($_.Exception.Message)"
        return $false
    }
}

function Install-NeovimTheme {
    try {
        Write-Log "INFO" "Installing Neovim theme..."
        
        $nvimConfigDir = "$env:LOCALAPPDATA\nvim"
        if (!(Test-Path $nvimConfigDir)) {
            $nvimConfigDir = "$env:USERPROFILE\.config\nvim"
        }
        
        $colorsDir = Join-Path $nvimConfigDir "colors"
        $luaColorsDir = Join-Path $nvimConfigDir "lua\colors"
        
        # Create directories
        New-Item -ItemType Directory -Path $colorsDir -Force | Out-Null
        New-Item -ItemType Directory -Path $luaColorsDir -Force | Out-Null
        
        # Install traditional Vim colors
        $sourceColorsDir = Join-Path $script:RepoRoot "extras\vim\colors"
        if (Test-Path $sourceColorsDir) {
            Write-Log "INFO" "Installing Vim colors for Neovim"
            Get-ChildItem -Path $sourceColorsDir -Filter "*.vim" | ForEach-Object {
                Copy-Item -Path $_.FullName -Destination $colorsDir -Force
            }
        }
        
        # Install Lua colorscheme
        $luaThemeFile = Join-Path $script:RepoRoot "extras\lua\milkoutside.lua"
        if (Test-Path $luaThemeFile) {
            $destLuaFile = Join-Path $luaColorsDir "milkoutside.lua"
            if (Install-File -Source $luaThemeFile -Destination $destLuaFile -Description "Neovim Lua colorscheme") {
                # Update init.lua if it exists
                $initFile = Join-Path $nvimConfigDir "init.lua"
                if (Test-Path $initFile) {
                    $content = Get-Content $initFile -Raw
                    if ($content -notmatch "colorscheme.*milkoutside") {
                        Write-Log "INFO" "Adding colorscheme to init.lua"
                        $newContent = @'
-- MilkOutside theme configuration
vim.cmd.colorscheme('milkoutside')

'@ + $content
                        Set-Content -Path $initFile -Value $newContent -Encoding UTF8
                    }
                } else {
                    Write-Log "INFO" "Creating basic init.lua"
                    $initContent = @'
-- MilkOutside theme configuration
vim.cmd.colorscheme('milkoutside')

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
'@
                    Set-Content -Path $initFile -Value $initContent -Encoding UTF8
                }
            }
        }
        
        Write-Log "INFO" "Neovim theme installed successfully"
        return $true
    }
    catch {
        Write-Log "ERROR" "Failed to install Neovim theme: $($_.Exception.Message)"
        return $false
    }
}

# Run installation based on script name
$scriptName = Split-Path -Leaf $MyInvocation.MyCommand.Definition -LeafBase

switch ($scriptName) {
    "vim" {
        Install-VimTheme
    }
    "neovim" -or "nvim" {
        Install-NeovimTheme
    }
    default {
        Install-VimTheme
        Install-NeovimTheme
    }
}