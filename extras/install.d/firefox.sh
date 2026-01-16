#!/bin/bash

# Firefox theme installer with automatic profile detection

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get Firefox profile directory
get_firefox_profile() {
    local firefox_dir="$HOME/.mozilla/firefox"
    
    if [ ! -d "$firefox_dir" ]; then
        # Try alternative locations
        if [[ "$OS" == "macos" ]]; then
            firefox_dir="$HOME/Library/Application Support/Firefox/Profiles"
        fi
    fi
    
    if [ -d "$firefox_dir" ]; then
        # Look for default profile
        for profile_dir in "$firefox_dir"/*.default* "$firefox_dir"/*default*; do
            if [ -d "$profile_dir" ]; then
                echo "$profile_dir"
                return
            fi
        done
        
        # If no default found, use the first directory
        for profile_dir in "$firefox_dir"/*; do
            if [ -d "$profile_dir" ] && [[ ! "$(basename "$profile_dir")" =~ ^(crashreports|profiles|profile) ]]; then
                echo "$profile_dir"
                return
            fi
        done
    fi
    
    echo ""
}

# Install Firefox theme
install_firefox() {
    local theme_file="$REPO_ROOT/extras/firefox/userChrome.css"
    
    if [ ! -f "$theme_file" ]; then
        log "ERROR" "Firefox theme file not found"
        return 1
    fi
    
    local firefox_profile=$(get_firefox_profile)
    
    if [ -z "$firefox_profile" ]; then
        log "ERROR" "Firefox profile not found. Make sure Firefox is installed and has been run at least once."
        return 1
    fi
    
    log "INFO" "Found Firefox profile: $firefox_profile"
    
    local chrome_dir="$firefox_profile/chrome"
    mkdir -p "$chrome_dir"
    
    # Install userChrome.css
    if install_file "$theme_file" "$chrome_dir/userChrome.css" "Firefox theme"; then
        # Check if user.js exists and enable legacy userProfileCustomizations
        local userjs_file="$firefox_profile/user.js"
        if [ ! -f "$userjs_file" ]; then
            log "INFO" "Creating user.js to enable custom stylesheets"
            cat > "$userjs_file" << 'EOF'
// Firefox user preferences
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("layout.css.color-mix.enabled", true);
EOF
        else
            if ! grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$userjs_file"; then
                log "INFO" "Adding custom stylesheet preference to user.js"
                echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$userjs_file"
            fi
        fi
        
        log "INFO" "Firefox theme installed successfully"
        log "INFO" "Restart Firefox to see changes"
        return 0
    else
        return 1
    fi
}

# Auto-install BetterDiscord integration if available
auto_install_betterdiscord_firefox() {
    if command_exists "firefox"; then
        # Check if Firefox WebExtension for BetterDiscord exists
        local firefox_extension_dir="$firefox_profile/extensions"
        if [ -d "$firefox_extension_dir" ]; then
            log "INFO" "Firefox extension directory found"
        fi
    fi
}

# Run installation
install_firefox