// Content script for Safari extension
(function() {
    'use strict';
    
    console.log('MilkOutside Safari theme loaded');
    
    // Add a class to body for theme identification
    document.body.classList.add('milkoutside-theme');
    
    // Create a floating indicator (optional - can be removed if not wanted)
    const indicator = document.createElement('div');
    indicator.style.cssText = `
        position: fixed;
        top: 10px;
        right: 10px;
        background: rgb(99, 195, 221);
        color: rgb(4, 6, 7);
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        z-index: 10000;
        opacity: 0.8;
        pointer-events: none;
    `;
    indicator.textContent = 'MilkOutside';
    
    // Only show indicator if not on sensitive pages
    if (!window.location.hostname.includes('chrome://') && 
        !window.location.hostname.includes('safari://')) {
        document.body.appendChild(indicator);
        
        // Hide after 3 seconds
        setTimeout(() => {
            if (indicator.parentNode) {
                indicator.parentNode.removeChild(indicator);
            }
        }, 3000);
    }
})();