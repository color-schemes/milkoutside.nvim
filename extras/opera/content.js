// Content script for MilkOutside Opera Theme
let styleElement = null;
let isEnabled = true;

// Function to create or remove the style element
function updateTheme(enabled) {
  if (enabled && !styleElement) {
    // Add MilkOutside theming
    styleElement = document.createElement('style');
    styleElement.id = 'milkoutside-theme';
    styleElement.textContent = `
      :root {
        --milkoutside-bg: rgb(4, 6, 7);
        --milkoutside-bg-dark: rgb(0, 0, 0);
        --milkoutside-bg-highlight: rgb(15, 15, 21);
        --milkoutside-bg-medium: rgb(13, 13, 13);
        --milkoutside-fg: rgb(232, 232, 232);
        --milkoutside-accent: rgb(253, 161, 160);
        --milkoutside-accent-bright: rgb(228, 85, 85);
        --milkoutside-green: rgb(146, 207, 156);
        --milkoutside-border: rgb(48, 48, 48);
      }
      
      html, body {
        background-color: var(--milkoutside-bg) !important;
        color: var(--milkoutside-fg) !important;
        color-scheme: dark !important;
      }
      
      a, a:link, a:visited {
        color: var(--milkoutside-accent) !important;
      }
      
      a:hover {
        color: var(--milkoutside-accent-bright) !important;
      }
      
      input, textarea, select, button {
        background-color: var(--milkoutside-bg-medium) !important;
        color: var(--milkoutside-fg) !important;
        border: 1px solid var(--milkoutside-border) !important;
      }
      
      input:focus, textarea:focus, select:focus {
        border-color: var(--milkoutside-accent) !important;
        outline: 1px solid var(--milkoutside-accent) !important;
      }
      
      ::selection {
        background-color: var(--milkoutside-accent) !important;
        color: var(--milkoutside-bg-dark) !important;
      }
      
      .navbar, .navbar-nav, .nav, .header, .top-bar, .menu {
        background-color: var(--milkoutside-bg-medium) !important;
        color: var(--milkoutside-fg) !important;
      }
      
      .sidebar, .aside {
        background-color: var(--milkoutside-bg-medium) !important;
        color: var(--milkoutside-fg) !important;
      }
      
      .card, .panel, .widget {
        background-color: var(--milkoutside-bg-medium) !important;
        color: var(--milkoutside-fg) !important;
        border: 1px solid var(--milkoutside-border) !important;
      }
      
      ::-webkit-scrollbar {
        width: 12px;
        background-color: var(--milkoutside-bg);
      }
      
      ::-webkit-scrollbar-track {
        background-color: var(--milkoutside-bg);
      }
      
      ::-webkit-scrollbar-thumb {
        background-color: var(--milkoutside-border);
        border-radius: 6px;
      }
      
      ::-webkit-scrollbar-thumb:hover {
        background-color: var(--milkoutside-accent);
      }
    `;
    document.head.appendChild(styleElement);
  } else if (!enabled && styleElement) {
    // Remove the MilkOutside theming
    styleElement.remove();
    styleElement = null;
  }
}

// Listen for messages from background script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'enableTheme') {
    isEnabled = true;
    updateTheme(true);
  } else if (request.action === 'disableTheme') {
    isEnabled = false;
    updateTheme(false);
  }
  sendResponse({ success: true });
});

// Initialize theme when content script loads
chrome.storage.sync.get(['themeEnabled'], (result) => {
  isEnabled = result.themeEnabled !== false;
  updateTheme(isEnabled);
});

// Also apply theme immediately for faster loading
updateTheme(true);