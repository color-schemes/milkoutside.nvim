#!/bin/bash

# Safari theme installer for macOS

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Check if running on macOS
if [[ "$OS" != "macos" ]]; then
    log "ERROR" "Safari theme can only be applied on macOS"
    exit 1
fi

# Install Safari theme
install_safari() {
    log "INFO" "Installing Safari theme..."
    
    # Safari uses Web Extensions, so we need to create an extension
    local safari_extension_dir="$HOME/Library/Safari/Extensions"
    local safari_extension_name="milkoutside-safari-theme"
    
    if [ ! -d "$safari_extension_dir" ]; then
        log "WARN" "Safari extensions directory not found"
        log "INFO" "Safari theme requires manual setup via Web Extensions"
        show_safari_manual_instructions
        return 1
    fi
    
    # Create Safari Web Extension
    create_safari_extension
}

# Create Safari Web Extension
create_safari_extension() {
    local ext_dir="/tmp/$safari_extension_name"
    mkdir -p "$ext_dir"
    
    log "INFO" "Creating Safari Web Extension..."
    
    # Create manifest.json
    cat > "$ext_dir/manifest.json" << 'EOF'
{
  "manifest_version": 3,
  "name": "MilkOutside Safari Theme",
  "version": "1.0.0",
  "description": "Dark, cosmic-inspired theme based on milkoutside.nvim colorscheme",
  "author": "milkoutside.nvim",
  "homepage_url": "https://github.com/milkoutside/milkoutside.nvim",
  "permissions": [
    "activeTab",
    "storage"
  ],
  "action": {
    "default_title": "MilkOutside Theme"
  },
  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "css": ["styles.css"],
      "js": ["content.js"],
      "run_at": "document_start"
    }
  ],
  "background": {
    "service_worker": "background.js"
  },
  "web_accessible_resources": [
    {
      "resources": ["styles.css"],
      "matches": ["<all_urls>"]
    }
  ]
}
EOF
    
    # Create styles.css
    cat > "$ext_dir/styles.css" << 'EOF'
/* MilkOutside Safari Theme CSS */

/* Dark mode override for all websites */
html, body {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
    filter: invert(0) hue-rotate(0deg) !important;
}

/* Invert back images and videos to maintain original appearance */
img, video, picture, svg, canvas {
    filter: invert(1) hue-rotate(180deg) !important;
}

/* Fix specific elements that shouldn't be inverted */
iframe, embed, object {
    filter: invert(1) hue-rotate(180deg) !important;
}

/* Ensure text remains readable */
*:not(img):not(video):not(picture):not(svg):not(canvas):not(iframe):not(embed):not(object) {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
}

/* Links with MilkOutside accent */
a, a:link, a:visited {
    color: #fda1a0 !important;
    text-decoration: none !important;
}

a:hover {
    color: #e45555 !important;
    text-decoration: underline !important;
}

/* Code blocks */
pre, code, tt {
    background-color: #0d0d0d !important;
    color: #92cf9c !important;
    border: 1px solid #262626 !important;
    padding: 2px 4px !important;
}

/* Selection color */
::selection {
    background-color: #e45555 !important;
    color: #000000 !important;
}

::-moz-selection {
    background-color: #e45555 !important;
    color: #000000 !important;
}

/* Form elements */
input, textarea, select, button {
    background-color: #0d0d0d !important;
    color: #e8e8e8 !important;
    border: 1px solid #262626 !important;
}

input:focus, textarea:focus, select:focus {
    border-color: #fda1a0 !important;
    outline: 1px solid #fda1a0 !important;
}

/* Tables */
table {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
}

th, td {
    border-color: #262626 !important;
    background-color: #000000 !important;
    color: #e8e8e8 !important;
}

/* Remove white backgrounds */
[class*="white"], [class*="light"], [style*="background: white"], [style*="background-color: white"] {
    background-color: #000000 !important;
}

/* Common problematic elements */
.navbar, .navbar-nav, .nav, .header, .top-bar, .menu {
    background-color: #0d0d0d !important;
    color: #e8e8e8 !important;
}

.sidebar, .aside {
    background-color: #0d0d0d !important;
    color: #e8e8e8 !important;
}

.card, .panel, .widget {
    background-color: #0d0d0d !important;
    color: #e8e8e8 !important;
    border: 1px solid #262626 !important;
}
EOF
    
    # Create content.js
    cat > "$ext_dir/content.js" << 'EOF'
// MilkOutside Safari Theme content script

// Function to inject styles if not already applied
function injectStyles() {
    if (document.getElementById('milkoutside-styles')) {
        return; // Already injected
    }
    
    const style = document.createElement('link');
    style.id = 'milkoutside-styles';
    style.rel = 'stylesheet';
    style.type = 'text/css';
    style.href = browser.runtime.getURL('styles.css');
    document.head.appendChild(style);
}

// Inject styles immediately
injectStyles();

// Also inject after DOM is fully loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', injectStyles);
}
EOF
    
    # Create background.js
    cat > "$ext_dir/background.js" << 'EOF'
// MilkOutside Safari Theme background script

browser.action.onClicked.addListener((tab) => {
    browser.tabs.sendMessage(tab.id, { action: 'toggleTheme' });
});

// Listen for tab updates to ensure theme is applied
browser.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (changeInfo.status === 'complete') {
        browser.tabs.sendMessage(tabId, { action: 'applyTheme' });
    }
});
EOF
    
    log "INFO" "Safari Web Extension created at: $ext_dir"
    log "INFO" "To install the Safari extension:"
    log "INFO" "1. Open Safari > Settings > Extensions"
    log "INFO" "2. Enable 'Allow unsigned extensions' in Developer menu"
    log "INFO" "3. Click '+' and select the extension directory"
    log "INFO" "4. Enable the extension"
    
    show_safari_manual_instructions
}

# Show Safari manual instructions
show_safari_manual_instructions() {
    log "INFO" "Manual Safari theme setup:"
    log "INFO" "1. Enable Safari Developer menu: Safari > Settings > Advanced > Show Develop menu"
    log "INFO" "2. Set appearance to Dark: System Settings > Appearance > Dark"
    log "INFO" "3. Use Safari Reader mode for better reading experience"
    log "INFO" "4. Consider using a Safari extension like 'Dark Reader' with custom colors:"
    log "INFO" "   - Background: #000000"
    log "INFO" "   - Text: #e8e8e8" 
    log "INFO" "   - Links: #fda1a0"
    log "INFO" "   - Selection: #e45555"
}

# Run installation
install_safari