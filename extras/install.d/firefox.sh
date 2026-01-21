#!/bin/bash

# Firefox theme installer with automatic profile detection

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get all Firefox profile directories
get_firefox_profiles() {
    local firefox_dir=""
    local profiles=()
    
    # Try different locations based on OS
    if [[ "$OS" == "macos" ]]; then
        # macOS Firefox profile locations - check both possible locations
        firefox_dir="$HOME/Library/Application Support/Firefox/Profiles"
        if [ ! -d "$firefox_dir" ]; then
            firefox_dir="$HOME/Library/Mozilla/Firefox/Profiles"
        fi
    else
        # Linux/Unix Firefox profile locations
        firefox_dir="$HOME/.mozilla/firefox"
    fi
    
    if [ -d "$firefox_dir" ]; then
        # Find all valid profile directories (must contain profile files)
        for profile_dir in "$firefox_dir"/*; do
            if [ -d "$profile_dir" ]; then
                local profile_name=$(basename "$profile_dir")
                # Only include directories that look like Firefox profiles (contain .default or .release in name)
                if [[ "$profile_name" =~ (\.default|\.release) ]] && [[ ! "$profile_name" =~ ^(crashreports|profiles|profile|Pending Installs|\.DS_Store) ]]; then
                    # Check if this looks like a real Firefox profile (has required files)
                    if [ -f "$profile_dir/prefs.js" ] || [ -f "$profile_dir/times.json" ]; then
                        profiles+=("$profile_dir")
                    fi
                fi
            fi
        done
    fi
    
    # Return the profiles array
    printf '%s\n' "${profiles[@]}"
}

# Get Firefox profile directory (for backward compatibility)
get_firefox_profile() {
    local profiles=()
while IFS= read -r line; do
    profiles+=("$line")
done < <(get_firefox_profiles)
    if [ ${#profiles[@]} -gt 0 ]; then
        echo "${profiles[0]}"
    else
        echo ""
    fi
}

# Install Firefox theme to all profiles
install_firefox() {
    local theme_file="$REPO_ROOT/extras/firefox/userChrome.css"
    
    if [ ! -f "$theme_file" ]; then
        log "ERROR" "Firefox theme file not found"
        return 1
    fi
    
    local firefox_profiles=()
while IFS= read -r line; do
    firefox_profiles+=("$line")
done < <(get_firefox_profiles)
    
    
    if [ ${#firefox_profiles[@]} -eq 0 ]; then
        log "ERROR" "Firefox profiles not found. Make sure Firefox is installed and has been run at least once."
        return 1
    fi
    
    log "INFO" "Found ${#firefox_profiles[@]} Firefox profile(s)"
    
    local success_count=0
    local total_count=${#firefox_profiles[@]}
    
    for firefox_profile in "${firefox_profiles[@]}"; do
        local profile_name=$(basename "$firefox_profile")
        log "INFO" "Installing to profile: $profile_name"
        
        local chrome_dir="$firefox_profile/chrome"
        mkdir -p "$chrome_dir"
        
        # Install userChrome.css
        if install_file "$theme_file" "$chrome_dir/userChrome.css" "Firefox theme for $profile_name"; then
            # Check if user.js exists and enable legacy userProfileCustomizations
            local userjs_file="$firefox_profile/user.js"
            if [ ! -f "$userjs_file" ]; then
                log "INFO" "Creating user.js to enable custom stylesheets for $profile_name"
                cat > "$userjs_file" << 'EOF'
// Firefox user preferences for MilkOutside theme
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("layout.css.color-mix.enabled", true);
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 0);
user_pref("ui.systemUsesDarkTheme", 1);
EOF
            else
                # Add required preferences if they don't exist
                local prefs=(
                    "toolkit.legacyUserProfileCustomizations.stylesheets"
                    "svg.context-properties.content.enabled"
                    "layout.css.color-mix.enabled"
                    "browser.compactmode.show"
                    "browser.uidensity"
                    "ui.systemUsesDarkTheme"
                )
                for pref in "${prefs[@]}"; do
                    if ! grep -q "$pref" "$userjs_file"; then
                        case "$pref" in
                            "toolkit.legacyUserProfileCustomizations.stylesheets") echo "user_pref(\"$pref\", true);" >> "$userjs_file" ;;
                            "svg.context-properties.content.enabled") echo "user_pref(\"$pref\", true);" >> "$userjs_file" ;;
                            "layout.css.color-mix.enabled") echo "user_pref(\"$pref\", true);" >> "$userjs_file" ;;
                            "browser.compactmode.show") echo "user_pref(\"$pref\", true);" >> "$userjs_file" ;;
                            "browser.uidensity") echo "user_pref(\"$pref\", 0);" >> "$userjs_file" ;;
                            "ui.systemUsesDarkTheme") echo "user_pref(\"$pref\", 1);" >> "$userjs_file" ;;
                        esac
                    fi
                done
            fi
            
            success_count=$((success_count + 1))
            log "INFO" "Successfully installed theme to profile: $profile_name"
        else
            log "ERROR" "Failed to install theme to profile: $profile_name"
        fi
    done
    
    if [ $success_count -eq $total_count ]; then
        log "INFO" "Firefox theme installed successfully to all $total_count profile(s)"
        log "INFO" "Restart Firefox to see changes"
        return 0
    elif [ $success_count -gt 0 ]; then
        log "WARN" "Firefox theme installed to $success_count of $total_count profile(s)"
        log "INFO" "Restart Firefox to see changes"
        return 0
    else
        log "ERROR" "Failed to install Firefox theme to any profile"
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