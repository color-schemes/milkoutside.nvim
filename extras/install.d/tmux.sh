#!/bin/bash

# Tmux theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install Tmux theme
install_tmux() {
    local tmux_config_dir="$HOME/.config/tmux"
    local theme_file="$tmux_config_dir/milkoutside.tmux"
    
    if ! command_exists "tmux"; then
        log "ERROR" "Tmux not found. Please install Tmux first."
        return 1
    fi
    
    if [ ! -f "$REPO_ROOT/extras/tmux/milkoutside.tmux" ]; then
        log "ERROR" "Tmux theme file not found"
        return 1
    fi
    
    # Create config directory
    mkdir -p "$tmux_config_dir"
    
    # Install theme file
    if install_file "$REPO_ROOT/extras/tmux/milkoutside.tmux" "$theme_file" "Tmux theme"; then
        # Update .tmux.conf to source the theme
        local tmux_conf="$HOME/.tmux.conf"
        if [ -f "$tmux_conf" ]; then
            if ! grep -q "milkoutside.tmux" "$tmux_conf"; then
                log "INFO" "Adding theme to .tmux.conf"
                echo -e "\n# MilkOutside theme\nsource-file ~/.config/tmux/milkoutside.tmux" >> "$tmux_conf"
            fi
        else
            log "INFO" "Creating .tmux.conf"
            cat > "$tmux_conf" << 'EOF'
# Tmux configuration

# MilkOutside theme
source-file ~/.config/tmux/milkoutside.tmux

# Basic settings
set -g mouse on
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"
EOF
        fi
        
        log "INFO" "Tmux theme installed successfully"
        log "INFO" "Reload Tmux configuration with: tmux source-file ~/.tmux.conf"
        return 0
    else
        return 1
    fi
}

# Run installation
install_tmux