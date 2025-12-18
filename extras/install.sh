#!/bin/bash

# MilkOutside Extras Installer
# Installs all extra themes to their respective config directories

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

# Create backup directory
BACKUP_DIR="$HOME/.config/milkoutside-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

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

# Available applications
declare -A apps=(
    ["alacritty"]="Alacritty terminal emulator"
    ["aerc"]="Aerc email client"
    ["aider"]="Aider AI assistant"
    ["btop"]="Btop system monitor"
    ["delta"]="Git delta pager"
    ["discord"]="Discord client"
    ["dunst"]="Dunst notification daemon"
    ["eza"]="Eza file lister"
    ["fish"]="Fish shell"
    ["foot"]="Foot terminal emulator"
    ["fuzzel"]="Fuzzel launcher"
    ["fzf"]="Fuzzy finder"
    ["ghostty"]="Ghostty terminal"
    ["gitui"]="Git UI"
    ["helix"]="Helix editor"
    ["ish"]="iSH shell"
    ["iterm"]="iTerm2 terminal"
    ["kitty"]="Kitty terminal emulator"
    ["konsole"]="Konsole terminal"
    ["lazygit"]="LazyGit UI"
    ["nvimtree"]="NvimTree plugin"
    ["neotree"]="Neo-tree plugin"
    ["opencode"]="OpenCode AI assistant"
    ["process_compose"]="Process Compose"
    ["prism"]="Prism syntax highlighter"
    ["qterminal"]="QTerminal"
    ["slack"]="Slack client"
    ["snacks"]="Snacks.nvim plugin"
    ["spotify_player"]="Spotify player"
    ["st"]="Suckless Simple Terminal"
    ["sublime"]="Sublime Text"
    ["tailwindv4"]="Tailwind CSS"
    ["termux"]="Termux terminal"
    ["terminator"]="Terminator terminal"
    ["tilix"]="Tilix terminal"
    ["tmux"]="Tmux terminal multiplexer"
    ["vim"]="Vim editor"
    ["vimium"]="Vimium browser extension"
    ["vivaldi"]="Vivaldi browser"
    ["wezterm"]="WezTerm terminal emulator"
    ["windows_terminal"]="Windows Terminal"
    ["xfceterm"]="XFCE Terminal"
    ["xresources"]="Xresources"
    ["yazi"]="Yazi file manager"
    ["zathura"]="Zathura PDF viewer"
    ["zellij"]="Zellij terminal multiplexer"
    ["firefox"]="Mozilla Firefox"
)

# Function to list available apps
list_apps() {
    echo -e "${BLUE}Available applications:${NC}"
    echo
    for app in "${!apps[@]}"; do
        printf "  ${YELLOW}%-15s${NC} %s\n" "$app" "${apps[$app]}"
    done
    echo
    echo -e "${GREEN}Usage: $0 [app1] [app2] ...${NC}"
    echo -e "${GREEN}       $0 --all${NC} (install all)"
    echo -e "${GREEN}       $0 --list${NC} (show available)"
}

# Install specific app
install_app() {
    local app="$1"
    
    case "$app" in
        "alacritty")
            install_file "$REPO_ROOT/extras/alacritty/milkoutside.toml" "$HOME/.config/alacritty/milkoutside.toml"
            ;;
        "kitty")
            install_file "$REPO_ROOT/extras/kitty/milkoutside.conf" "$HOME/.config/kitty/milkoutside.conf"
            ;;
        "fish")
            install_file "$REPO_ROOT/extras/fish/milkoutside.fish" "$HOME/.config/fish/functions/_fish_prompt_milkoutside.fish"
            mkdir -p "$HOME/.config/fish/themes"
            install_file "$REPO_ROOT/extras/fish_themes/milkoutside.theme" "$HOME/.config/fish/themes/MilkOutside.theme"
            ;;
        "wezterm")
            install_file "$REPO_ROOT/extras/wezterm/milkoutside.toml" "$HOME/.config/wezterm/milkoutside.toml"
            ;;
        "firefox")
            local firefox_profile=$(get_firefox_profile)
            if [ -n "$firefox_profile" ]; then
                local chrome_dir="$firefox_profile/chrome"
                mkdir -p "$chrome_dir"
                install_file "$REPO_ROOT/extras/firefox/userChrome.css" "$chrome_dir/userChrome.css"
                echo -e "${YELLOW}Note: Enable toolkit.legacyUserProfileCustomizations.stylesheets in about:config${NC}"
            else
                echo -e "${RED}Firefox profile not found. Make sure Firefox is installed and has been run at least once.${NC}"
            fi
            ;;
        "tmux")
            install_file "$REPO_ROOT/extras/tmux/milkoutside.tmux" "$HOME/.config/tmux/milkoutside.tmux"
            ;;
        "dunst")
            mkdir -p "$HOME/.config/dunst/dunstrc.d"
            install_file "$REPO_ROOT/extras/dunst/milkoutside.dunstrc" "$HOME/.config/dunst/dunstrc.d/99-milkoutside.conf"
            ;;
        "yazi")
            install_file "$REPO_ROOT/extras/yazi/milkoutside.toml" "$HOME/.config/yazi/theme.toml"
            ;;
        "helix")
            install_file "$REPO_ROOT/extras/helix/milkoutside.toml" "$HOME/.config/helix/themes/milkoutside.toml"
            ;;
        "foot")
            install_file "$REPO_ROOT/extras/foot/milkoutside.ini" "$HOME/.config/foot/milkoutside.ini"
            ;;
        "fuzzel")
            install_file "$REPO_ROOT/extras/fuzzel/milkoutside.ini" "$HOME/.config/fuzzel/milkoutside.ini"
            ;;
        "fzf")
            install_file "$REPO_ROOT/extras/fzf/milkoutside.sh" "$HOME/.config/fzf/milkoutside.sh"
            ;;
        "neovim"|"nvim")
            install_dir "$REPO_ROOT/extras/vim/colors" "$HOME/.config/nvim/colors"
            install_file "$REPO_ROOT/extras/lua/milkoutside.lua" "$HOME/.config/nvim/colors/milkoutside.lua"
            ;;
        "vim")
            install_dir "$REPO_ROOT/extras/vim/colors" "$HOME/.vim/colors"
            ;;
        "lazygit")
            install_file "$REPO_ROOT/extras/lazygit/milkoutside.yml" "$HOME/.config/lazygit/config.yml"
            ;;
        "opencode")
            install_file "$REPO_ROOT/extras/opencode/milkoutside.json" "$HOME/.config/opencode/themes/milkoutside.json"
            ;;
        "windows_terminal")
            echo -e "${YELLOW}Windows Terminal config must be added manually${NC}"
            echo -e "${BLUE}Copy the contents of extras/windows_terminal/milkoutside.json to your Windows Terminal schemes${NC}"
            ;;
        *)
            echo -e "${YELLOW}Unknown application: $app - skipping${NC}"
            ;;
    esac
}

# Install all applications
install_all() {
    echo -e "${BLUE}Installing all MilkOutside extras...${NC}"
    
    # Get all available apps from the apps array
    all_apps=("${!apps[@]}")
    
        for app in "${all_apps[@]}"; do
            # Skip apps that need manual installation or special handling
            if [ "$app" = "windows_terminal" ]; then
                echo -e "${YELLOW}Skipping $app (requires manual installation)${NC}"
                continue
            fi
            
            # For special apps, check if they're available or if their config dirs exist
            if [ "$app" = "firefox" ]; then
                if command -v firefox &> /dev/null; then
                    install_app "$app" || true
                else
                    echo -e "${YELLOW}Skipping $app (not detected)${NC}"
                fi
            elif [ "$app" = "nvimtree" ] || [ "$app" = "neotree" ] || [ "$app" = "snacks" ]; then
                # These are neovim plugins, install if neovim config exists
                if [ -d "$HOME/.config/nvim" ]; then
                    install_app "$app" || true
                else
                    echo -e "${YELLOW}Skipping $app (neovim config not found)${NC}"
                fi
            else
                # For regular apps, check if command exists or config directory exists
                if command -v "$app" &> /dev/null || [ -d "$HOME/.config/$app" ] || [ "$app" = "fish" ] || [ "$app" = "tmux" ]; then
                    install_app "$app" || true
                else
                    echo -e "${YELLOW}Skipping $app (not detected)${NC}"
                fi
            fi
        done
}

# Main script logic
if [ $# -eq 0 ]; then
    echo -e "${RED}No arguments provided.${NC}"
    list_apps
    exit 1
fi

case "$1" in
    "--list"|"-l")
        list_apps
        ;;
    "--all"|"-a")
        install_all
        ;;
    "--help"|"-h")
        echo -e "${BLUE}MilkOutside Extras Installer${NC}"
        echo
        list_apps
        ;;
    *)
        echo -e "${BLUE}Installing selected applications...${NC}"
        for app in "$@"; do
            install_app "$app" || true  # Continue even if individual app fails
        done
        ;;
esac

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Backups saved to: $BACKUP_DIR${NC}"
echo -e "${BLUE}You may need to restart applications or reload their configs.${NC}"