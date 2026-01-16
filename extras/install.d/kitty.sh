#!/bin/bash

# Kitty theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install Kitty theme
install_kitty() {
    local config_dir="$HOME/.config/kitty"
    local theme_file="$config_dir/milkoutside.conf"
    
    if [ ! -f "$REPO_ROOT/extras/kitty/milkoutside.conf" ]; then
        log "ERROR" "Kitty theme file not found"
        return 1
    fi
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Install theme file
    if install_file "$REPO_ROOT/extras/kitty/milkoutside.conf" "$theme_file" "Kitty theme"; then
        # Check if kitty.conf exists and includes the theme
        local main_config="$config_dir/kitty.conf"
        if [ -f "$main_config" ]; then
            if ! grep -q "include milkoutside.conf" "$main_config"; then
                log "INFO" "Adding theme include to kitty.conf"
                echo -e "\n# MilkOutside theme\ninclude milkoutside.conf" >> "$main_config"
            fi
        else
            # Create minimal config that includes the theme
            log "INFO" "Creating minimal kitty.conf"
            cat > "$main_config" << EOF
# Kitty configuration with MilkOutside theme
include milkoutside.conf

# Basic settings
font_family monospace
font_size 12.0
EOF
        fi
        
        log "INFO" "Kitty theme installed successfully"
        log "INFO" "Press Ctrl+Shift+F5 in Kitty to reload config"
        return 0
    else
        return 1
    fi
}

# Run installation
install_kitty