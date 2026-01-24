#!/bin/bash

# Opera theme installer

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get Opera directory
get_opera_dir() {
    local opera_dir=""
    
    case "$OS" in
        "macos")
            if [ -d "/Applications/Opera.app" ]; then
                opera_dir="/Applications/Opera.app"
            elif [ -d "$HOME/Applications/Opera.app" ]; then
                opera_dir="$HOME/Applications/Opera.app"
            fi
            ;;
        "linux")
            if [ -d "/usr/share/opera" ]; then
                opera_dir="/usr/share/opera"
            elif [ -d "/opt/opera" ]; then
                opera_dir="/opt/opera"
            elif [ -d "$HOME/.local/share/opera" ]; then
                opera_dir="$HOME/.local/share/opera"
            fi
            ;;
        "windows")
            if [ -d "$PROGRAMFILES\\Opera" ]; then
                opera_dir="$PROGRAMFILES\\Opera"
            elif [ -d "$PROGRAMFILES (x86)\\Opera" ]; then
                opera_dir="$PROGRAMFILES (x86)\\Opera"
            elif [ -d "$LOCALAPPDATA\\Opera Software" ]; then
                opera_dir="$LOCALAPPDATA\\Opera Software"
            fi
            ;;
    esac
    
    echo "$opera_dir"
}

# Get Opera profile directory
get_opera_profile() {
    local opera_profile=""
    
    case "$OS" in
        "macos")
            opera_profile="$HOME/Library/Application Support/com.operasoftware.Opera"
            if [ ! -d "$opera_profile" ]; then
                opera_profile="$HOME/Library/Application Support/Opera"
            fi
            ;;
        "linux")
            opera_profile="$HOME/.config/opera"
            ;;
        "windows")
            opera_profile="$APPDATA\\Opera Software\\Opera Stable"
            ;;
    esac
    
    echo "$opera_profile"
}

# Install Opera theme
install_opera() {
    local theme_file="$REPO_ROOT/extras/opera/milkoutside.css"
    local opera_dir=$(get_opera_dir)
    local opera_profile=$(get_opera_profile)
    
    if [ ! -f "$theme_file" ]; then
        log "ERROR" "Opera theme file not found"
        return 1
    fi
    
    if [ -z "$opera_dir" ]; then
        log "ERROR" "Opera installation not found"
        return 1
    fi
    
    if [ -z "$opera_profile" ]; then
        log "ERROR" "Opera profile directory not found"
        return 1
    fi
    
    log "INFO" "Found Opera installation: $opera_dir"
    log "INFO" "Found Opera profile: $opera_profile"
    
    # Install Opera UI theme (new theming engine)
    install_opera_ui_theme
    
    # Install user CSS for web content
    install_opera_css_theme
    
    # Create Opera extension for web content theming
    create_opera_extension
}

# Install Opera UI theme
install_opera_ui_theme() {
    local opera_profile=$(get_opera_profile)
    local theme_dir="$opera_profile/Themes"
    
    if [ ! -d "$theme_dir" ]; then
        mkdir -p "$theme_dir"
    fi
    
    # Install theme file
    local theme_file="$theme_dir/MilkOutside.theme"
    if install_file "$REPO_ROOT/extras/opera/milkoutside.theme" "$theme_file" "Opera UI theme"; then
        log "INFO" "Opera UI theme installed"
        log "INFO" "To activate the browser UI theme:"
        log "INFO" "1. Open Opera"
        log "INFO" "2. Go to opera://settings/appearance"
        log "INFO" "3. Click 'Add theme' or select 'MilkOutside' from themes"
        log "INFO" "4. Apply the theme"
    fi
}

# Install Opera CSS theme
install_opera_css_theme() {
    local opera_profile=$(get_opera_profile)
    local css_dir="$opera_profile/Extensions"
    
    if [ ! -d "$css_dir" ]; then
        mkdir -p "$css_dir"
    fi
    
    # Install user CSS file
    local css_file="$css_dir/milkoutside.css"
    if install_file "$REPO_ROOT/extras/opera/milkoutside.css" "$css_file" "Opera CSS theme"; then
        log "INFO" "Opera CSS theme installed"
        log "INFO" "Enable custom CSS in Opera:"
        log "INFO" "1. Go to opera://flags"
        log "INFO" "2. Search for 'User CSS'"
        log "INFO" "3. Enable 'User CSS for WebUI'"
        log "INFO" "4. Restart Opera"
    fi
}

# Create Opera extension
create_opera_extension() {
    local ext_dir="/tmp/milkoutside-opera-extension"
    mkdir -p "$ext_dir"
    
    log "INFO" "Creating Opera extension..."
    
    # Copy existing opera extension files
    if [ -d "$REPO_ROOT/extras/opera" ]; then
        cp -r "$REPO_ROOT/extras/opera"/* "$ext_dir/"
    fi
    
    # Update manifest to remove unsupported theme API for Opera
    cat > "$ext_dir/manifest.json" << 'EOF'
{
  "manifest_version": 3,
  "name": "MilkOutside Theme",
  "version": "2.0",
  "description": "MilkOutside dark theme for Opera - Updated for new theming engine",
  "permissions": [
    "tabs",
    "storage",
    "activeTab"
  ],
  "host_permissions": [
    "<all_urls>"
  ],
  "background": {
    "service_worker": "background.js"
  },
  "action": {
    "default_popup": "popup.html",
    "default_title": "MilkOutside Theme"
  },
  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "css": ["theme.css"],
      "run_at": "document_start",
      "all_frames": true
    }
  ],
  "icons": {
    "16": "icons/icon16.png",
    "48": "icons/icon48.png",
    "128": "icons/icon128.png"
  },
  "web_accessible_resources": [
    {
      "resources": ["theme.css"],
      "matches": ["<all_urls>"]
    }
  ]
}
EOF
    
    # Create styles.css
    cat > "$ext_dir/styles.css" << 'EOF'
/* MilkOutside Opera Theme CSS */

/* Dark mode override for all websites */
html, body {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
    background-image: none !important;
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

/* Common UI elements */
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

/* Remove white backgrounds */
[class*="white"], [class*="light"], [style*="background: white"], [style*="background-color: white"] {
    background-color: #000000 !important;
}

/* Scrollbar */
::-webkit-scrollbar {
    width: 12px;
    background-color: #000000;
}

::-webkit-scrollbar-track {
    background-color: #000000;
}

::-webkit-scrollbar-thumb {
    background-color: #262626;
    border-radius: 6px;
}

::-webkit-scrollbar-thumb:hover {
    background-color: #e45555;
}

/* Opera-specific elements */
.speeddial { /* Opera Speed Dial */
    background-color: #000000 !important;
}

.speeddial .tab {
    background-color: #0d0d0d !important;
    border: 1px solid #262626 !important;
}

.speeddial .tab:hover {
    border-color: #fda1a0 !important;
}

/* Opera sidebar */
._sidebar {
    background-color: #0d0d0d !important;
    color: #e8e8e8 !important;
}

/* Opera extensions page */
.extensions-page {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
}

/* Opera settings page */
.settings-page {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
}

.settings-page .form-control {
    background-color: #0d0d0d !important;
    color: #e8e8e8 !important;
    border: 1px solid #262626 !important;
}
EOF
    
    # Create background.js
    cat > "$ext_dir/background.js" << 'EOF'
// MilkOutside Opera Theme background script

chrome.action.onClicked.addListener((tab) => {
    chrome.tabs.sendMessage(tab.id, { action: 'toggleTheme' });
});

// Listen for tab updates to ensure theme is applied
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (changeInfo.status === 'complete') {
        chrome.tabs.sendMessage(tabId, { action: 'applyTheme' });
    }
});

// Apply theme on startup
chrome.runtime.onStartup.addListener(() => {
    chrome.tabs.query({}, (tabs) => {
        tabs.forEach(tab => {
            chrome.tabs.sendMessage(tab.id, { action: 'applyTheme' });
        });
    });
});
EOF
    
    # Create content script
    cat > "$ext_dir/content.js" << 'EOF'
// MilkOutside Opera Theme content script

// Function to inject styles if not already applied
function injectStyles() {
    if (document.getElementById('milkoutside-styles')) {
        return; // Already injected
    }
    
    const style = document.createElement('link');
    style.id = 'milkoutside-styles';
    style.rel = 'stylesheet';
    style.type = 'text/css';
    style.href = chrome.runtime.getURL('styles.css');
    document.head.appendChild(style);
}

// Inject styles immediately
injectStyles();

// Also inject after DOM is fully loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', injectStyles);
}

// Handle messages from background script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'applyTheme' || request.action === 'toggleTheme') {
        injectStyles();
        sendResponse({ success: true });
    }
});
EOF
    
    log "INFO" "Opera extension created at: $ext_dir"
    log "INFO" "To install Opera extension:"
    log "INFO" "1. Open Opera"
    log "INFO" "2. Go to opera://extensions"
    log "INFO" "3. Enable 'Developer mode'"
    log "INFO" "4. Click 'Load unpacked'"
    log "INFO" "5. Select the extension directory: $ext_dir"
    log "INFO" "6. Enable the extension"
    
    show_opera_manual_instructions
}

# Show Opera manual instructions
show_opera_manual_instructions() {
    log "INFO" "Additional Opera theme setup:"
    log "INFO" "1. Set appearance to Dark: opera://settings/appearance"
    log "INFO" "2. Enable dark mode for web pages: opera://settings/appearance"
    log "INFO" "3. Custom CSS file: $opera_profile/Extensions/milkoutside.css"
    log "INFO" "4. Enable User CSS flags: opera://flags#user-css"
}

# Create Opera CSS file
create_opera_css() {
    local css_dir="$REPO_ROOT/extras/opera"
    mkdir -p "$css_dir"
    
    if [ ! -f "$css_dir/milkoutside.css" ]; then
        cat > "$css_dir/milkoutside.css" << 'EOF'
/* MilkOutside Opera Theme - Custom CSS */

/* Opera browser UI elements */
.o-browser-toolbar {
    background-color: #0d0d0d !important;
}

.o-address-field {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
    border: 1px solid #262626 !important;
}

.o-tab {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
}

.o-tab.is-active {
    background-color: #0d0d0d !important;
    color: #fda1a0 !important;
}

.o-tab:hover {
    background-color: #262626 !important;
}

.o-bookmark-bar {
    background-color: #0d0d0d !important;
}

.o-sidebar {
    background-color: #0d0d0d !important;
    color: #e8e8e8 !important;
}

/* Speed Dial */
.speeddial {
    background-color: #000000 !important;
}

.speeddial-item {
    background-color: #0d0d0d !important;
    border: 1px solid #262626 !important;
    color: #e8e8e8 !important;
}

.speeddial-item:hover {
    border-color: #fda1a0 !important;
}

/* Settings pages */
.settings-content {
    background-color: #000000 !important;
    color: #e8e8e8 !important;
}

.settings-form {
    background-color: #000000 !important;
}

.form-input {
    background-color: #0d0d0d !important;
    color: #e8e8e8 !important;
    border: 1px solid #262626 !important;
}

.form-input:focus {
    border-color: #fda1a0 !important;
}

/* Buttons */
.button-primary {
    background-color: #e45555 !important;
    color: #000000 !important;
    border: none !important;
}

.button-secondary {
    background-color: #262626 !important;
    color: #e8e8e8 !important;
    border: 1px solid #404040 !important;
}

/* Extensions page */
.extensions-grid {
    background-color: #000000 !important;
}

.extension-card {
    background-color: #0d0d0d !important;
    border: 1px solid #262626 !important;
    color: #e8e8e8 !important;
}

/* Context menus */
.context-menu {
    background-color: #0d0d0d !important;
    border: 1px solid #262626 !important;
    color: #e8e8e8 !important;
}

.context-menu-item {
    background-color: transparent !important;
    color: #e8e8e8 !important;
}

.context-menu-item:hover {
    background-color: #e45555 !important;
    color: #000000 !important;
}
EOF
    fi
}

# Run installation
create_opera_css
install_opera