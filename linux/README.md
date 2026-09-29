# Debian Keyboard Shortcuts

To reload your shortcuts run the following

```bash
dconf load /org/gnome/desktop/wm/keybindings/ < gnome-wm-shortcuts.ini
dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < custom-shortcuts.ini
```