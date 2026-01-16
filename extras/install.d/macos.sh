#!/bin/bash

# macOS system theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Check if running on macOS
if [[ "$OS" != "macos" ]]; then
    log "ERROR" "macOS theme can only be applied on macOS"
    exit 1
fi

# Install macOS theme
install_macos() {
    local macos_theme_dir="$REPO_ROOT/extras/macos"
    
    if [ ! -d "$macos_theme_dir" ]; then
        log "ERROR" "macOS theme directory not found"
        return 1
    fi
    
    # Check for existing macOS theme installer
    if [ -f "$macos_theme_dir/install.sh" ]; then
        log "INFO" "Running macOS theme installer"
        chmod +x "$macos_theme_dir/install.sh"
        "$macos_theme_dir/install.sh"
        return $?
    fi
    
    # Install terminal.app theme if available
    if [ -f "$macos_theme_dir/MilkOutside.terminal" ]; then
        log "INFO" "Installing Terminal.app theme"
        
        # Import terminal theme
        local result=$(osascript -e "tell application \"Terminal\" to set custom title of front window to \"MilkOutside\"" 2>/dev/null)
        
        # Copy theme to Terminal's plist
        local terminal_plist="$HOME/Library/Preferences/com.apple.Terminal.plist"
        if [ -f "$terminal_plist" ]; then
            log "INFO" "Terminal theme would be imported manually"
            log "INFO" "Open Terminal.app > Preferences > Profiles > Import and select:"
            log "INFO" "$macos_theme_dir/MilkOutside.terminal"
        fi
    fi
    
    # Install system accent color if supported
    if command_exists "defaults"; then
        log "INFO" "Setting system appearance to Dark mode"
        defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
        
        log "INFO" "Setting highlight color to Graphite (matches MilkOutside)"
        defaults write NSGlobalDomain AppleHighlightColor -string "0.968627 0.631373 0.627451 Graphite"
        
        log "INFO" "Setting sidebar icon size to medium"
        defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
    fi
    
    # Install Safari theme if available
    if [ -d "$macos_theme_dir/safari" ]; then
        log "INFO" "Safari theme found - would require manual extension installation"
        log "INFO" "Enable Safari Developer menu and load extension from: $macos_theme_dir/safari"
    fi
    
    log "INFO" "macOS theme installation completed"
    log "INFO" "You may need to restart some applications to see all changes"
    log "INFO" "For Terminal.app: Terminal > Preferences > Profiles > Import > Select MilkOutside.terminal"
    
    return 0
}

# Run installation
install_macos