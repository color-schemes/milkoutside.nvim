#!/bin/bash

# OpenCode AI assistant theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install OpenCode theme
install_opencode() {
    log "INFO" "Installing OpenCode theme"
    
    # Check if OpenCode config directory exists
    local opencode_config_dir="$HOME/.config/opencode"
    local opencode_theme_file="$opencode_config_dir/milkoutside-theme.json"
    
    # Create OpenCode config directory if it doesn't exist
    mkdir -p "$opencode_config_dir"
    
    # Create OpenCode theme file if it doesn't exist in repo
    local theme_source="$REPO_ROOT/extras/opencode/milkoutside-theme.json"
    if [ ! -f "$theme_source" ]; then
        log "INFO" "Creating OpenCode theme file"
        mkdir -p "$(dirname "$theme_source")"
        cat > "$theme_source" << 'EOF'
{
  "name": "MilkOutside",
  "type": "dark",
  "colors": {
    "background": "#1e1e2e",
    "foreground": "#cdd6f4",
    "cursor": "#f5e0dc",
    "selection": "#585b70",
    "black": "#45475a",
    "red": "#f38ba8",
    "green": "#a6e3a1",
    "yellow": "#f9e2af",
    "blue": "#89b4fa",
    "magenta": "#f5c2e7",
    "cyan": "#94e2d5",
    "white": "#bac2de",
    "brightBlack": "#585b70",
    "brightRed": "#f38ba8",
    "brightGreen": "#a6e3a1",
    "brightYellow": "#f9e2af",
    "brightBlue": "#89b4fa",
    "brightMagenta": "#f5c2e7",
    "brightCyan": "#94e2d5",
    "brightWhite": "#a6adc8"
  },
  "syntax": {
    "comment": "#6c7086",
    "keyword": "#cba6f7",
    "function": "#89b4fa",
    "string": "#a6e3a1",
    "number": "#fab387",
    "variable": "#f2cdcd",
    "type": "#94e2d5"
  },
  "ui": {
    "border": "#45475a",
    "highlight": "#313244",
    "active": "#585b70",
    "inactive": "#1e1e2e"
  }
}
EOF
    fi
    
    # Install theme file
    if install_file "$theme_source" "$opencode_theme_file" "OpenCode theme"; then
        log "INFO" "OpenCode theme installed successfully"
        log "INFO" "Restart OpenCode to apply the theme"
    else
        log "ERROR" "Failed to install OpenCode theme"
        return 1
    fi
    
    return 0
}

# Run installation
install_opencode