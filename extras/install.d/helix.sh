#!/bin/bash

# Helix editor theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install Helix theme
install_helix() {
    local helix_config_dir="$HOME/.config/helix"
    local themes_dir="$helix_config_dir/themes"
    local theme_file="$themes_dir/milkoutside.toml"
    
    if ! command_exists "hx"; then
        log "ERROR" "Helix editor not found. Please install Helix first."
        return 1
    fi
    
    if [ ! -f "$REPO_ROOT/extras/helix/milkoutside.toml" ]; then
        log "ERROR" "Helix theme file not found"
        return 1
    fi
    
    # Create themes directory
    mkdir -p "$themes_dir"
    
    # Install theme
    if install_file "$REPO_ROOT/extras/helix/milkoutside.toml" "$theme_file" "Helix theme"; then
        # Update config.toml to use the theme
        local config_file="$helix_config_dir/config.toml"
        if [ -f "$config_file" ]; then
            if ! grep -q "theme = \"milkoutside\"" "$config_file"; then
                log "INFO" "Adding theme to Helix config"
                if grep -q "^theme = " "$config_file"; then
                    # Replace existing theme line
                    sed -i.bak 's/^theme = .*/theme = "milkoutside"/' "$config_file"
                else
                    # Add theme line
                    echo 'theme = "milkoutside"' >> "$config_file"
                fi
            fi
        else
            log "INFO" "Creating Helix config file"
            cat > "$config_file" << 'EOF'
theme = "milkoutside"

[editor]
line-number = "relative"
mouse = true

[editor.cursor-shape]
insert = "bar"
normal = "block"
select = "underline"

[editor.file-picker]
hidden = false
EOF
        fi
        
        log "INFO" "Helix theme installed successfully"
        log "INFO" "Restart Helix or run :theme milkoutside to apply"
        return 0
    else
        return 1
    fi
}

# Run installation
install_helix