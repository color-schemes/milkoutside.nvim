# MilkOutside macOS Color Scheme

This package provides a macOS system-wide color scheme based on the MilkOutside theme.

## Installation

Run the installation script:
```bash
./install.sh
```

## What it does

The installer applies the following macOS settings:

### Appearance
- **Dark Mode**: Enabled (matches `#040607` background)
- **Accent Color**: Red (matches `#fda1a0` light red)
- **Highlight Color**: Custom light red accent
- **Menu Bar**: Non-transparent for consistency

### Accessibility
- **Increase Contrast**: Enabled (matches theme's high contrast nature)
- **Differentiate Without Color**: Disabled (preserves color information)

### Dock
- **Size**: 48px (default readable size)
- **Orientation**: Bottom
- **Show Recents**: Disabled (clean appearance)
- **Auto-hide**: Disabled (consistent access)

### Color Mapping

| MilkOutside Color | macOS Element |
|------------------|---------------|
| `#040607` (bg) | Dark mode background |
| `#fda1a0` (red) | Primary accent color |
| `#e8e8e8` (fg) | Text on dark backgrounds |
| `#1a1e2e` (bg_dark1) | UI element backgrounds |

## Manual Configuration

After installation, some items may need manual adjustment in **System Preferences**:

1. **General**:
   - Appearance: Dark ✓
   - Accent color: Blue ✓
   - Highlight color: Custom (adjust if needed)

2. **Accessibility > Display**:
   - Increase contrast: ✓
   - Reduce transparency: ✓ (recommended)

3. **Dock & Menu Bar**:
   - Size: 48px ✓
   - Position: Bottom ✓

## Terminal Applications

For terminal emulators, install the respective themes:

```bash
# iTerm2
./install.sh iterm

# For other terminals, see the extras directory
./install.sh --list
```

## Backup

The installer creates a backup of your current settings at:
```
~/.config/milkoutside-macos-backup-YYYYMMDD-HHMMSS/
```

## Restoration

To restore original settings:
```bash
# Navigate to backup directory
cd ~/.config/milkoutside-macos-backup-*

# Restore settings (example)
defaults write NSGlobalDomain AppleInterfaceStyle -string "$(cat interface_style.txt)"
defaults write NSGlobalDomain AppleAccentColor -int "$(cat accent_color.txt)"
# ... etc for other settings
```

## Notes

- Some changes require logging out or restarting to take full effect
- The accent color matches the primary light red (`#fda1a0`) from the MilkOutside palette
- Increased contrast provides better readability matching the theme's design philosophy
- Terminal applications require separate theme installation