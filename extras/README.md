# MilkOutside Extras Installation

This directory contains color scheme configurations for various applications.

## 🚀 Quick Install

Use the automated installer to set up all themes at once:

```bash
# From the repository root
./extras/install.sh --all

# Or install specific applications
./extras/install.sh kitty alacritty fish firefox
```

## 📁 Manual Installation

Copy the files to their respective configuration directories:

### Terminal Emulators

| Application | Config Location | File |
|-------------|----------------|-------|
| **Kitty** | `~/.config/kitty/` | `kitty/milkoutside.conf` |
| **Alacritty** | `~/.config/alacritty/` | `alacritty/milkoutside.toml` |
| **WezTerm** | `~/.config/wezterm/` | `wezterm/milkoutside.toml` |
| **Foot** | `~/.config/foot/` | `foot/milkoutside.ini` |
| **Ghostty** | `~/.config/ghostty/` | `ghostty/milkoutside.json` |
| **Terminator** | `~/.config/terminator/` | `terminator/milkoutside.conf` |
| **Tilix** | `~/.config/tilix/` | `tilix/milkoutside.json` |
| **QTerminal** | `~/.config/qterminal/` | `qterminal/milkoutside.colorscheme` |
| **XFCE Terminal** | `~/.config/xfceterm/` | `xfceterm/milkoutside.theme` |
| **ST** | Compile from source | `st/milkoutside.h` |
| **iSH** | `~/.config/ish/` | `ish/milkoutside.json` |

### Shells

| Application | Config Location | File |
|-------------|----------------|-------|
| **Fish** | `~/.config/fish/` | `fish/milkoutside.fish` + `fish_themes/milkoutside.theme` |
| **Eza** | `~/.config/eza/` | `eza/milkoutside.yml` |

### Editors

| Application | Config Location | File |
|-------------|----------------|-------|
| **Helix** | `~/.config/helix/themes/` | `helix/milkoutside.toml` |
| **Vim** | `~/.vim/colors/` | `vim/colors/milkoutside.vim` |
| **Sublime Text** | `~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/` | `sublime/milkoutside.tmTheme` |

### Terminal Multiplexers

| Application | Config Location | File |
|-------------|----------------|-------|
| **Tmux** | `~/.config/tmux/` | `tmux/milkoutside.tmux` |
| **Zellij** | `~/.config/zellij/` | `zellij/milkoutside.kdl` |

### File Managers

| Application | Config Location | File |
|-------------|----------------|-------|
| **Yazi** | `~/.config/yazi/` | `yazi/milkoutside.toml` |
| **LazyGit** | `~/.config/lazygit/` | `lazygit/milkoutside.yml` |
| **Neo-tree** | `~/.config/nvim/` | `neotree/milkoutside.ron` |
| **NvimTree** | `~/.config/nvim/` | `nvimtree/milkoutside.conf` |

### Browsers

| Application | Config Location | File |
|-------------|----------------|-------|
| **Firefox** | `~/.mozilla/firefox/*/chrome/` | `firefox/userChrome.css` |
| **Vivaldi** | Vivaldi settings | `vivaldi/milkoutside.json` |
| **Windows Terminal** | Windows Terminal settings | `windows_terminal/milkoutside.json` |

### Development Tools

| Application | Config Location | File |
|-------------|----------------|-------|
| **FZF** | `~/.config/fzf/` | `fzf/milkoutside.sh` |
| **Delta** | `~/.gitconfig` section | `delta/milkoutside.gitconfig` |
| **Dunst** | `~/.config/dunst/dunstrc.d/` | `dunst/milkoutside.dunstrc` |
| **Aerc** | `~/.config/aerc/` | `aerc/milkoutside.ini` |
| **Zathura** | `~/.config/zathura/` | `zathura/milkoutside.zathurarc` |

### Web Development

| Application | Config Location | File |
|-------------|----------------|-------|
| **Tailwind CSS** | Your CSS file | `tailwindv4/milkoutside.css` |
| **Prism.js** | Your JS file | `prism/milkoutside.js` |

### Communication

| Application | Config Location | File |
|-------------|----------------|-------|
| **Discord** | BetterDiscord plugins | `discord/milkoutside.css` |
| **Slack** | Slack themes | `slack/milkoutside.txt` |
| **Spotify Player** | `~/.config/spotify-player/` | `spotify_player/milkoutside.toml` |

### System Monitoring

| Application | Config Location | File |
|-------------|----------------|-------|
| **Btop** | `~/.config/btop/` | `btop/milkoutside.theme` |

## 🔧 Configuration

### Firefox Setup

For the Firefox theme to work:

1. Open Firefox and go to `about:config`
2. Search for `toolkit.legacyUserProfileCustomizations.stylesheets`
3. Set it to `true`
4. Copy `extras/firefox/userChrome.css` to your Firefox profile's `chrome` directory
5. Restart Firefox

### Kitty Setup

Add to your `kitty.conf`:
```
include milkoutside.conf
```

### Fish Setup

Add to your `config.fish`:
```fish
source ~/.config/fish/functions/_fish_prompt_milkoutside.fish
fish_config theme save MilkOutside
```

### Tmux Setup

Add to your `~/.tmux.conf`:
```
source-file ~/.config/tmux/milkoutside.tmux
```

## 🎨 Color Palette

The MilkOutside color palette includes:

- **Background**: `#040607` (dark)
- **Foreground**: `#e8e8e8` (light)
- **Red**: `#e45555` (your custom red)
- **Green**: `#92cf9c` (soft green)
- **Yellow**: `#f8e063` (warm yellow)
- **Blue**: `#63c3dd` (cool blue)
- **Magenta**: `#e79cfb` (soft magenta)
- **Cyan**: `#7dcfff` (bright cyan)

## 🔄 Updating

To update themes after modifying the main color palette:

```bash
# Re-run the installer
./extras/install.sh --all

# Or manually copy updated files
cp -r extras/* ~/.config/
```

## 🐛 Troubleshooting

- **Backup files** are saved to `~/.config/milkoutside-backup-YYYYMMDD-HHMMSS`
- **Permissions**: Make sure the install script is executable: `chmod +x extras/install.sh`
- **Firefox**: Ensure `toolkit.legacyUserProfileCustomizations.stylesheets` is enabled in `about:config`
- **Terminal emulators**: You may need to restart them for themes to apply

## 📝 Contributing

When adding new extras:
1. Use the current MilkOutside color palette
2. Test your theme works
3. Add it to the `install.sh` script
4. Update this README