// Background script for MilkOutside Opera Theme
// Opera doesn't support theme API, so we rely on CSS content scripts

// Toggle theme on/off
chrome.action.onClicked.addListener((tab) => {
  chrome.storage.sync.get(['themeEnabled'], (result) => {
    const enabled = result.themeEnabled !== false; // Default to enabled
    
    if (enabled) {
      // Disable theme
      chrome.storage.sync.set({ themeEnabled: false });
      chrome.tabs.sendMessage(tab.id, { action: 'disableTheme' }).catch(() => {});
    } else {
      // Enable theme
      chrome.storage.sync.set({ themeEnabled: true });
      chrome.tabs.sendMessage(tab.id, { action: 'enableTheme' }).catch(() => {});
    }
    
    // Notify all tabs to update theming
    chrome.tabs.query({}, (tabs) => {
      tabs.forEach(tab => {
        chrome.tabs.sendMessage(tab.id, { 
          action: enabled ? 'disableTheme' : 'enableTheme' 
        }).catch(() => {
          // Ignore errors for tabs that don't have content script
        });
      });
    });
  });
});

// Initialize theme on startup
chrome.runtime.onInstalled.addListener(() => {
  chrome.storage.sync.set({ themeEnabled: true });
});

// Handle tab updates to ensure content script is active
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete' && tab.url) {
    chrome.storage.sync.get(['themeEnabled'], (result) => {
      const enabled = result.themeEnabled !== false;
      if (enabled) {
        chrome.tabs.sendMessage(tabId, { action: 'enableTheme' }).catch(() => {
          // Content script not ready, will be injected automatically
        });
      }
    });
  }
});