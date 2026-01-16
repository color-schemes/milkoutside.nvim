#!/bin/bash

# Neovim/Vim theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install Neovim theme
install_neovim() {
    local nvim_config_dir="$HOME/.config/nvim"
    local colors_dir="$nvim_config_dir/colors"
    local lua_colors_dir="$nvim_config_dir/lua/colors"
    
    # Create directories
    mkdir -p "$colors_dir"
    mkdir -p "$lua_colors_dir"
    
    # Install traditional Vim colors
    if [ -d "$REPO_ROOT/extras/vim/colors" ]; then
        log "INFO" "Installing Vim colors for Neovim"
        cp -r "$REPO_ROOT/extras/vim/colors"/* "$colors_dir/" 2>/dev/null || true
    fi
    
    # Install Lua colorscheme
    if [ -f "$REPO_ROOT/extras/lua/milkoutside.lua" ]; then
        install_file "$REPO_ROOT/extras/lua/milkoutside.lua" "$lua_colors_dir/milkoutside.lua" "Neovim Lua colorscheme"
    fi
    
    # Update init.lua if it exists
    local init_file="$nvim_config_dir/init.lua"
    if [ -f "$init_file" ]; then
        if ! grep -q "milkoutside" "$init_file"; then
            log "INFO" "Adding colorscheme to init.lua"
            local temp_file=$(mktemp)
            cp "$init_file" "$temp_file"
            
            # Add colorscheme configuration at the beginning
            cat > "$init_file" << 'EOF'
-- MilkOutside theme configuration
vim.cmd.colorscheme('milkoutside')

EOF
            cat "$temp_file" >> "$init_file"
            rm "$temp_file"
        fi
    fi
    
    log "INFO" "Neovim theme installed successfully"
    return 0
}

# Install Vim theme
install_vim() {
    local vim_config_dir="$HOME/.vim"
    local colors_dir="$vim_config_dir/colors"
    
    # Create directories
    mkdir -p "$colors_dir"
    
    # Install colors
    if [ -d "$REPO_ROOT/extras/vim/colors" ]; then
        if install_dir "$REPO_ROOT/extras/vim/colors" "$colors_dir" "Vim colors"; then
            # Update .vimrc if it exists
            local vimrc="$HOME/.vimrc"
            if [ -f "$vimrc" ]; then
                if ! grep -q "milkoutside" "$vimrc"; then
                    log "INFO" "Adding colorscheme to .vimrc"
                    echo -e '\n" MilkOutside theme\ncolorscheme milkoutside' >> "$vimrc"
                fi
            else
                log "INFO" "Creating basic .vimrc"
                cat > "$vimrc" << 'EOF'
" Basic Vim configuration
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab

" MilkOutside theme
colorscheme milkoutside
EOF
            fi
        fi
    fi
    
    log "INFO" "Vim theme installed successfully"
    return 0
}

# Install plugin themes
install_plugin_themes() {
    local nvim_config_dir="$HOME/.config/nvim"
    
    # NvimTree
    if [ -f "$REPO_ROOT/extras/nvimtree/milkoutside.lua" ] && [ -d "$nvim_config_dir/lua/plugins" ]; then
        local nvimtree_config="$nvim_config_dir/lua/plugins/nvimtree.lua"
        install_file "$REPO_ROOT/extras/nvimtree/milkoutside.lua" "$nvimtree_config" "NvimTree theme"
    fi
    
    # Neo-tree
    if [ -f "$REPO_ROOT/extras/neotree/milkoutside.lua" ] && [ -d "$nvim_config_dir/lua/plugins" ]; then
        local neotree_config="$nvim_config_dir/lua/plugins/neotree.lua"
        install_file "$REPO_ROOT/extras/neotree/milkoutside.lua" "$neotree_config" "Neo-tree theme"
    fi
    
    # Snacks
    if [ -f "$REPO_ROOT/extras/snacks/milkoutside.lua" ] && [ -d "$nvim_config_dir/lua/plugins" ]; then
        local snacks_config="$nvim_config_dir/lua/plugins/snacks.lua"
        install_file "$REPO_ROOT/extras/snacks/milkoutside.lua" "$snacks_config" "Snacks theme"
    fi
}

# Main installer
case "$(basename "$0")" in
    "vim.sh")
        install_vim
        ;;
    "neovim.sh"|"nvim.sh")
        install_neovim
        install_plugin_themes
        ;;
    *)
        # Default to installing both
        install_vim
        install_neovim
        install_plugin_themes
        ;;
esac