// Background script for Safari extension
chrome.runtime.onInstalled.addListener((details) => {
    console.log('MilkOutside Safari extension installed:', details);
    
    // Show notification on installation
    if (chrome.notifications) {
        chrome.notifications.create({
            type: 'basic',
            iconUrl: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><rect fill="%23040607" width="16" height="16"/><rect fill="%2363c3dd" x="2" y="2" width="4" height="4"/></svg>',
            title: 'MilkOutside Theme',
            message: 'Theme installed successfully! Dark mode is now active.'
        });
    }
});

// Handle extension icon clicks
chrome.action.onClicked.addListener((tab) => {
    console.log('MilkOutside icon clicked');
    
    // Could add toggle functionality here
    if (chrome.scripting) {
        chrome.scripting.executeScript({
            target: { tabId: tab.id },
            func: () => {
                document.body.classList.toggle('milkoutside-theme');
                
                // Show temporary indicator
                const indicator = document.createElement('div');
                indicator.style.cssText = `
                    position: fixed;
                    top: 50px;
                    right: 20px;
                    background: ${document.body.classList.contains('milkoutside-theme') ? 'rgb(146, 207, 156)' : 'rgb(99, 195, 221)'};
                    color: rgb(4, 6, 7);
                    padding: 8px 12px;
                    border-radius: 4px;
                    font-size: 12px;
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    z-index: 10000;
                `;
                indicator.textContent = document.body.classList.contains('milkoutside-theme') ? 'Theme ON' : 'Theme OFF';
                
                document.body.appendChild(indicator);
                
                setTimeout(() => {
                    if (indicator.parentNode) {
                        indicator.parentNode.removeChild(indicator);
                    }
                }, 2000);
            }
        });
    }
});