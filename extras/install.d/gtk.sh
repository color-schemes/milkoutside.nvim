#!/bin/bash

# GTK Theme Installer for MilkOutside

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Install GTK theme
install_gtk_theme() {
    local gtk_theme_dir="$HOME/.themes/MilkOutside"
    local src_dir="$REPO_ROOT/extras/gtk"
    
    if [ ! -d "$src_dir" ]; then
        log "ERROR" "GTK theme source directory not found: $src_dir"
        return 1
    fi
    
    log "INFO" "Installing GTK theme..."
    
    # Create theme directory
    mkdir -p "$gtk_theme_dir"
    
    # Install theme files
    if install_dir "$src_dir" "$gtk_theme_dir" "GTK theme"; then
        log "INFO" "GTK theme installed successfully"
        
        # Detect desktop environment and apply theme
        detect_and_apply_gtk_theme
        return 0
    else
        return 1
    fi
}

# Detect desktop environment and apply theme
detect_and_apply_gtk_theme() {
    local current_desktop="${XDG_CURRENT_DESKTOP:-}"
    local desktop=""
    
    case "$current_desktop" in
        *"GNOME"*)
            desktop="gnome"
            apply_gnome_theme
            ;;
        *"KDE"*)
            desktop="kde"
            apply_kde_theme
            ;;
        *"XFCE"*)
            desktop="xfce"
            apply_xfce_theme
            ;;
        *"MATE"*)
            desktop="mate"
            apply_mate_theme
            ;;
        *"Cinnamon"*)
            desktop="cinnamon"
            apply_cinnamon_theme
            ;;
        *"Budgie"*)
            desktop="budgie"
            apply_budgie_theme
            ;;
        *)
            log "WARN" "Unknown desktop environment: $current_desktop"
            log "INFO" "Please manually apply the GTK theme in your desktop settings"
            return 1
            ;;
    esac
}

# Apply GNOME theme
apply_gnome_theme() {
    log "INFO" "Applying GTK theme for GNOME..."
    
    if command_exists "gsettings"; then
        gsettings set org.gnome.desktop.interface gtk-theme "MilkOutside"
        gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        log "INFO" "GTK theme applied for GNOME"
        log "INFO" "Restart your session or run 'killall -r nautilus' to see changes"
    else
        log "ERROR" "gsettings not found. Cannot apply GNOME theme automatically."
    fi
}

# Apply KDE theme
apply_kde_theme() {
    log "INFO" "KDE detected. Note: KDE uses Qt, not GTK."
    log "INFO" "For GTK applications in KDE, the theme should apply automatically."
    log "INFO" "You may need to configure GTK settings in KDE System Settings > Appearance > Application Style > GNOME Application Style (GTK)"
}

# Apply XFCE theme
apply_xfce_theme() {
    log "INFO" "Applying GTK theme for XFCE..."
    
    if command_exists "xfconf-query"; then
        xfconf-query -c xsettings -p /Net/ThemeName -s "MilkOutside"
        xfconf-query -c xsettings -p /Net/IconThemeName -s "Adwaita"
        xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Adwaita"
        log "INFO" "GTK theme applied for XFCE"
    else
        log "ERROR" "xfconf-query not found. Cannot apply XFCE theme automatically."
    fi
}

# Apply MATE theme
apply_mate_theme() {
    log "INFO" "Applying GTK theme for MATE..."
    
    if command_exists "gsettings"; then
        gsettings set org.mate.interface gtk-theme "MilkOutside"
        gsettings set org.mate.interface icon-theme "Adwaita"
        gsettings set org.mate.interface cursor-theme "Adwaita"
        log "INFO" "GTK theme applied for MATE"
    else
        log "ERROR" "gsettings not found. Cannot apply MATE theme automatically."
    fi
}

# Apply Cinnamon theme
apply_cinnamon_theme() {
    log "INFO" "Applying GTK theme for Cinnamon..."
    
    if command_exists "gsettings"; then
        gsettings set org.cinnamon.desktop.interface gtk-theme "MilkOutside"
        gsettings set org.cinnamon.desktop.interface icon-theme "Adwaita"
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita"
        log "INFO" "GTK theme applied for Cinnamon"
    else
        log "ERROR" "gsettings not found. Cannot apply Cinnamon theme automatically."
    fi
}

# Apply Budgie theme
apply_budgie_theme() {
    log "INFO" "Applying GTK theme for Budgie..."
    
    if command_exists "gsettings"; then
        gsettings set org.budgie.desktop.interface gtk-theme "MilkOutside"
        gsettings set org.budgie.desktop.interface icon-theme "Adwaita"
        gsettings set org.budgie.desktop.interface cursor-theme "Adwaita"
        log "INFO" "GTK theme applied for Budgie"
    else
        log "ERROR" "gsettings not found. Cannot apply Budgie theme automatically."
    fi
}

# Run installation
install_gtk_theme