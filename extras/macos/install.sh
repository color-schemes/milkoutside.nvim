#!/bin/bash

# MilkOutside macOS Color Scheme Installer
# Applies MilkOutside colors to macOS system interface

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to check if running on macOS
check_macos() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}This script can only be run on macOS${NC}"
    exit 1
  fi
}

# Function to backup current settings
backup_settings() {
  local backup_dir="$HOME/.config/milkoutside-macos-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"

  echo -e "${YELLOW}Creating backup of current settings...${NC}"

  # Backup existing appearance settings
  sudo defaults read NSGlobalDomain AppleInterfaceStyle >"$backup_dir/interface_style.txt" 2>/dev/null || echo "Not set" >"$backup_dir/interface_style.txt"
  sudo defaults read NSGlobalDomain AppleAccentColor >"$backup_dir/accent_color.txt" 2>/dev/null || echo "Not set" >"$backup_dir/accent_color.txt"
  sudo defaults read NSGlobalDomain AppleHighlightColor >"$backup_dir/highlight_color.txt" 2>/dev/null || echo "Not set" >"$backup_dir/highlight_color.txt"

  # Backup accessibility settings (may fail due to permissions)
  sudo defaults read com.apple.universalaccess IncreaseContrast >"$backup_dir/increase_contrast.txt" 2>/dev/null || echo "Not set" >"$backup_dir/increase_contrast.txt"
  sudo defaults read com.apple.universalaccess DifferentiateWithoutColor >"$backup_dir/differentiate_without_color.txt" 2>/dev/null || echo "Not set" >"$backup_dir/differentiate_without_color.txt"

  echo -e "${GREEN}Backup created: $backup_dir${NC}"
}

# Function to apply MilkOutside color scheme
apply_colors() {
  echo -e "${BLUE}Applying MilkOutside color scheme...${NC}"

  # Dark mode (uses our dark background colors)
  sudo defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
  sudo defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool false

  # Set accent color to red that matches our light red theme
  # macOS uses numeric values: 0=Blue, 1=Purple, 2=Pink, 3=Red, 4=Orange, 5=Yellow, 6=Green, 7=Graphite
  # We'll use Red (3) as it matches our #fda1a0 light red
  sudo defaults write NSGlobalDomain AppleAccentColor -int 3

  # Set highlight color (custom color matching our light red accent)
  # This is more complex - we need to create a custom color preset
  sudo defaults write NSGlobalDomain AppleHighlightColor -string "0.992157 0.631373 0.627451 Red"

  # Menu bar transparency
  sudo defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false

  # Dock settings (darker appearance)
  sudo defaults write com.apple.dock tilesize -int 48
  sudo defaults write com.apple.dock orientation -string "bottom"

  echo -e "${GREEN}Basic color scheme applied!${NC}"
}

# Function to apply accessibility settings (may require permissions)
apply_accessibility() {
  echo -e "${BLUE}Applying accessibility settings...${NC}"

  # Try to apply accessibility settings for better contrast
  if sudo defaults write com.apple.universalaccess IncreaseContrast -bool true 2>/dev/null; then
    echo -e "${GREEN}✓ Increased contrast enabled${NC}"
  else
    echo -e "${YELLOW}⚠ Could not set increased contrast (manual setup required)${NC}"
  fi

  if sudo defaults write com.apple.universalaccess DifferentiateWithoutColor -bool false 2>/dev/null; then
    echo -e "${GREEN}✓ Color differentiation settings applied${NC}"
  else
    echo -e "${YELLOW}⚠ Could not set color differentiation (manual setup required)${NC}"
  fi
}

# Function to apply custom highlight color via defaults
apply_custom_highlight() {
  echo -e "${BLUE}Setting custom highlight color...${NC}"

  # Use defaults command to set highlight color (more reliable than AppleScript)
  if defaults write NSGlobalDomain AppleHighlightColor -string "0.992157 0.631373 0.627451 MilkOutside"; then
    echo -e "${GREEN}✓ Custom highlight color set successfully${NC}"
  else
    echo -e "${YELLOW}⚠ Custom highlight color may require manual adjustment in System Preferences${NC}"
  fi
}

# Function to restart affected applications
restart_apps() {
  echo -e "${BLUE}Restarting System UI components...${NC}"

  # Kill and restart Dock
  killall Dock 2>/dev/null || true

  # Kill and restart SystemUIServer
  killall SystemUIServer 2>/dev/null || true

  # Kill and restart ControlCenter
  killall ControlCenter 2>/dev/null || true

  echo -e "${GREEN}System components restarted!${NC}"
}

# Function to show manual instructions
show_manual_instructions() {
  echo -e "${YELLOW}Manual adjustments may be needed:${NC}"
  echo -e "${BLUE}1. Open System Settings > Appearance${NC}"
  echo -e "${BLUE}2. Verify 'Dark' appearance is selected${NC}"
  echo -e "${BLUE}3. Set 'Accent color' to Red (matches #fda1a0)${NC}"
  echo -e "${BLUE}4. Set 'Highlight color' to match MilkOutside accent${NC}"
  echo -e "${BLUE}5. Open System Settings > Accessibility > Display${NC}"
  echo -e "${BLUE}6. Enable 'Increase contrast' (if not already applied)${NC}"
  echo
  echo -e "${YELLOW}For terminal applications, install separate themes:${NC}"
  echo -e "${BLUE}- iTerm2: ./install.sh iterm${NC}"
  echo -e "${BLUE}- Terminal.app: Manual setup required${NC}"
}

# Main installation function
main() {
  echo -e "${GREEN}MilkOutside macOS Color Scheme Installer${NC}"
  echo

  check_macos
  backup_settings
  apply_colors
  apply_accessibility
  apply_custom_highlight
  restart_apps
  show_manual_instructions

  echo
  echo -e "${GREEN}Installation complete!${NC}"
  echo -e "${BLUE}Some changes may require a logout/restart to fully take effect.${NC}"
}

# Run main function
main "$@"
