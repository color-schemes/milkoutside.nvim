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

# Check if BetterDiscord is installed and working
is_betterdiscord_installed() {
    local discord_dir=$(get_discord_dir)
    
    if [ -z "$discord_dir" ]; then
        return 1
    fi
    
    case "$OS" in
        "macos")
            # Check if BetterDiscord directory exists and app.asar is patched
            [ -d "$HOME/Library/Application Support/BetterDiscord" ] && [ -f "$discord_dir/Contents/Resources/app.asar" ]
            ;;
        "linux")
            [ -d "$HOME/.config/BetterDiscord" ] && [ -f "$discord_dir/resources/app.asar" ]
            ;;
        "windows")
            [ -d "$APPDATA\\BetterDiscord" ] && [ -d "$discord_dir/app-*" ]
            ;;
        *)
            return 1
            ;;
    esac
}

# Check if BetterDiscord needs repair after Discord update
needs_betterdiscord_repair() {
    local discord_dir=$(get_discord_dir)
    
    if [ -z "$discord_dir" ]; then
        return 1
    fi
    
    case "$OS" in
        "macos")
            # More reliable check: if BetterDiscord exists and app.asar is original Discord (not patched)
            [ -d "$HOME/Library/Application Support/BetterDiscord" ] && [ -f "$discord_dir/Contents/Resources/app.asar.bak" ]
            ;;
        "linux")
            [ -d "$HOME/.config/BetterDiscord" ] && [ -f "$discord_dir/resources/app.asar.bak" ]
            ;;
        "windows")
            # Windows check is more complex, just assume repair needed if BD exists
            [ -d "$APPDATA\\BetterDiscord" ]
            ;;
        *)
            return 1
            ;;
    esac
}

# Repair BetterDiscord after Discord update
repair_betterdiscord() {
    log "INFO" "BetterDiscord needs repair after Discord update..."
    
    case "$OS" in
        "macos")
            # Try Homebrew repair first
            if command_exists "brew"; then
                log "INFO" "Attempting to repair BetterDiscord via Homebrew..."
                if brew reinstall --cask betterdiscord 2>/dev/null; then
                    return 0
                else
                    log "WARN" "Homebrew repair failed, trying manual installer..."
                fi
            fi
            
            # Fallback to manual installer
            local installer="/tmp/BetterDiscord-Mac.zip"
            if download_betterdiscord_installer; then
                if run_betterdiscord_installer "$installer" "repair"; then
                    rm -f "$installer"
                    return 0
                else
                    rm -f "$installer"
                    return 1
                fi
            else
                log "INFO" "Please install BetterDiscord manually from https://betterdiscord.app"
                return 1
            fi
            ;;
        "linux")
            log "INFO" "Downloading BetterDiscord installer for repair..."
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
                log "INFO" "Running BetterDiscord repair..."
                "$installer"
                rm -f "$installer"
                return 0
            else
                log "ERROR" "Failed to download BetterDiscord installer"
                return 1
            fi
            ;;
        "windows")
            log "INFO" "Please run the BetterDiscord installer and select 'Repair BetterDiscord'"
            start "https://betterdiscord.app" 2>/dev/null
            return 0
            ;;
        *)
            log "ERROR" "Unsupported OS for BetterDiscord repair"
            return 1
            ;;
    esac
}

# Download BetterDiscord installer for macOS
download_betterdiscord_installer() {
    local installer="/tmp/BetterDiscord-Mac.zip"
    
    log "INFO" "Downloading BetterDiscord installer for macOS..."
    
    # Remove any existing partial download
    rm -f "$installer"
    
    local download_url="https://github.com/BetterDiscord/Installer/releases/latest/download/BetterDiscord-Mac.zip"
    
    if command_exists "curl"; then
        log "INFO" "Using curl to download: $download_url"
        if curl -L --progress-bar -o "$installer" "$download_url"; then
            log "INFO" "Download completed successfully"
        else
            log "ERROR" "curl download failed"
            return 1
        fi
    elif command_exists "wget"; then
        log "INFO" "Using wget to download: $download_url"
        if wget --progress=bar:force -O "$installer" "$download_url"; then
            log "INFO" "Download completed successfully"
        else
            log "ERROR" "wget download failed"
            return 1
        fi
    else
        log "ERROR" "Neither curl nor wget available to download BetterDiscord"
        return 1
    fi
    
    if [ -f "$installer" ] && [ -s "$installer" ]; then
        return 0
    else
        log "ERROR" "Failed to download BetterDiscord installer or file is empty"
        return 1
    fi
}

# Run BetterDiscord installer (install or repair)
run_betterdiscord_installer() {
    local installer="$1"
    local action="$2"  # "install" or "repair"
    
    log "INFO" "Running BetterDiscord installer ($action)..."
    
    # Check if installer file exists
    if [ ! -f "$installer" ]; then
        log "ERROR" "Installer file not found: $installer"
        return 1
    fi
    
    case "$OS" in
        "macos")
            # Extract and copy the .app to Applications for macOS
            cd /tmp
            log "INFO" "Extracting BetterDiscord installer in /tmp..."
            if unzip -q "$installer"; then
                local installer_app="/tmp/BetterDiscord.app"
                
                if [ -n "$installer_app" ]; then
                    local app_name=$(basename "$installer_app")
                    local dest_app="/Applications/$app_name"
                    
                    log "INFO" "Copying $app_name to Applications..."
                    # Remove existing app if it exists
                    if [ -d "$dest_app" ]; then
                        rm -rf "$dest_app"
                    fi
                    cp -r "$installer_app" "$dest_app"
                    
                    log "INFO" "Starting BetterDiscord installer from Applications..."
                    open "$dest_app"
                    
                    log "INFO" "Please complete the BetterDiscord installation:"
                    log "INFO" "1. Select '$action' in the installer"
                    log "INFO" "2. Choose your Discord build"
                    log "INFO" "3. Click '$action BetterDiscord'"
                    log "INFO" "4. Wait for installation to complete"
                    
                    # Wait for installation
                    sleep 15
                    # Clean up only the extracted app in /tmp, keep the one in Applications
                    rm -rf "$installer_app"
                    return 0
                else
                    log "ERROR" "Could not find BetterDiscord installer app in ZIP"
                    return 1
                fi
            else
                log "ERROR" "Failed to extract BetterDiscord installer ZIP"
                return 1
            fi
            ;;
        "linux")
            # Run the AppImage directly
            log "INFO" "Starting BetterDiscord installer..."
            chmod +x "$installer"
            "$installer"
            return 0
            ;;
        *)
            log "ERROR" "Unsupported OS for manual installer"
            return 1
            ;;
    esac
}

# Install BetterDiscord automatically
install_betterdiscord() {
    log "INFO" "Installing BetterDiscord..."
    
    case "$OS" in
        "macos")
            # Try Homebrew first
            if command_exists "brew"; then
                log "INFO" "Installing BetterDiscord via Homebrew Cask..."
                if brew install --cask betterdiscord; then
                    return 0
                else
                    log "WARN" "Homebrew installation failed, trying manual installer..."
                fi
            fi
            
            # Fallback to manual installer download
            if download_betterdiscord_installer; then
                if run_betterdiscord_installer "/tmp/BetterDiscord-Mac.zip" "install"; then
                    rm -f "/tmp/BetterDiscord-Mac.zip"
                    return 0
                else
                    rm -f "/tmp/BetterDiscord-Mac.zip"
                    return 1
                fi
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
    
    # Always install BetterDiscord to ensure it's working
    log "INFO" "Installing BetterDiscord..."
    if ! install_betterdiscord; then
            log "INFO" "Please install BetterDiscord manually from https://betterdiscord.app"
            log "INFO" "After installation, run the script again to install the theme"
        return 1
    fi
    log "INFO" "Please restart Discord after BetterDiscord installation"
    
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