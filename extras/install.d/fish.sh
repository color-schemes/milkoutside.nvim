#!/bin/bash

# Fish shell theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install Fish theme
install_fish() {
    local fish_config_dir="$HOME/.config/fish"
    local prompt_file="$fish_config_dir/functions/_fish_prompt_milkoutside.fish"
    local themes_dir="$fish_config_dir/themes"
    local theme_file="$themes_dir/MilkOutside.theme"
    
    # Check if Fish is installed
    if ! command_exists "fish"; then
        log "ERROR" "Fish shell not found. Please install Fish first."
        return 1
    fi
    
    # Create directories
    mkdir -p "$fish_config_dir/functions"
    mkdir -p "$themes_dir"
    
    # Install prompt function
    if [ -f "$REPO_ROOT/extras/fish/milkoutside.fish" ]; then
        if install_file "$REPO_ROOT/extras/fish/milkoutside.fish" "$prompt_file" "Fish prompt"; then
            log "INFO" "Fish prompt function installed"
        fi
    fi
    
    # Install Fish theme
    if [ -f "$REPO_ROOT/extras/fish_themes/milkoutside.theme" ]; then
        if install_file "$REPO_ROOT/extras/fish_themes/milkoutside.theme" "$theme_file" "Fish theme"; then
            log "INFO" "Fish theme installed"
            
            # Set theme in config.fish if not already set
            local config_file="$fish_config_dir/config.fish"
            if [ -f "$config_file" ]; then
                if ! grep -q "fish_theme MilkOutside" "$config_file"; then
                    log "INFO" "Adding theme to Fish config"
                    echo -e "\n# MilkOutside theme\nfish_theme MilkOutside" >> "$config_file"
                fi
            else
                log "INFO" "Creating Fish config file"
                cat > "$config_file" << EOF
# Fish configuration

# MilkOutside theme
fish_theme MilkOutside

# MilkOutside prompt function
function fish_prompt
    _fish_prompt_milkoutside
end
EOF
            fi
        fi
    fi
    
    # Install color scheme
    if [ -f "$REPO_ROOT/extras/fish/fish_colors" ]; then
        local colors_file="$fish_config_dir/fish_colors"
        if install_file "$REPO_ROOT/extras/fish/fish_colors" "$colors_file" "Fish color scheme"; then
            log "INFO" "Fish color scheme installed"
        fi
    fi
    
    log "INFO" "Fish theme installation completed"
    log "INFO" "Restart Fish or run 'source ~/.config/fish/config.fish' to see changes"
    return 0
}

# Run installation
install_fish