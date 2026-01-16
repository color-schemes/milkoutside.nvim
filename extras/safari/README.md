# Safari Theme Installation Instructions

## MilkOutside Safari Theme

### Prerequisites:

- Safari 14+ (macOS Big Sur or later)
- Xcode command line tools (for building extensions)

### Installation Steps:

1. **Enable Safari Developer Menu**
   - Open Safari
   - Go to Safari > Preferences > Advanced
   - Check "Show Develop menu in menu bar"

2. **Allow Unsigned Extensions**
   - In Safari menu, go to Develop > Allow Unsigned Extensions
   - This enables loading of third-party extensions

3. **Build Extension**
   ```bash
   cd extras/safari
   xcrun safari-web-extension-converter .
   ```

4. **Load Extension**
   - Open Safari > Preferences > Extensions
   - The MilkOutside extension should appear in the list
   - Enable the extension by checking the box next to it

### Manual Loading:

If the automatic conversion doesn't work:

1. **Package the Extension**
   ```bash
   cd extras/safari
   mkdir -p MilkOutside.safariextension
   cp manifest.json MilkOutside.safariextension/
   cp milkoutside.css MilkOutside.safariextension/
   ```

2. **Load in Safari**
   - Double-click the `MilkOutside.safariextension` folder
   - Safari will ask for permission to install
   - Confirm installation in Extensions preferences

### Features:

- Dark theme with MilkOutside color palette
- Custom Safari interface styling
- Themed toolbar and bookmarks
- Custom tab styling
- Matching contextual menus

### Troubleshooting:

- If the extension doesn't appear, restart Safari
- Make sure "Allow Unsigned Extensions" is enabled
- Check Safari's Extensions preferences for any errors
- Some system UI elements may not be themed due to Safari limitations

### Removal:

To remove the theme, go to Safari > Preferences > Extensions, find "MilkOutside" and uncheck or remove it.

### Notes:

- Safari has more limited theming capabilities than Chrome/Firefox
- Some UI elements may retain default appearance
- Extension needs to be rebuilt after major Safari updates