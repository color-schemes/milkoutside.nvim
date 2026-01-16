# Safari Extension Installation Guide

## MilkOutside Safari Theme Installation

Safari themes work differently from other browsers. Here's the complete guide:

---

## 🍎 Method 1: Safari Web Extension (Recommended)

### Prerequisites:
- Safari 14+ (macOS Big Sur or later)
- Xcode Command Line Tools

### Step 1: Install Xcode Tools
```bash
xcode-select --install
```

### Step 2: Enable Developer Menu
1. Open Safari
2. Click "Safari" in menu bar
3. Select "Preferences" 
4. Click "Advanced" tab
5. Check "Show Develop menu in menu bar"

### Step 3: Allow Unsigned Extensions
1. Click "Develop" menu (now visible)
2. Select "Allow Unsigned Extensions"

### Step 4: Build Extension
```bash
# Navigate to the safari theme directory
cd /path/to/milkoutside.nvim/extras/safari

# Make the build script executable
chmod +x build.sh

# Build the extension
./build.sh
```

### Step 5: Install Extension
1. Open Finder
2. Navigate to milkoutside.nvim directory
3. Double-click "MilkOutside.safariextension" folder
4. Safari will show installation prompt
5. Click "Install"
6. Go to Safari > Preferences > Extensions
7. Enable "MilkOutside Theme" by checking the box

---

## 🎨 Method 2: User Stylesheet (Alternative)

This method works for older Safari versions or if extension doesn't work.

### Step 1: Enable Style Sheets
1. Open Safari > Preferences > Advanced
2. Check "Show Develop menu in menu bar"

### Step 2: Create User Style Sheet
```bash
# Create user styles directory
mkdir -p ~/Library/Safari/UserStyleSheet

# Copy the theme file
cp /path/to/milkoutside.nvim/extras/safari/milkoutside.css \
   ~/Library/Safari/UserStyleSheet/milkoutside.css
```

### Step 3: Activate in Safari
1. Open Safari
2. Click "Develop" menu
3. Select "User Style" > "milkoutside"
4. Theme should apply immediately

---

## 🔧 Troubleshooting

### Extension Not Appearing:
1. **Check Safari Version**: Must be Safari 14+
2. **Developer Menu**: Must be enabled in Preferences > Advanced
3. **Unsigned Extensions**: Must be allowed via Develop menu
4. **Build Extension**: Run `./build.sh` to create proper package

### Theme Not Applying:
1. **Restart Safari**: Required after enabling extensions
2. **Check Conflicts**: Disable other theme extensions
3. **Verify CSS**: Ensure milkoutside.css exists and is readable

### Permissions Error:
1. **System Preferences**: Allow Safari extensions in System Settings
2. **Security Settings**: Check Privacy & Security settings

---

## 🐛 Manual Installation

If automatic methods fail:

### Direct CSS Injection:
```bash
# Use Safari's built-in user style
sudo cp /path/to/milkoutside.nvim/extras/safari/milkoutside.css \
   /Applications/Safari.app/Contents/Resources/UserStyleSheet.css
```

### Terminal Commands:
```bash
# Enable develop menu (if not already enabled)
defaults write com.apple.Safari IncludeDevelopMenu -bool true

# Allow unsigned extensions
defaults write com.apple.Safari WebKitDeveloperExtras -bool true
```

---

## 📱 Verification

To verify the theme is working:
1. Open Safari
2. Check if interface uses dark colors
3. Look for MilkOutside color scheme:
   - Background: Dark (#040607)
   - Text: Light (#e8e8e8)
   - Accents: Blue (#63c3dd), Red (#fda1a0)

---

## 🔍 Debug Mode

To debug Safari extension issues:
1. Enable Develop menu
2. Open Develop > Web Inspector
3. Check Console for JavaScript errors
4. Look for extension-related messages

---

## 🗑️ Removal

### To Remove Extension:
1. Open Safari > Preferences > Extensions
2. Find "MilkOutside Theme"
3. Uncheck to disable
4. Click "Uninstall" to remove completely

### To Remove User Style:
1. Delete the CSS file:
```bash
rm ~/Library/Safari/UserStyleSheet/milkoutside.css
```
2. Restart Safari

---

## 💡 Notes

- **Safari Limitations**: Safari has fewer theming capabilities than Chrome/Firefox
- **System Integration**: Some UI elements may remain default
- **Permission Required**: Safari extensions require explicit user approval
- **macOS Only**: Safari themes only work on macOS
- **Updates Required**: Extension may need rebuilding after Safari updates

---

## 🚀 Quick Start Commands

For macOS users with Homebrew and Xcode installed:

```bash
# Install everything at once
cd /path/to/milkoutside.nvim/extras
./install.sh safari

# Or use the specialized macOS browser installer
./macos/browsers.sh safari
```

This should get the MilkOutside theme working in Safari!