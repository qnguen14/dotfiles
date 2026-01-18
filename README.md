# Personal Hyprland Dotfiles

A personalized, dynamic, and minimal configuration for Arch Linux using Hyprland.
Features **Material You** dynamic theming using `matugen` that automatically generates color schemes from your wallpaper.

## Preview
![Preview](.dotfiles/screenshot.png)

## Packages

| Component | Application |
|-----------|-------------|
| **Window Manager** | [Hyprland](https://hyprland.org/) |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| **Shell** | [Fish](https://fishshell.com/) |
| **Bar** | [Waybar](https://github.com/Alexays/Waybar) |
| **Launcher** | [Fuzzel](https://codeberg.org/dnkl/fuzzel) (Primary) & [Rofi](https://github.com/davatorium/rofi) |
| **Notifications** | [Mako](https://github.com/emersion/mako) |
| **Theming** | [Matugen](https://github.com/InioX/matugen) |
| **System Info** | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) |

## Dependencies

You will need the following packages (names may vary by distro, these are for Arch):

```bash
# Core
sudo pacman -S hyprland kitty fish waybar fuzzel rofi mako fastfetch

# Utilities
sudo pacman -S imagemagick playerctl curl git

# Theming (AUR)
yay -S matugen-bin

