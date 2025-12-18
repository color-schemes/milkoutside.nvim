# MilkOutside for Vivaldi Browser

The MilkOutside theme for Vivaldi browser.

## Usage

Vivaldi themes must be provided as zip files with a specific structure. Each theme requires a JSON file named `settings.json` inside the zip archive.

### Build script

A script is included to build the theme files:

1. Navigate to the `extras/vivaldi` directory
2. Run the build script:

   ```bash
   ./build
   ```

   This creates zip files for each theme variant with the JSON file renamed to `settings.json`.

### Manual Zipping

If you prefer to manually create the theme files:

1. Create a temporary directory
2. Copy a theme JSON file (e.g., `milkoutside.json`) to this directory
3. Rename it to `settings.json`
4. Zip the file: 

   ```bash
   zip milkoutside.zip settings.json`
   ```

5. Repeat for each theme variant

## Installation

1. In Vivaldi, go to Settings > Themes
2. Click "Import Themes" and select one of the zip files
3. The theme will appear in your themes list
4. Click the theme to apply it
