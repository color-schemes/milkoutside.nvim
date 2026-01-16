#!/bin/bash

# WezTerm theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install WezTerm theme
install_wezterm() {
    local config_dir="$HOME/.config/wezterm"
    local theme_file="$config_dir/milkoutside.toml"
    
    if [ ! -f "$REPO_ROOT/extras/wezterm/milkoutside.toml" ]; then
        log "ERROR" "WezTerm theme file not found"
        return 1
    fi
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Install theme file
    if install_file "$REPO_ROOT/extras/wezterm/milkoutside.toml" "$theme_file" "WezTerm theme"; then
        # Check if main config exists and includes the theme
        local main_config="$config_dir/wezterm.lua"
        if [ -f "$main_config" ]; then
            if ! grep -q "milkoutside" "$main_config"; then
                log "INFO" "Adding theme import to wezterm.lua"
                local temp_file=$(mktemp)
                cat > "$temp_file" << 'EOF'
-- WezTerm configuration with MilkOutside theme
local wezterm = require 'wezterm'
local config = {}

-- Import MilkOutside theme
local milkoutside = wezterm.config.load_file('milkoutside.toml')
config.color_schemes = ['MilkOutside'] = milkoutside
config.color_scheme = 'MilkOutside'

-- Your existing configuration below this line
EOF
                # Append existing config (excluding first line if it's similar)
                tail -n +2 "$main_config" >> "$temp_file"
                mv "$temp_file" "$main_config"
            fi
        else
            # Create basic config that uses the theme
            log "INFO" "Creating wezterm.lua"
            cat > "$main_config" << 'EOF'
-- WezTerm configuration with MilkOutside theme
local wezterm = require 'wezterm'
local config = {}

-- Import MilkOutside theme
local milkoutside = wezterm.config.load_file('milkoutside.toml')
config.color_schemes = {
  ['MilkOutside'] = milkoutside,
}
config.color_scheme = 'MilkOutside'

-- Basic settings
config.font = wezterm.font('JetBrains Mono')
config.font_size = 12.0

return config
EOF
        fi
        
        log "INFO" "WezTerm theme installed successfully"
        log "INFO" "Reload WezTerm configuration to see changes"
        return 0
    else
        return 1
    fi
}

# Run installation
install_wezterm