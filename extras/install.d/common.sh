#!/bin/bash

# Common utility functions for MilkOutside installer

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export NC='\033[0m' # No Color

# Global variables
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
export BACKUP_DIR="$HOME/.config/milkoutside-backup-$(date +%Y%m%d-%H%M%S)"
export LOG_FILE="/tmp/milkoutside-install.log"

# OS Detection
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

export OS=$(detect_os)

# Progress indicator
progress() {
    local current=$1
    local total=$2
    local desc=$3
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r${CYAN}[%3d%%]${NC} [" "$percent"
    printf "%*s" $filled | tr ' ' '='
    printf "%*s" $empty | tr ' ' '-'
    printf "] %s" "$desc"
    
    if [ $current -eq $total ]; then
        printf "\n"
    fi
}

# Logging
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "INFO")  echo -e "${GREEN}[INFO]${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
        "DEBUG") [[ "${DEBUG:-0}" == "1" ]] && echo -e "${BLUE}[DEBUG]${NC} $message" ;;
    esac
}

# Create backup directory
setup_backup() {
    mkdir -p "$BACKUP_DIR"
    log "INFO" "Created backup directory: $BACKUP_DIR"
}

# Function to create backup and install file
install_file() {
    local src="$1"
    local dest="$2"
    local desc="${3:-Installing file}"
    local dest_dir=$(dirname "$dest")
    
    log "INFO" "$desc: $dest"
    
    # Create destination directory if it doesn't exist
    if ! mkdir -p "$dest_dir" 2>/dev/null; then
        log "ERROR" "Failed to create directory: $dest_dir"
        return 1
    fi
    
    # Backup existing file if it exists
    if [ -f "$dest" ] || [ -L "$dest" ]; then
        local backup_path="$BACKUP_DIR/$(basename "$dest")-$(date +%H%M%S)"
        mkdir -p "$(dirname "$backup_path")"
        cp -r "$dest" "$backup_path" && log "INFO" "Backed up existing file: $dest"
    fi
    
    # Copy file
    if cp "$src" "$dest" 2>/dev/null; then
        log "INFO" "Successfully installed: $dest"
        return 0
    else
        log "ERROR" "Failed to install: $dest"
        return 1
    fi
}

# Function to create backup and install directory
install_dir() {
    local src="$1"
    local dest="$2"
    local desc="${3:-Installing directory}"
    
    log "INFO" "$desc: $dest"
    
    # Backup existing directory if it exists
    if [ -d "$dest" ]; then
        local backup_path="$BACKUP_DIR/$(basename "$dest")-$(date +%H%M%S)"
        mkdir -p "$(dirname "$backup_path")"
        cp -r "$dest" "$backup_path" && log "INFO" "Backed up existing directory: $dest"
    fi
    
    # Copy directory
    if cp -r "$src" "$dest" 2>/dev/null; then
        log "INFO" "Successfully installed: $dest"
        return 0
    else
        log "ERROR" "Failed to install: $dest"
        return 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if config directory exists
config_exists() {
    local app="$1"
    [ -d "$HOME/.config/$app" ]
}

# Get app description
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
        "snacks") echo "Snacks.nvim plugin" ;;
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

# Check if app should be installed
should_install_app() {
    local app="$1"
    
    # Always install if explicitly requested
    if [[ "${FORCE_INSTALL:-0}" == "1" ]]; then
        return 0
    fi
    
    # Check if app exists or config exists
    case "$app" in
        "firefox")
            command_exists "firefox" || [ -d "$HOME/.mozilla/firefox" ]
            ;;
        "chrome" | "chromium")
            command_exists "google-chrome" || command_exists "chromium" || command_exists "chrome" || \
            [ -d "$HOME/.config/google-chrome" ] || [ -d "$HOME/.config/chromium" ]
            ;;
        "safari")
            [[ "$OS" == "macos" ]] && command_exists "safari"
            ;;
        "opera")
            command_exists "opera" || [ -d "$HOME/.config/opera" ]
            ;;
        "discord")
            command_exists "discord" || command_exists "Discord" || [ -d "/Applications/Discord.app" ] || \
            [ -d "$HOME/.config/discord" ] || [ -d "$HOME/.config/BetterDiscord" ]
            ;;
        "macos")
            [[ "$OS" == "macos" ]]
            ;;
        "windows_terminal")
            [[ "$OS" == "windows" ]]
            ;;
        "fish")
            command_exists "fish"
            ;;
        "nvimtree" | "neotree" | "snacks")
            [ -d "$HOME/.config/nvim" ]
            ;;
        *)
            command_exists "$app" || config_exists "$app"
            ;;
    esac
}

# Install dependencies
install_dependencies() {
    local missing_deps=()
    
    # Check for common dependencies
    if ! command_exists "curl"; then
        missing_deps+=("curl")
    fi
    
    if ! command_exists "git"; then
        missing_deps+=("git")
    fi
    
    if [[ "$OS" == "linux" ]]; then
        if ! command_exists "wget"; then
            missing_deps+=("wget")
        fi
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log "WARN" "Missing dependencies: ${missing_deps[*]}"
        
        case "$OS" in
            "macos")
                if command_exists "brew"; then
                    log "INFO" "Installing missing dependencies with Homebrew..."
                    brew install "${missing_deps[@]}"
                else
                    log "ERROR" "Please install Homebrew first: https://brew.sh"
                    return 1
                fi
                ;;
            "linux")
                if command_exists "apt"; then
                    log "INFO" "Installing missing dependencies with apt..."
                    sudo apt update && sudo apt install -y "${missing_deps[@]}"
                elif command_exists "pacman"; then
                    log "INFO" "Installing missing dependencies with pacman..."
                    sudo pacman -S --noconfirm "${missing_deps[@]}"
                elif command_exists "dnf"; then
                    log "INFO" "Installing missing dependencies with dnf..."
                    sudo dnf install -y "${missing_deps[@]}"
                else
                    log "ERROR" "Please install missing dependencies manually: ${missing_deps[*]}"
                    return 1
                fi
                ;;
            *)
                log "ERROR" "Please install missing dependencies manually: ${missing_deps[*]}"
                return 1
                ;;
        esac
    fi
    
    return 0
}

# Interactive selection
interactive_select() {
    local available_apps=("$@")
    local selected_apps=()
    
    echo -e "${BLUE}Select applications to install (space to toggle, enter to confirm):${NC}"
    echo
    
    for i in "${!available_apps[@]}"; do
        local app="${available_apps[i]}"
        printf "%2d. ${YELLOW}%-15s${NC} %s\n" $((i+1)) "$app" "$(get_app_description "$app")"
    done
    
    echo
    read -p "Enter numbers (e.g., 1 3 5) or 'all': " selection
    
    if [[ "$selection" == "all" ]]; then
        selected_apps=("${available_apps[@]}")
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#available_apps[@]}" ]; then
                selected_apps+=("${available_apps[$((num-1))]}")
            fi
        done
    fi
    
    printf '%s\n' "${selected_apps[@]}"
}

# Rollback function
rollback() {
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        log "INFO" "Rolling back changes from: $BACKUP_DIR"
        
        for backup_file in "$BACKUP_DIR"/*; do
            local original_name=$(basename "$backup_file" | sed 's/-[0-9]\{6\}$//')
            local restore_path="$HOME/.config/$original_name"
            
            if [ -f "$backup_file" ]; then
                cp "$backup_file" "$restore_path" && log "INFO" "Restored: $restore_path"
            elif [ -d "$backup_file" ]; then
                rm -rf "$restore_path" && cp -r "$backup_file" "$restore_path" && log "INFO" "Restored: $restore_path"
            fi
        done
        
        log "INFO" "Rollback completed"
    else
        log "WARN" "No backup found to rollback from"
    fi
}

# Cleanup function
cleanup() {
    if [[ "${KEEP_BACKUP:-0}" != "1" ]] && [ -d "$BACKUP_DIR" ]; then
        log "INFO" "Cleaning up backup directory: $BACKUP_DIR"
        rm -rf "$BACKUP_DIR"
    fi
}

# Set up signal handlers
trap cleanup EXIT