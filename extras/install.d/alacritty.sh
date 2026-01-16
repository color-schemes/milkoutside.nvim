#!/bin/bash

# Alacritty theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install Alacritty theme
install_alacritty() {
    local config_dir="$HOME/.config/alacritty"
    local theme_file="$config_dir/milkoutside.toml"
    
    if [ ! -f "$REPO_ROOT/extras/alacritty/milkoutside.toml" ]; then
        log "ERROR" "Alacritty theme file not found"
        return 1
    fi
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Install theme file
    if install_file "$REPO_ROOT/extras/alacritty/milkoutside.toml" "$theme_file" "Alacritty theme"; then
        # Check if alacritty.toml exists and includes the theme
        local main_config="$config_dir/alacritty.toml"
        if [ -f "$main_config" ]; then
            if ! grep -q "import = \['milkoutside.toml'\]" "$main_config"; then
                log "INFO" "Adding theme import to alacritty.toml"
                echo -e "\nimport = ['milkoutside.toml']" >> "$main_config"
            fi
        else
            # Create minimal config that imports the theme
            log "INFO" "Creating minimal alacritty.toml"
            cat > "$main_config" << EOF
# Alacritty configuration with MilkOutside theme
import = ['milkoutside.toml']

[shell]
program = "/bin/bash"
EOF
        fi
        
        log "INFO" "Alacritty theme installed successfully"
        log "INFO" "Restart Alacritty to see changes"
        return 0
    else
        return 1
    fi
}

# Run installation
install_alacritty