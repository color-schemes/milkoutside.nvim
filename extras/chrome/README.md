# Chrome Theme Installation Instructions

## MilkOutside Chrome Theme

### Installation Steps:

1. **Open Chrome Extensions**
   - Open Chrome browser
   - Navigate to `chrome://extensions/`
   - Enable "Developer mode" (toggle switch in top right)

2. **Load Theme**
   - Click "Load unpacked" button
   - Navigate to and select the `extras/chrome` directory from milkoutside.nvim
   - The theme will be loaded as an extension and applied automatically

3. **Verify Installation**
   - The theme should apply immediately
   - Check Chrome's appearance settings to confirm "MilkOutside" is selected
   - Browser interface should now use dark MilkOutside colors

### Alternative Installation:

You can also drag the entire `extras/chrome` folder directly onto the `chrome://extensions/` page when Developer mode is enabled.

### Troubleshooting:

**Error: "Cannot load extension"**
- Ensure you're selecting the `extras/chrome` directory, not a file inside it
- Check that Developer mode is enabled
- Make sure Chrome is updated to latest version

**Error: "manifest.json not found"**
- Verify the manifest.json is in the `extras/chrome` directory
- Check file permissions on the theme files

**Theme not applying**
- Try restarting Chrome after loading the extension
- Check if other themes are conflicting
- Disable other theme extensions temporarily

### Features:

- ✅ Dark theme with MilkOutside color palette
- ✅ Custom tab colors and styling
- ✅ Themed URL bar and buttons
- ✅ Matching bookmark and history panels
- ✅ Custom scrollbars and selection colors
- ✅ No external image dependencies
- ✅ Pure color-based theming system

### Removal:

To remove the theme:
1. Go to `chrome://extensions/`
2. Find "MilkOutside" in the list
3. Click "Remove" button

### Notes:

- Theme uses Chrome's built-in theming API (Manifest V3)
- No external images required - works with pure color definitions
- Some websites may override theme colors with their own styles
- Theme persists across browser restarts
- Compatible with Chrome 88+

### Color Scheme:

- **Frame/Toolbar**: `#040607` (dark background)
- **Tabs**: `#000000` (black) with `#e8e8e8` text
- **Accent**: `#63c3dd` (blue) for buttons and highlights
- **Active Elements**: `#e8e8e8` (light text)
- **Inactive Elements**: `#e0e0e0` (secondary text)