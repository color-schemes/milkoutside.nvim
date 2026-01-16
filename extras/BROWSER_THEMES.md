# Browser Themes Installation

## MilkOutside Browser Themes

This directory contains themes for multiple browsers with the MilkOutside color scheme.

## Supported Browsers

### 🦊 Mozilla Firefox
**File**: `extras/firefox/userChrome.css`

**Installation**:
```bash
# Install via script
./install.sh firefox

# Or manual:
# 1. Find Firefox profile: ~/.mozilla/firefox/*.default*
# 2. Create chrome directory: mkdir -p profile/chrome/
# 3. Copy userChrome.css: cp extras/firefox/userChrome.css profile/chrome/
# 4. Enable in about:config: toolkit.legacyUserProfileCustomizations.stylesheets = true
```

### 🌐 Google Chrome
**Directory**: `extras/chrome/`

**Installation**:
```bash
# Install via script
./install.sh chrome

# Then follow these steps:
# 1. Open chrome://extensions/
# 2. Enable "Developer mode"
# 3. Click "Load unpacked"
# 4. Select extras/chrome directory
# 5. Apply in Chrome Settings > Appearance
```

### 🧭 Apple Safari
**Directory**: `extras/safari/`

**Installation**:
```bash
# Install via script
./install.sh safari

# Then follow these steps:
# 1. Safari > Preferences > Advanced > Show Develop menu
# 2. Develop > Allow Unsigned Extensions
# 3. Build extension: cd extras/safari && xcrun safari-web-extension-converter .
# 4. Enable in Safari Preferences > Extensions
```

### 🎭 Opera
**Directory**: `extras/opera/`

**Installation**:
```bash
# Install via script
./install.sh opera

# Then follow these steps:
# 1. Open opera://extensions/
# 2. Enable "Developer mode"
# 3. Click "Load unpacked"
# 4. Select extras/opera directory
# 5. Use extension icon to toggle theme
```

## Color Scheme

All themes use the MilkOutside palette:

- **Background**: `#040607` (dark), `#000000` (black), `#0f0f15` (highlight)
- **Foreground**: `#e8e8e8` (primary), `#e0e0e0` (secondary)
- **Accent**: `#fda1a0` (red), `#63c3dd` (blue), `#92cf9c` (green)
- **Other**: `#f8e063` (yellow), `#e79cfb` (magenta), `#9d7cd8` (purple)

## Quick Installation

To install all browser themes at once:

```bash
# Install all themes
./install.sh firefox chrome safari opera
```

## Troubleshooting

### Firefox
- **Theme not applying**: Check `toolkit.legacyUserProfileCustomizations.stylesheets` in about:config
- **Restart required**: Firefox may need restart after installing userChrome.css

### Chrome
- **Developer mode**: Must be enabled in chrome://extensions/
- **Permissions**: Theme may need permission to modify browser UI

### Safari
- **Developer menu**: Must be enabled in Safari Preferences
- **Unsigned extensions**: Allow in Develop menu
- **macOS only**: Safari themes only work on macOS

### Opera
- **Extension loading**: Must enable Developer mode in opera://extensions/
- **Theme toggle**: Use the extension icon in toolbar to enable/disable

## Manual Instructions

If the installer doesn't work, see individual README files:
- `extras/chrome/README.md`
- `extras/safari/README.md`
- `extras/opera/README.md`

## Notes

- **Firefox**: Uses userChrome.css for deep integration
- **Chrome**: Uses Chrome extension manifest
- **Safari**: Limited theming capabilities due to Apple restrictions
- **Opera**: Uses extension with toggle functionality

All themes aim for consistency across browsers while respecting each browser's capabilities and limitations.