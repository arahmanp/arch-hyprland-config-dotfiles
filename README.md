# 🪟 Arch + Hyprland — Automated Desktop

A single command turns a **fresh Arch Linux install** into a complete, beautiful,
ready-to-use **Hyprland** desktop. Tuned for **Intel integrated graphics**.
No post-install fiddling — reboot, log in, and everything works.

> Everything is themed with **Catppuccin Mocha**, uses native Wayland tools where
> possible, and falls back gracefully when an optional component can't be installed.

---

## ✨ What you get

| Area | Tool |
|------|------|
| Compositor | **Hyprland** (rounded corners, blur, smooth animations) |
| Login manager | **SDDM** + Catppuccin theme |
| Status bar | **Waybar** (workspaces, tray, network, BT, audio, battery, CPU/RAM, power) |
| App launcher | **fuzzel** (native Wayland) |
| Notifications | **swaync** (with a control center + media controls) |
| Lock / idle | **hyprlock** + **hypridle** |
| Wallpaper | **hyprpaper** + random-wallpaper script |
| Terminal | **kitty** |
| File manager | **Thunar** (archive, volume mgmt, thumbnails) |
| Audio | **PipeWire** + WirePlumber + pavucontrol |
| On-screen display | **SwayOSD** (volume / brightness / caps-lock popups) |
| Screenshots | **grim** + **slurp** + **swappy** |
| Clipboard history | **cliphist** (`SUPER+V`) |
| Power menu | **wlogout** (with fuzzel fallback) |
| Network / Bluetooth | NetworkManager + Blueman applets |
| Polkit / secrets | hyprpolkitagent + gnome-keyring |
| Browser & media | **Firefox**, **mpv**, **imv**, **Evince**, **Mousepad** |
| Theming | Catppuccin GTK · Papirus-Dark icons · Bibata cursor · Kvantum (Qt) |
| Shell | **zsh** + **oh-my-zsh** + **powerlevel10k** (pre-configured, no wizard) |
| Shell comfort | eza · bat · fzf · zoxide · fastfetch · btop (starship kept for bash) |
| Intel GPU | mesa · vulkan-intel · **intel-media-driver** (VA-API, `iHD`) |

---

## 🚀 Install

> **Prerequisites:** a finished Arch install, a normal user in the `wheel` group
> with `sudo`, and a working internet connection. Run as your **user, not root**.

```bash
# 1. Clone the dotfiles + installer from GitHub:
git clone https://github.com/arahmanp/arch-hyprland-config-dotfiles.git
cd arch-hyprland-config-dotfiles

# 2. Run it:
chmod +x install.sh
./install.sh
```

### Options

```
./install.sh [options]
  -y, --yes          Unattended (assume "yes" to prompts)
      --no-aur       Skip AUR packages / installing an AUR helper
      --skip-update  Skip the initial full system upgrade
      --skip-mirrors Don't refresh the pacman mirrorlist with reflector
  -h, --help         Show help
```

When it finishes:

```bash
sudo reboot
```

At the **SDDM** login screen, make sure the session selector (top-left) says
**Hyprland**, then log in. Press **`SUPER + F1`** for the keybinding cheat-sheet.

---

## ⌨️ Key bindings (the essentials)

`SUPER` (the Windows/Meta key) is the modifier. Full list: **`SUPER + F1`**.

| Keys | Action |
|------|--------|
| `SUPER + Return` | Terminal |
| `SUPER + D` / `SUPER + Space` | App launcher |
| `SUPER + E` | File manager |
| `SUPER + B` | Browser |
| `SUPER + Q` | Close window |
| `SUPER + V` | Clipboard history |
| `SUPER + L` | Lock screen |
| `SUPER + N` | Notification panel |
| `SUPER + SHIFT + E` | Power menu |
| `SUPER + SHIFT + W` | Random wallpaper |
| `SUPER + F` | Fullscreen |
| `SUPER + SHIFT + Space` | Toggle floating |
| `SUPER + Arrows` | Move focus |
| `SUPER + SHIFT + Arrows` | Move window |
| `SUPER + CTRL + Arrows` | Resize window |
| `SUPER + 1…0` | Switch workspace |
| `SUPER + SHIFT + 1…0` | Send window to workspace |
| `SUPER + S` | Scratchpad |
| `Print` | Region screenshot → clipboard |
| `SHIFT + Print` | Region → annotate (swappy) |
| `SUPER + Print` | Full-screen screenshot |
| Volume/Brightness/Media keys | With on-screen display |

---

## 🛠️ Customizing

Everything lives in `~/.config`. The Hyprland config is split for clarity:

```
~/.config/hypr/
├── hyprland.conf            # sources the parts below
├── hyprlock.conf            # lock screen
├── hypridle.conf            # idle/sleep timings
├── hyprpaper.conf           # wallpaper daemon
├── conf/
│   ├── env.conf             # environment variables (incl. Intel VA-API)
│   ├── monitors.conf        # ← edit for resolution / scaling / multi-monitor
│   ├── looknfeel.conf       # gaps, borders, blur, animations
│   ├── input.conf           # keyboard layout, touchpad, gestures
│   ├── autostart.conf       # exec-once apps
│   ├── windowrules.conf     # per-app rules
│   └── keybinds.conf        # ← edit your shortcuts here
└── scripts/                 # wallpaper / screenshot / powermenu / etc.
```

Common tweaks:

- **Monitor resolution / scaling / multi-monitor** → `conf/monitors.conf`
  (run `hyprctl monitors all` to see names/modes).
- **Keyboard layout** → `conf/input.conf` (`kb_layout`).
- **Personal overrides** → create `~/.config/hypr/conf/custom.conf` and
  uncomment its `source =` line at the bottom of `hyprland.conf`.
- **GTK look** → run `nwg-look`. **Qt look** → run `kvantummanager` / `qt6ct`.
- **Disable auto-suspend** (desktops) → comment the last `listener` block in
  `hypridle.conf`.
- After edits: `hyprctl reload` or **`SUPER + SHIFT + R`**.

Drop your own wallpapers into `~/Pictures/Wallpapers` — `SUPER + SHIFT + W`
cycles through them.

### ℹ️ Config format & Lua migration (Hyprland 0.55+)

Arch currently ships **Hyprland 0.55**, which added a **Lua** config format and
**deprecated** the classic *hyprlang* (`.conf`) format used here. This is **not a
problem today**: Hyprland only loads `hyprland.lua` if it exists — since this
setup ships `hyprland.conf` (and no `.lua`), it is loaded normally, exactly as
before. hyprlang is supported for a few more releases.

When you eventually want to switch to Lua:
- Read the announcement: <https://hypr.land/news/26_lua/>
- Use the official converters:
  [in-browser / CLI](https://github.com/EIonTusk/hyprlang2lua) ·
  [hyprrulefix (rules)](https://itsohen.github.io/hyprrulefix/)
- Generate a fresh Lua starter by temporarily moving `~/.config/hypr/hyprland.conf`
  aside and launching Hyprland once.

Until then, keep editing the `.conf` files — everything works.

---

### 🐚 Shell (zsh + oh-my-zsh + powerlevel10k)

The installer sets **zsh** as your default shell and wires up **oh-my-zsh** with
the **powerlevel10k** prompt — all **pre-configured**, so the `p10k configure`
wizard never appears. It activates at your next login (kitty uses your login
shell automatically).

- Config files: `~/.zshrc` (oh-my-zsh, plugins, aliases) and `~/.p10k.zsh` (prompt).
- Plugins enabled: `git`, `sudo`, `archlinux`, `zsh-autosuggestions`,
  `zsh-syntax-highlighting` (the last two come from official packages and are
  symlinked into oh-my-zsh, so `pacman -Syu` keeps them current).
- Restyle the prompt any time with `p10k configure` (rewrites `~/.p10k.zsh`).
- Prefer a different look? Edit `ZSH_THEME` in `~/.zshrc`.
- Want to stay on bash instead? `chsh -s /bin/bash` — the installer also left an
  enhanced `~/.bashrc` (starship prompt + the same aliases).
- The prompt needs the bundled **JetBrainsMono Nerd Font** (installed) — already
  the default in kitty, so icons render correctly out of the box.

## 🩺 Troubleshooting

- **`./install.sh: bad interpreter` / `$'\r'` errors** — the file has Windows
  line endings. Run `sed -i 's/\r$//' install.sh` (or the `find` one-liner above).
- **Login screen looks plain** — the Catppuccin SDDM theme download was skipped
  (offline at install time). It's cosmetic; everything still works. Re-run the
  installer when online, or pick a theme in SDDM's config.
- **An AUR package failed** (e.g. GTK/cursor theme) — non-fatal; the installer
  uses a built-in fallback (Adwaita-dark / Adwaita cursor). Install it later with
  `paru -S <pkg>`.
- **Screen sharing in browsers** — works via `xdg-desktop-portal-hyprland`
  (already installed). Use a Wayland-native browser/window.
- **No sound** — check `pavucontrol` (output device) and that `wireplumber` is
  running (`systemctl --user status wireplumber`).
- **Hardware video acceleration** — verify with `vainfo` (should list the iHD
  driver and H.264/HEVC profiles).

---

## 📦 Package lists

- `packages/pacman.txt` — official-repo packages (`pacman -S --needed`).
- `packages/aur.txt` — AUR packages (installed individually; non-fatal).

Edit these before running to add/remove software.

---

## ♻️ Uninstall / revert

Your previous configs are backed up to `~/.config-backup-<timestamp>/`.
To revert a specific app, move its folder back from there. The installed
packages can be removed with `pacman -Rns <name>` as desired.

---

Made to be **comfortable out of the box**. Enjoy your new desktop! 🎉
