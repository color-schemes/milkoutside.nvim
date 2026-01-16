#!/bin/bash

# MilkOutside macOS Browser Theme Installer
# Specialized installer for macOS browsers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}This script is designed for macOS only${NC}"
        exit 1
    fi
}

# Create backup directory
BACKUP_DIR="$HOME/.config/milkoutside-macos-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Function to detect installed browsers
detect_browsers() {
    local browsers=()
    
    # Check for Firefox
    if [ -d "/Applications/Firefox.app" ] || command -v firefox &>/dev/null; then
        browsers+=("firefox")
    fi
    
    # Check for Chrome
    if [ -d "/Applications/Google Chrome.app" ] || [ -d "/Applications/Chrome.app" ]; then
        browsers+=("chrome")
    fi
    
    # Check for Safari (always present on macOS)
    browsers+=("safari")
    
    # Check for Opera
    if [ -d "/Applications/Opera.app" ]; then
        browsers+=("opera")
    fi
    
    echo "${browsers[@]}"
}

# Function to install Firefox theme
install_firefox() {
    echo -e "${BLUE}Installing Firefox theme...${NC}"
    
    local firefox_profile="$HOME/.mozilla/firefox"
    if [ -d "$firefox_profile" ]; then
        # Find default profile
        for profile_dir in "$firefox_profile"/*.default*; do
            if [ -d "$profile_dir" ]; then
                local chrome_dir="$profile_dir/chrome"
                mkdir -p "$chrome_dir"
                
                # Backup existing
                if [ -f "$chrome_dir/userChrome.css" ]; then
                    echo -e "${YELLOW}Backing up existing Firefox theme${NC}"
                    cp "$chrome_dir/userChrome.css" "$BACKUP_DIR/"
                fi
                
                cp "$REPO_ROOT/extras/firefox/userChrome.css" "$chrome_dir/userChrome.css"
                echo -e "${GREEN}✓ Firefox theme installed${NC}"
                
                # Enable legacy profile customizations
                echo -e "${YELLOW}Note: You need to enable toolkit.legacyUserProfileCustomizations.stylesheets in about:config${NC}"
                echo -e "${BLUE}Open Firefox, go to about:config, search for 'toolkit.legacyUserProfileCustomizations.stylesheets' and set to true${NC}"
                return
            fi
        done
        
        echo -e "${RED}No Firefox profile found. Please run Firefox first to create profile.${NC}"
    else
        echo -e "${RED}Firefox not found${NC}"
    fi
}

# Function to install Chrome theme
install_chrome() {
    echo -e "${BLUE}Installing Chrome theme...${NC}"
    
    # Check if Chrome is installed
    if [ -d "/Applications/Google Chrome.app" ] || [ -d "/Applications/Chrome.app" ]; then
        echo -e "${YELLOW}Chrome theme requires manual installation${NC}"
        echo -e "${GREEN}Follow these steps:${NC}"
        echo
        echo -e "${BLUE}1. Open Chrome browser${NC}"
        echo -e "${BLUE}2. Navigate to: chrome://extensions/${NC}"
        echo -e "${BLUE}3. Enable 'Developer mode' (toggle in top right corner)${NC}"
        echo -e "${BLUE}4. Click 'Load unpacked' button${NC}"
        echo -e "${BLUE}5. Navigate to and select: $REPO_ROOT/extras/chrome${NC}"
        echo -e "${BLUE}6. Go to Chrome Settings > Appearance and select 'MilkOutside'${NC}"
        echo
        echo -e "${GREEN}Chrome theme files are ready at: $REPO_ROOT/extras/chrome${NC}"
        
        # Try to open Chrome automatically
        open -a "Google Chrome" "chrome://extensions/"
    else
        echo -e "${RED}Chrome not found${NC}"
    fi
}

# Function to install Safari theme
install_safari() {
    echo -e "${BLUE}Installing Safari theme...${NC}"
    
    # Safari requires developer menu to be enabled
    echo -e "${YELLOW}Safari theme requires developer features${NC}"
    echo -e "${GREEN}Follow these steps:${NC}"
    echo
    echo -e "${BLUE}1. Open Safari${NC}"
    echo -e "${BLUE}2. Go to Safari > Preferences > Advanced${NC}"
    echo -e "${BLUE}3. Check 'Show Develop menu in menu bar'${NC}"
    echo -e "${BLUE}4. Go to Develop > Allow Unsigned Extensions${NC}"
    echo -e "${BLUE}5. Build the extension:${NC}"
    echo -e "${CYAN}   cd '$REPO_ROOT/extras/safari'${NC}"
    echo -e "${CYAN}   xcrun safari-web-extension-converter .${NC}"
    echo -e "${BLUE}6. Go to Safari > Preferences > Extensions and enable MilkOutside${NC}"
    echo
    echo -e "${GREEN}Safari theme files are ready at: $REPO_ROOT/extras/safari${NC}"
    
    # Try to open Safari preferences
    open -a Safari "x-safari://preferences/extensions"
}

# Function to install Opera theme
install_opera() {
    echo -e "${BLUE}Installing Opera theme...${NC}"
    
    if [ -d "/Applications/Opera.app" ]; then
        echo -e "${YELLOW}Opera theme requires manual installation${NC}"
        echo -e "${GREEN}Follow these steps:${NC}"
        echo
        echo -e "${BLUE}1. Open Opera browser${NC}"
        echo -e "${BLUE}2. Navigate to: opera://extensions/${NC}"
        echo -e "${BLUE}3. Enable 'Developer mode' (toggle in top left corner)${NC}"
        echo -e "${BLUE}4. Click 'Load unpacked' button${NC}"
        echo -e "${BLUE}5. Navigate to and select: $REPO_ROOT/extras/opera${NC}"
        echo -e "${BLUE}6. Use the MilkOutside icon in toolbar to toggle theme${NC}"
        echo
        echo -e "${GREEN}Opera theme files are ready at: $REPO_ROOT/extras/opera${NC}"
        
        # Try to open Opera automatically
        open -a Opera "opera://extensions/"
    else
        echo -e "${RED}Opera not found${NC}"
    fi
}

# Function to show menu
show_menu() {
    local browsers=($(detect_browsers))
    
    echo -e "${GREEN}MilkOutside macOS Browser Theme Installer${NC}"
    echo
    echo -e "${BLUE}Detected browsers:${NC}"
    echo
    
    local i=1
    for browser in "${browsers[@]}"; do
        case "$browser" in
            "firefox") echo -e "  ${YELLOW}$i) Firefox${NC}" ;;
            "chrome") echo -e "  ${YELLOW}$i) Google Chrome${NC}" ;;
            "safari") echo -e "  ${YELLOW}$i) Safari${NC}" ;;
            "opera") echo -e "  ${YELLOW}$i) Opera${NC}" ;;
        esac
        ((i++))
    done
    
    echo
    echo -e "${BLUE}a) Install all detected browsers${NC}"
    echo -e "${BLUE}q) Quit${NC}"
    echo
    echo -ne "${GREEN}Select browser to install (1-${#browsers[@]}): ${NC}"
}

# Function to install all browsers
install_all() {
    local browsers=($(detect_browsers))
    
    echo -e "${BLUE}Installing all detected browser themes...${NC}"
    echo
    
    for browser in "${browsers[@]}"; do
        echo -e "${YELLOW}Installing $browser...${NC}"
        case "$browser" in
            "firefox") install_firefox ;;
            "chrome") install_chrome ;;
            "safari") install_safari ;;
            "opera") install_opera ;;
        esac
        echo
    done
}

# Main installer function
main() {
    check_macos
    
    # Parse command line arguments
    if [ $# -eq 1 ]; then
        case "$1" in
            "firefox") install_firefox ;;
            "chrome") install_chrome ;;
            "safari") install_safari ;;
            "opera") install_opera ;;
            "all") install_all ;;
            *) 
                echo -e "${RED}Unknown browser: $1${NC}"
                exit 1
                ;;
        esac
    else
        # Interactive mode
        show_menu
        read -r choice
        
        case "$choice" in
            1) 
                local browsers=($(detect_browsers))
                install_${browsers[0]}
                ;;
            2) 
                if [ ${#browsers[@]} -ge 2 ]; then
                    local browsers=($(detect_browsers))
                    install_${browsers[1]}
                else
                    echo -e "${RED}Invalid choice${NC}"
                fi
                ;;
            3) 
                if [ ${#browsers[@]} -ge 3 ]; then
                    local browsers=($(detect_browsers))
                    install_${browsers[2]}
                else
                    echo -e "${RED}Invalid choice${NC}"
                fi
                ;;
            4) 
                if [ ${#browsers[@]} -ge 4 ]; then
                    local browsers=($(detect_browsers))
                    install_${browsers[3]}
                else
                    echo -e "${RED}Invalid choice${NC}"
                fi
                ;;
            "a"|"A") install_all ;;
            "q"|"Q") exit 0 ;;
            *) echo -e "${RED}Invalid choice${NC}" ;;
        esac
    fi
    
    echo
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${BLUE}Backups saved to: $BACKUP_DIR${NC}"
    echo -e "${YELLOW}You may need to restart browsers to apply themes.${NC}"
}

# Run main function
main "$@"