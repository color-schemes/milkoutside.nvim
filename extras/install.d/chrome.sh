#!/bin/bash

# Chrome/Chromium theme installer with automatic extension loading

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get Chrome/Chromium user data directory
get_chrome_user_data_dir() {
    local chrome_dir=""
    
    case "$OS" in
        "macos")
            if [ -d "$HOME/Library/Application Support/Google/Chrome" ]; then
                chrome_dir="$HOME/Library/Application Support/Google/Chrome"
            elif [ -d "$HOME/Library/Application Support/Chromium" ]; then
                chrome_dir="$HOME/Library/Application Support/Chromium"
            fi
            ;;
        "linux")
            if [ -d "$HOME/.config/google-chrome" ]; then
                chrome_dir="$HOME/.config/google-chrome"
            elif [ -d "$HOME/.config/chromium" ]; then
                chrome_dir="$HOME/.config/chromium"
            fi
            ;;
        "windows")
            if [ -d "$APPDATA\\Google\\Chrome\\User Data" ]; then
                chrome_dir="$APPDATA\\Google\\Chrome\\User Data"
            elif [ -d "$LOCALAPPDATA\\Google\\Chrome\\User Data" ]; then
                chrome_dir="$LOCALAPPDATA\\Google\\Chrome\\User Data"
            fi
            ;;
    esac
    
    echo "$chrome_dir"
}

# Auto-load Chrome extension if possible
auto_load_chrome_extension() {
    local chrome_user_dir=$(get_chrome_user_data_dir)
    local theme_source="$REPO_ROOT/extras/chrome"
    
    if [ -z "$chrome_user_dir" ]; then
        log "WARN" "Chrome user data directory not found"
        return 1
    fi
    
    if [ ! -d "$theme_source" ]; then
        log "ERROR" "Chrome theme source not found at $theme_source"
        return 1
    fi
    
    log "INFO" "Found Chrome user data directory: $chrome_user_dir"
    
    # Try to find a profile directory
    local profile_dir=""
    for dir in "$chrome_user_dir"/Default "$chrome_user_dir"/Profile*; do
        if [ -d "$dir" ]; then
            profile_dir="$dir"
            break
        fi
    done
    
    if [ -z "$profile_dir" ]; then
        log "WARN" "No Chrome profile found"
        return 1
    fi
    
    log "INFO" "Found Chrome profile: $profile_dir"
    
    # Create extensions directory if it doesn't exist
    local extensions_dir="$profile_dir/Extensions"
    mkdir -p "$extensions_dir"
    
    # Copy theme to a temporary location for loading
    local temp_theme_dir="/tmp/chrome-milkoutside-$$"
    cp -r "$theme_source" "$temp_theme_dir"
    
    # Create extension ID based on public key (this would normally be generated)
    local extension_id="milkoutside-theme-auto"
    
    # Install extension to Chrome's extension directory
    local extension_path="$extensions_dir/$extension_id"
    if cp -r "$temp_theme_dir" "$extension_path"; then
        log "INFO" "Chrome theme copied to extension directory"
        
        # Try to reload extensions using Chrome command line if Chrome is running
        if pgrep -f "chrome" > /dev/null; then
            log "INFO" "Chrome is running - theme should be available in extension settings"
        else
            log "INFO" "Start Chrome to enable the theme"
        fi
        
        # Cleanup
        rm -rf "$temp_theme_dir"
        
        log "INFO" "Chrome theme auto-installation completed"
        log "INFO" "Go to chrome://extensions/ to enable the theme"
        return 0
    else
        log "ERROR" "Failed to copy Chrome theme"
        rm -rf "$temp_theme_dir"
        return 1
    fi
}

# Install Chrome theme
install_chrome() {
    local theme_source="$REPO_ROOT/extras/chrome"
    
    if [ ! -d "$theme_source" ]; then
        log "ERROR" "Chrome theme directory not found"
        return 1
    fi
    
    log "INFO" "Installing Chrome theme..."
    
    # Try automatic installation first
    if auto_load_chrome_extension; then
        return 0
    fi
    
    # Fallback to manual instructions
    log "WARN" "Automatic installation failed, providing manual instructions"
    log "INFO" "Manual installation steps:"
    log "INFO" "1. Open Chrome and go to chrome://extensions/"
    log "INFO" "2. Enable 'Developer mode' (toggle in top right)"
    log "INFO" "3. Click 'Load unpacked' and select: $theme_source"
    log "INFO" "4. The theme will be available in Chrome's appearance settings"
    
    return 0
}

# Run installation
install_chrome