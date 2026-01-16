#!/bin/bash

# Basic installer for apps without special requirements

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Function to install simple config file
install_simple_config() {
    local app="$1"
    local src_file="$2"
    local dest_file="$3"
    local desc="${4:-$app theme}"
    
    if [ ! -f "$src_file" ]; then
        log "WARN" "Source file not found: $src_file"
        return 1
    fi
    
    local dest_dir=$(dirname "$dest_file")
    mkdir -p "$dest_dir"
    
    install_file "$src_file" "$dest_file" "$desc"
    return $?
}

# Get app from script name
app_name=$(basename "$0" .sh)

case "$app_name" in
    "foot")
        install_simple_config "foot" "$REPO_ROOT/extras/foot/milkoutside.ini" "$HOME/.config/foot/milkoutside.ini"
        ;;
    "fuzzel")
        install_simple_config "fuzzel" "$REPO_ROOT/extras/fuzzel/milkoutside.ini" "$HOME/.config/fuzzel/milkoutside.ini"
        ;;
    "fzf")
        install_simple_config "fzf" "$REPO_ROOT/extras/fzf/milkoutside.sh" "$HOME/.config/fzf/milkoutside.sh"
        ;;
    "yazi")
        install_simple_config "yazi" "$REPO_ROOT/extras/yazi/milkoutside.toml" "$HOME/.config/yazi/theme.toml" "Yazi theme"
        ;;
    "lazygit")
        install_simple_config "lazygit" "$REPO_ROOT/extras/lazygit/milkoutside.yml" "$HOME/.config/lazygit/config.yml" "LazyGit theme"
        ;;
    "dunst")
        mkdir -p "$HOME/.config/dunst/dunstrc.d"
        install_simple_config "dunst" "$REPO_ROOT/extras/dunst/milkoutside.dunstrc" "$HOME/.config/dunst/dunstrc.d/99-milkoutside.conf" "Dunst theme"
        ;;
    "btop")
        install_simple_config "btop" "$REPO_ROOT/extras/btop/milkoutside.theme" "$HOME/.config/btop/themes/milkoutside.theme"
        ;;
    "gitui")
        install_simple_config "gitui" "$REPO_ROOT/extras/gitui/milkoutside.ron" "$HOME/.config/gitui/theme.ron" "GitUI theme"
        ;;
    "helix")
        # Use the dedicated helix script instead
        exec "$SCRIPT_DIR/helix.sh"
        ;;
    "alacritty")
        # Use the dedicated alacritty script instead
        exec "$SCRIPT_DIR/alacritty.sh"
        ;;
    "kitty")
        # Use the dedicated kitty script instead
        exec "$SCRIPT_DIR/kitty.sh"
        ;;
    "wezterm")
        # Use the dedicated wezterm script instead
        exec "$SCRIPT_DIR/wezterm.sh"
        ;;
    "fish")
        # Use the dedicated fish script instead
        exec "$SCRIPT_DIR/fish.sh"
        ;;
    "tmux")
        # Use the dedicated tmux script instead
        exec "$SCRIPT_DIR/tmux.sh"
        ;;
    "vim")
        # Use the dedicated vim script instead
        exec "$SCRIPT_DIR/vim.sh"
        ;;
    "firefox")
        # Use the dedicated firefox script instead
        exec "$SCRIPT_DIR/firefox.sh"
        ;;
    "chrome")
        # Use the dedicated chrome script instead
        exec "$SCRIPT_DIR/chrome.sh"
        ;;
    "discord")
        # Use the dedicated discord script instead
        exec "$SCRIPT_DIR/discord.sh"
        ;;
    "macos")
        # Use the dedicated macos script instead
        exec "$SCRIPT_DIR/macos.sh"
        ;;
    *)
        log "WARN" "No specific installation logic for $app_name"
        # Try to install any matching file from extras directory
        if [ -d "$REPO_ROOT/extras/$app_name" ]; then
            local src_files=($(find "$REPO_ROOT/extras/$app_name" -name "*milkoutside*" -type f))
            for src_file in "${src_files[@]}"; do
                local filename=$(basename "$src_file")
                local dest_file="$HOME/.config/$app_name/$filename"
                install_simple_config "$app_name" "$src_file" "$dest_file"
            done
        else
            log "ERROR" "Unknown application: $app_name"
            exit 1
        fi
        ;;
esac