// Popup script for Opera theme
document.addEventListener('DOMContentLoaded', function() {
  const toggleBtn = document.getElementById('toggleBtn');
  const status = document.getElementById('status');
  
  chrome.storage.sync.get(['themeEnabled'], (result) => {
    const enabled = result.themeEnabled || false;
    updateUI(enabled);
  });
  
  toggleBtn.addEventListener('click', function() {
    chrome.storage.sync.get(['themeEnabled'], (result) => {
      const currentlyEnabled = result.themeEnabled || false;
      const newEnabled = !currentlyEnabled;
      
      if (newEnabled) {
        // Enable theme
        chrome.theme.update({
          colors: {
            frame: [4, 6, 7],
            frame_inactive: [4, 6, 7],
            toolbar: [0, 0, 0],
            tab_text: [232, 232, 232],
            tab_background_text: [224, 224, 224],
            bookmark_text: [232, 232, 232],
            ntp_background: [4, 6, 7],
            ntp_text: [232, 232, 232],
            ntp_link: [99, 195, 221],
            ntp_header: [232, 232, 232],
            ntp_section: [15, 15, 21],
            ntp_section_text: [232, 232, 232],
            ntp_section_link: [99, 195, 221],
            button_background: [48, 48, 48],
            button_background_hover: [99, 195, 221],
            button_background_active: [99, 195, 221],
            omnibox_background: [0, 0, 0],
            omnibox_text: [232, 232, 232],
            omnibox_selection_background: [99, 195, 221],
            omnibox_selection_text: [4, 6, 7],
            tab_background_text_inactive: [224, 224, 224],
            background_tab: [0, 0, 0],
            background_tab_inactive: [0, 0, 0]
          },
          tints: {
            buttons: [0.39, 0.77, 0.86],
            frame: [-1, -1, -1],
            frame_inactive: [-1, -1, -1],
            background_tab: [-1, -1, -1],
            background_tab_inactive: [-1, -1, -1]
          }
        });
      } else {
        // Disable theme
        chrome.theme.reset();
      }
      
      chrome.storage.sync.set({ themeEnabled: newEnabled });
      updateUI(newEnabled);
    });
  });
  
  function updateUI(enabled) {
    if (enabled) {
      toggleBtn.textContent = 'Disable Theme';
      toggleBtn.classList.add('active');
      status.textContent = 'Theme is currently enabled';
    } else {
      toggleBtn.textContent = 'Enable Theme';
      toggleBtn.classList.remove('active');
      status.textContent = 'Theme is currently disabled';
    }
  }
});