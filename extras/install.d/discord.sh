#!/bin/bash

# Discord theme installer with automatic BetterDiscord integration

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get Discord installation directory
get_discord_dir() {
    local discord_dir=""
    
    case "$OS" in
        "macos")
            if [ -d "/Applications/Discord.app" ]; then
                discord_dir="/Applications/Discord.app"
            elif [ -d "$HOME/Applications/Discord.app" ]; then
                discord_dir="$HOME/Applications/Discord.app"
            fi
            ;;
        "linux")
            if [ -d "/usr/share/discord" ]; then
                discord_dir="/usr/share/discord"
            elif [ -d "/opt/discord" ]; then
                discord_dir="/opt/discord"
            elif [ -d "$HOME/.local/share/discord" ]; then
                discord_dir="$HOME/.local/share/discord"
            fi
            ;;
        "windows")
            if [ -d "$LOCALAPPDATA\\Discord" ]; then
                discord_dir="$LOCALAPPDATA\\Discord"
            elif [ -d "$PROGRAMFILES\\Discord" ]; then
                discord_dir="$PROGRAMFILES\\Discord"
            fi
            ;;
    esac
    
    echo "$discord_dir"
}

# Check if BetterDiscord is installed
is_betterdiscord_installed() {
    local discord_dir=$(get_discord_dir)
    
    if [ -z "$discord_dir" ]; then
        return 1
    fi
    
    case "$OS" in
        "macos")
            [ -f "$discord_dir/Contents/Resources/app.asar" ] && [ -d "$HOME/Library/Application Support/BetterDiscord" ]
            ;;
        "linux")
            [ -f "$discord_dir/resources/app.asar" ] && [ -d "$HOME/.config/BetterDiscord" ]
            ;;
        "windows")
            [ -d "$discord_dir/app-*" ] && [ -d "$APPDATA\\BetterDiscord" ]
            ;;
        *)
            return 1
            ;;
    esac
}

# Install BetterDiscord automatically
install_betterdiscord() {
    log "INFO" "Installing BetterDiscord..."
    
    case "$OS" in
        "macos")
            if command_exists "brew"; then
                log "INFO" "Installing BetterDiscord via Homebrew Cask..."
                brew install --cask betterdiscord
                return 0
            else
                log "INFO" "Please install BetterDiscord manually from https://betterdiscord.app"
                return 1
            fi
            ;;
        "linux")
            log "INFO" "Downloading BetterDiscord installer..."
            local installer="/tmp/betterdiscord-installer.AppImage"
            
            if command_exists "wget"; then
                wget -O "$installer" "https://github.com/BetterDiscord/Installer/releases/latest/download/BetterDiscord-Linux.AppImage" 2>/dev/null
            elif command_exists "curl"; then
                curl -L -o "$installer" "https://github.com/BetterDiscord/Installer/releases/latest/download/BetterDiscord-Linux.AppImage" 2>/dev/null
            else
                log "ERROR" "Neither wget nor curl available to download BetterDiscord"
                return 1
            fi
            
            if [ -f "$installer" ]; then
                chmod +x "$installer"
                log "INFO" "Running BetterDiscord installer..."
                "$installer"
                rm -f "$installer"
                return 0
            else
                log "ERROR" "Failed to download BetterDiscord installer"
                return 1
            fi
            ;;
        "windows")
            log "INFO" "Please download and install BetterDiscord from https://betterdiscord.app"
            start "https://betterdiscord.app" 2>/dev/null
            return 0
            ;;
        *)
            log "ERROR" "Unsupported OS for automatic BetterDiscord installation"
            return 1
            ;;
    esac
}

# Install Discord theme
install_discord() {
    local theme_file="$REPO_ROOT/extras/discord/milkoutside.theme.css"
    local discord_dir=$(get_discord_dir)
    
    if [ ! -f "$theme_file" ]; then
        log "ERROR" "Discord theme file not found"
        return 1
    fi
    
    if [ -z "$discord_dir" ]; then
        log "ERROR" "Discord installation not found"
        return 1
    fi
    
    log "INFO" "Found Discord installation: $discord_dir"
    
    # Check if BetterDiscord is installed
    if ! is_betterdiscord_installed; then
        log "WARN" "BetterDiscord not found. Installing automatically..."
        if ! install_betterdiscord; then
            log "ERROR" "Failed to install BetterDiscord. Please install it manually from https://betterdiscord.app"
            return 1
        fi
        
        log "INFO" "Please restart Discord after BetterDiscord installation"
    fi
    
    # Determine BetterDiscord themes directory
    local themes_dir=""
    case "$OS" in
        "macos")
            themes_dir="$HOME/Library/Application Support/BetterDiscord/themes"
            ;;
        "linux")
            themes_dir="$HOME/.config/BetterDiscord/themes"
            ;;
        "windows")
            themes_dir="$APPDATA\\BetterDiscord\\themes"
            ;;
    esac
    
    if [ -z "$themes_dir" ]; then
        log "ERROR" "BetterDiscord themes directory not found"
        return 1
    fi
    
    # Create themes directory
    mkdir -p "$themes_dir"
    
    # Install theme
    local theme_dest="$themes_dir/milkoutside.theme.css"
    if install_file "$theme_file" "$theme_dest" "Discord theme"; then
        log "INFO" "Discord theme installed successfully"
        log "INFO" "Enable the theme in Discord settings (User Settings > BetterDiscord > Themes)"
        
        # Try to reload Discord themes automatically
        case "$OS" in
            "macos")
                osascript -e 'tell application "Discord" to activate' 2>/dev/null || true
                ;;
            "linux")
                if pgrep -f "discord" > /dev/null; then
                    log "INFO" "Discord is running - reload themes in Discord settings"
                fi
                ;;
        esac
        
        return 0
    else
        return 1
    fi
}

# Run installation
install_discord