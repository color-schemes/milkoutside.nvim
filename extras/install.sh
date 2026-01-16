#!/bin/bash

# MilkOutside Extras Installer - Enhanced Version
# Automatically installs and configures MilkOutside themes across all applications

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_D_DIR="$SCRIPT_DIR/install.d"

if [ ! -f "$INSTALL_D_DIR/common.sh" ]; then
    echo "Error: Common utilities not found at $INSTALL_D_DIR/common.sh"
    exit 1
fi

source "$INSTALL_D_DIR/common.sh"

# Function to create backup and install file
install_file() {
    local src="$1"
    local dest="$2"
    local dest_dir=$(dirname "$dest")
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    # Backup existing file if it exists
    if [ -f "$dest" ] || [ -L "$dest" ]; then
        echo -e "${YELLOW}Backing up existing file: $dest${NC}"
        cp -r "$dest" "$BACKUP_DIR/"
    fi
    
    # Copy file
    echo -e "${GREEN}Installing: $dest${NC}"
    cp "$src" "$dest"
}

# Function to create backup and install directory
install_dir() {
    local src="$1"
    local dest="$2"
    
    # Backup existing directory if it exists
    if [ -d "$dest" ]; then
        echo -e "${YELLOW}Backing up existing directory: $dest${NC}"
        cp -r "$dest" "$BACKUP_DIR/"
    fi
    
    # Copy directory
    echo -e "${GREEN}Installing: $dest${NC}"
    cp -r "$src" "$dest"
}

# Function to detect Firefox profile
get_firefox_profile() {
    local firefox_dir="$HOME/.mozilla/firefox"
    if [ -d "$firefox_dir" ]; then
        # Find the default profile
        for profile_dir in "$firefox_dir"/*.default*; do
            if [ -d "$profile_dir" ]; then
                echo "$profile_dir"
                return
            fi
        done
    fi
    echo ""
}

# Function to get app description (cross-platform alternative to associative arrays)
get_app_description() {
    case "$1" in
        "alacritty") echo "Alacritty terminal emulator" ;;
        "aerc") echo "Aerc email client" ;;
        "aider") echo "Aider AI assistant" ;;
        "btop") echo "Btop system monitor" ;;
        "delta") echo "Git delta pager" ;;
        "discord") echo "Discord client" ;;
        "dunst") echo "Dunst notification daemon" ;;
        "eza") echo "Eza file lister" ;;
        "fish") echo "Fish shell" ;;
        "foot") echo "Foot terminal emulator" ;;
        "fuzzel") echo "Fuzzel launcher" ;;
        "fzf") echo "Fuzzy finder" ;;
        "ghostty") echo "Ghostty terminal" ;;
        "gitui") echo "Git UI" ;;
        "helix") echo "Helix editor" ;;
        "ish") echo "iSH shell" ;;
        "iterm") echo "iTerm2 terminal" ;;
        "kitty") echo "Kitty terminal emulator" ;;
        "konsole") echo "Konsole terminal" ;;
        "lazygit") echo "LazyGit UI" ;;
        "nvimtree") echo "NvimTree plugin" ;;
        "neotree") echo "Neo-tree plugin" ;;
        "obsidian") echo "Obsidian note-taking app" ;;
        "opencode") echo "OpenCode AI assistant" ;;
        "process_compose") echo "Process Compose" ;;
        "prism") echo "Prism syntax highlighter" ;;
        "qterminal") echo "QTerminal" ;;
        "slack") echo "Slack client" ;;
     echo "Snacks.nvim plugin" ;;
        "spotify_player") echo "Spotify player" ;;
        "st") echo "Suckless Simple Terminal" ;;
        "sublime") echo "Sublime Text" ;;
        "tailwindv4") echo "Tailwind CSS" ;;
        "termux") echo "Termux terminal" ;;
        "terminator") echo "Terminator terminal" ;;
        "tilix") echo "Tilix terminal" ;;
        "tmux") echo "Tmux terminal multiplexer" ;;
        "vim") echo "Vim editor" ;;
        "vimium") echo "Vimium browser extension" ;;
        "vivaldi") echo "Vivaldi browser" ;;
        "wezterm") echo "WezTerm terminal emulator" ;;
        "windows_terminal") echo "Windows Terminal" ;;
        "xfceterm") echo "XFCE Terminal" ;;
        "xresources") echo "Xresources" ;;
        "yazi") echo "Yazi file manager" ;;
        "zathura") echo "Zathura PDF viewer" ;;
        "zellij") echo "Zellij terminal multiplexer" ;;
        "firefox") echo "Mozilla Firefox" ;;
        "chrome") echo "Google Chrome" ;;
        "safari") echo "Apple Safari" ;;
        "opera") echo "Opera browser" ;;
        "macos") echo "macOS system interface" ;;
        *) echo "Unknown application" ;;
    esac
}

# Available applications list
apps=(
    "alacritty"
    "aerc"
    "aider"
    "btop"
    "delta"
    "discord"
    "dunst"
    "eza"
    "fish"
    "foot"
    "fuzzel"
    "fzf"
    "ghostty"
    "gitui"
    "helix"
    "ish"
    "iterm"
    "kitty"
    "konsole"
    "lazygit"

    "obsidian"
    "opencode"
    "process_compose"
    "prism"
    "qterminal"
    "slack"
    "snacks"
    "spotify_player"
    "st"
    "sublime"
    "tailwindv4"
    "termux"
    "terminator"
    "tilix"
    "tmux"
    "vim"
    "vimium"
    "vivaldi"
    "wezterm"
    "windows_terminal"
    "xfceterm"
    "xresources"
    "yazi"
    "zathura"
    "zellij"
    "firefox"
    "chrome"
    "safari"
    "opera"
    "macos"
    "gnome_terminal"
)

# Application categories
terminal_apps=(
    "alacritty" "kitty" "foot" "ghostty" "iterm" "konsole" "qterminal"
    "terminator" "tilix" "termux" "st" "xfceterm" "wezterm" "windows_terminal"
)

browser_apps=(
    "firefox" "chrome" "safari" "opera" "vivaldi" "vimium"
)

editor_apps=(
    "vim" "helix" "sublime" "nvimtree" "neotree" "snacks"
)

tool_apps=(
    "fish" "tmux" "fzf" "lazygit" "gitui" "yazi" "zellij" "dunst" "fuzzel"
    "btop" "eza" "delta" "xresources" "zathura"
)

other_apps=(
    "discord" "slack" "obsidian" "aider" "process_compose" "prism"
    "opencode" "ish" "aerc" "spotify_player" "tailwindv4" "macos" "gnome_terminal"
)

# Function to list available apps
list_apps() {
    echo -e "${BLUE}Available applications:${NC}"
    echo
    for app in "${apps[@]}"; do
        printf "  ${YELLOW}%-15s${NC} %s\n" "$app" "$(get_app_description "$app")"
    done
    echo
    echo -e "${GREEN}Usage: $0 [app1] [app2] ...${NC}"
    echo -e "${GREEN}       $0 --all${NC} (install all)"
    echo -e "${GREEN}       $0 --list${NC} (show available)"
}

# Install specific app using modular approach
install_app() {
    local app="$1"
    local install_script="$INSTALL_D_DIR/${app}.sh"
    
    # Check if modular install script exists
    if [ -f "$install_script" ]; then
        log "INFO" "Installing $app using modular script"
        if bash "$install_script"; then
            log "INFO" "Successfully installed $app"
            return 0
        else
            log "ERROR" "Failed to install $app"
            return 1
        fi
    else
        log "WARN" "No install script found for $app, trying built-in installation"
        
        # Fallback to built-in installation for backward compatibility
        case "$app" in
            "neovim"|"nvim")
                install_dir "$REPO_ROOT/extras/vim/colors" "$HOME/.config/nvim/colors"
                install_file "$REPO_ROOT/extras/lua/milkoutside.lua" "$HOME/.config/nvim/colors/milkoutside.lua"
                ;;
            *)
                log "WARN" "Unknown application: $app - skipping"
                return 1
                ;;
        esac
    fi
}

# Install all applications
install_all() {
    log "INFO" "Installing all MilkOutside extras..."
    setup_backup
    
    local total=${#apps[@]}
    local current=0
    
    for app in "${apps[@]}"; do
        current=$((current + 1))
        progress $current $total "$app"
        
        if should_install_app "$app"; then
            install_app "$app" || log "WARN" "Failed to install $app (continuing)"
        else
            log "INFO" "Skipping $app (not detected)"
        fi
    done
}

# Install apps by category
install_category() {
    local category="$1"
    local category_apps=()
    
    case "$category" in
        "terminal") category_apps=("${terminal_apps[@]}") ;;
        "browser") category_apps=("${browser_apps[@]}") ;;
        "editor") category_apps=("${editor_apps[@]}") ;;
        "tools") category_apps=("${tool_apps[@]}") ;;
        "other") category_apps=("${other_apps[@]}") ;;
        *) 
            log "ERROR" "Unknown category: $category"
            return 1
            ;;
    esac
    
    log "INFO" "Installing $category applications..."
    setup_backup
    
    local total=${#category_apps[@]}
    local current=0
    
    for app in "${category_apps[@]}"; do
        current=$((current + 1))
        progress $current $total "$app"
        
        if should_install_app "$app"; then
            install_app "$app" || log "WARN" "Failed to install $app (continuing)"
        else
            log "INFO" "Skipping $app (not detected)"
        fi
    done
}

# Enhanced usage information
show_help() {
    echo -e "${BLUE}MilkOutside Extras Installer - Enhanced Version${NC}"
    echo
    echo -e "${GREEN}Usage:${NC}"
    echo "  $0 [options] [applications...]"
    echo
    echo -e "${GREEN}Options:${NC}"
    echo "  -h, --help              Show this help message"
    echo "  -l, --list              List all available applications"
    echo "  -a, --all               Install all detected applications"
    echo "  -c, --category CAT      Install by category (terminal|browser|editor|tools|other)"
    echo "  -i, --interactive       Interactive selection mode"
    echo "  -f, --force             Force install even if app not detected"
    echo "  --rollback              Rollback to previous configuration"
    echo "  --deps                  Install dependencies only"
    echo "  -d, --debug             Enable debug output"
    echo "  --keep-backup           Don't delete backup after successful installation"
    echo
    echo -e "${GREEN}Categories:${NC}"
    echo "  terminal  - Terminal emulators (alacritty, kitty, wezterm, etc.)"
    echo "  browser   - Web browsers (firefox, chrome, safari, etc.)"
    echo "  editor    - Text editors (vim, helix, sublime, etc.)"
    echo "  tools     - CLI tools and utilities (fish, tmux, fzf, etc.)"
    echo "  other     - Other applications (discord, obsidian, etc.)"
    echo
    echo -e "${GREEN}Examples:${NC}"
    echo "  $0 --all                           # Install all detected apps"
    echo "  $0 --category terminal             # Install all terminal emulators"
    echo "  $0 alacritty kitty fish            # Install specific apps"
    echo "  $0 --interactive                    # Select apps interactively"
    echo "  $0 --force firefox                  # Force install firefox theme"
    echo
}

# Main script logic
if [ $# -eq 0 ]; then
    log "ERROR" "No arguments provided."
    show_help
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -l|--list)
            echo -e "${BLUE}Available applications:${NC}"
            echo
            for category in terminal browser editor tools other; do
                echo -e "${CYAN}$category apps:${NC}"
                case $category in
                    terminal) apps_list=("${terminal_apps[@]}") ;;
                    browser) apps_list=("${browser_apps[@]}") ;;
                    editor) apps_list=("${editor_apps[@]}") ;;
                    tools) apps_list=("${tool_apps[@]}") ;;
                    other) apps_list=("${other_apps[@]}") ;;
                esac
                for app in "${apps_list[@]}"; do
                    printf "  ${YELLOW}%-15s${NC} %s\n" "$app" "$(get_app_description "$app")"
                done
                echo
            done
            exit 0
            ;;
        -a|--all)
            ACTION="install_all"
            shift
            ;;
        -c|--category)
            ACTION="install_category"
            CATEGORY="$2"
            shift 2
            ;;
        -i|--interactive)
            ACTION="interactive"
            shift
            ;;
        -f|--force)
            export FORCE_INSTALL=1
            shift
            ;;
        --rollback)
            ACTION="rollback"
            shift
            ;;
        --deps)
            ACTION="install_deps"
            shift
            ;;
        -d|--debug)
            export DEBUG=1
            shift
            ;;
        --keep-backup)
            export KEEP_BACKUP=1
            shift
            ;;
        -*)
            log "ERROR" "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            # It's an application name
            APPS_TO_INSTALL+=("$1")
            shift
            ;;
    esac
done

# Execute action
case "${ACTION:-install_apps}" in
    "install_all")
        install_dependencies || exit 1
        install_all
        ;;
    "install_category")
        install_dependencies || exit 1
        install_category "$CATEGORY"
        ;;
    "install_apps")
        if [ ${#APPS_TO_INSTALL[@]} -eq 0 ]; then
            log "ERROR" "No applications specified."
            show_help
            exit 1
        fi
        install_dependencies || exit 1
        setup_backup
        for app in "${APPS_TO_INSTALL[@]}"; do
            install_app "$app" || log "WARN" "Failed to install $app (continuing)"
        done
        ;;
    "interactive")
        install_dependencies || exit 1
        selected=($(interactive_select "${apps[@]}"))
        if [ ${#selected[@]} -gt 0 ]; then
            setup_backup
            total=${#selected[@]}
            current=0
            for app in "${selected[@]}"; do
                current=$((current + 1))
                progress $current $total "$app"
                install_app "$app" || log "WARN" "Failed to install $app (continuing)"
            done
        else
            log "INFO" "No applications selected."
        fi
        ;;
    "rollback")
        rollback
        ;;
    "install_deps")
        install_dependencies
        ;;
    *)
        log "ERROR" "Unknown action: ${ACTION:-install_apps}"
        show_help
        exit 1
        ;;
esac

log "INFO" "Installation complete!"
log "INFO" "Backups saved to: $BACKUP_DIR"
log "INFO" "Log file: $LOG_FILE"
log "INFO" "You may need to restart applications or reload their configurations."