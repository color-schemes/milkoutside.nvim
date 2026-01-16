#!/bin/bash

# Safari Extension Builder for MilkOutside
# Builds both v2 and v3 extensions for compatibility

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTRAS_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}Building MilkOutside Safari Extensions...${NC}"
echo

# Check if we're in the right directory
if [ ! -f "$SCRIPT_DIR/milkoutside.css" ]; then
    echo -e "${RED}Error: Must run from the extras/safari directory${NC}"
    exit 1
fi

# Function to build Safari v2 extension
build_v2() {
    echo -e "${BLUE}Building Safari v2 Extension...${NC}"
    
    EXTENSION_NAME="MilkOutside-v2.safariextension"
    rm -rf "$EXTRAS_DIR/$EXTENSION_NAME"
    mkdir -p "$EXTRAS_DIR/$EXTENSION_NAME"

    # Copy necessary files
    cp "$SCRIPT_DIR/manifest.json" "$EXTRAS_DIR/$EXTENSION_NAME/"
    cp "$SCRIPT_DIR/milkoutside.css" "$EXTRAS_DIR/$EXTENSION_NAME/"
    cp "$SCRIPT_DIR/background.js" "$EXTRAS_DIR/$EXTENSION_NAME/"
    cp "$SCRIPT_DIR/popup.html" "$EXTRAS_DIR/$EXTENSION_NAME/"

    # Create Info.plist for Safari v2
    cat > "$EXTRAS_DIR/$EXTENSION_NAME/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>MilkOutside Theme</string>
    <key>CFBundleIdentifier</key>
    <string>com.milkoutside.theme</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.1</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024 MilkOutside Theme</string>
    <key>NSHumanReadableDescription</key>
    <string>Dark theme for Safari using MilkOutside color scheme</string>
    <key>SFSafariWebExtensionConverterVersion</key>
    <string>15.4</string>
</dict>
</plist>
EOF

    echo -e "${GREEN}✓ Safari v2 extension built: $EXTENSION_NAME${NC}"
}

# Function to build Safari v3 extension  
build_v3() {
    echo -e "${BLUE}Building Safari v3 Extension...${NC}"
    
    EXTENSION_NAME="MilkOutside-v3.safariextension"
    rm -rf "$EXTRAS_DIR/$EXTENSION_NAME"
    mkdir -p "$EXTRAS_DIR/$EXTENSION_NAME"

    # Copy necessary files
    cp "$SCRIPT_DIR/manifest-v3.json" "$EXTRAS_DIR/$EXTENSION_NAME/manifest.json"
    cp "$SCRIPT_DIR/milkoutside.css" "$EXTRAS_DIR/$EXTENSION_NAME/"
    cp "$SCRIPT_DIR/background.js" "$EXTRAS_DIR/$EXTENSION_NAME/"
    cp "$SCRIPT_DIR/content.js" "$EXTRAS_DIR/$EXTENSION_NAME/"

    echo -e "${GREEN}✓ Safari v3 extension built: $EXTENSION_NAME${NC}"
}

# Function to provide installation instructions
show_instructions() {
    echo
    echo -e "${CYAN}🚀 Installation Instructions:${NC}"
    echo
    echo -e "${YELLOW}Method 1: Automatic (Safari 16+ on macOS Ventura/Sonoma):${NC}"
    echo -e "${BLUE}1. Open Safari${NC}"
    echo -e "${BLUE}2. Go to Safari > Settings > Extensions${NC}"
    echo -e "${BLUE}3. Turn on 'Allow Unsigned Extensions'${NC}"
    echo -e "${BLUE}4. Double-click either MilkOutside-v2 or MilkOutside-v3 folder${NC}"
    echo -e "${BLUE}5. Enable the extension in Safari Settings${NC}"
    echo
    
    echo -e "${YELLOW}Method 2: Manual Build (All Safari versions):${NC}"
    echo -e "${BLUE}1. Install Xcode Command Line Tools: xcode-select --install${NC}"
    echo -e "${BLUE}2. Enable Developer Menu: Safari > Settings > Advanced > Show Develop menu${NC}"
    echo -e "${BLUE}3. Build extension: xcrun safari-web-extension-converter [folder]${NC}"
    echo -e "${BLUE}4. Enable in Safari Settings > Extensions${NC}"
    echo
    
    echo -e "${YELLOW}Method 3: User Style Sheet (Older Safari):${NC}"
    echo -e "${BLUE}1. Enable Developer Menu${NC}"
    echo -e "${BLUE}2. Copy CSS to: ~/Library/Safari/UserStyleSheet/milkoutside.css${NC}"
    echo -e "${BLUE}3. Activate: Develop > User Style > milkoutside${NC}"
    echo
    
    echo -e "${CYAN}📁 Extension Locations:${NC}"
    echo -e "${GREEN}v2 Extension: $EXTRAS_DIR/MilkOutside-v2.safariextension${NC}"
    echo -e "${GREEN}v3 Extension: $EXTRAS_DIR/MilkOutside-v3.safariextension${NC}"
    echo
    
    # Try to open extensions directory
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${CYAN}📂 Opening extensions folder...${NC}"
        open "$EXTRAS_DIR/"
    fi
}

# Build both versions
build_v2
build_v3

# Show instructions
show_instructions

echo
echo -e "${GREEN}✅ Build Complete!${NC}"
echo -e "${BLUE}Try the v3 extension first, then v2 if v3 doesn't work.${NC}"