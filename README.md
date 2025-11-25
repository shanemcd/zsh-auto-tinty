# zsh-kde-tinty

> Auto-sync Konsole’s color scheme with KDE’s light/dark mode using `tinty`.

`zsh-kde-tinty` is a small Oh My Zsh–style plugin that watches KDE Plasma’s theme changes over D-Bus and updates your Konsole color scheme via [`tinty`](https://github.com/gtramontina/tinty), **per tab**, without breaking ZLE, fzf, or your prompt.

It is designed for:

- KDE Plasma (5/6)
- Konsole
- Oh My Zsh (or any Zsh plugin manager)
- People who like auto light/dark switching and consistent terminal themes

---

## Why this exists

KDE Plasma can automatically switch between light and dark color schemes based on time of day or a schedule. Konsole has its own color schemes, and they don’t follow Plasma’s light/dark mode automatically.

This plugin:

- Listens to KDE’s D-Bus signals (`colorsChanged`, `reloadConfig`)
- Reads the active KDE color scheme via `kreadconfig6`
- Maps it to a **light** or **dark** `tinty` theme
- Applies the appropriate Konsole colorscheme with `tinty apply`
- Runs inside each Konsole tab's Zsh session (required for tinty to work)
- Uses ZLE-safe hooks, debouncing, and a simple lock to avoid race conditions

You get:

- Seamless KDE → Konsole theme syncing
- No cursor glitches
- No broken ZLE widgets
- No runaway background jobs

---

## Features

- 🌓 Automatic light/dark sync with KDE's theme
- 🎨 Konsole theming via `tinty` (Base16 or custom themes)
- 🧠 Per-tab watcher
- 🛡 ZLE-safe initialization
- 🔁 Debounced & locked tinty calls
- ⚙️ Customizable theme mapping
- 💼 Tested with Oh My Zsh (should work with other Zsh plugin managers)

---

## Requirements

- Zsh
- Konsole
- KDE Plasma (with light/dark switching)
- `kreadconfig6`
- `dbus-monitor`
- `tinty`
- `flock`

Ensure Konsole color schemes live in:

```
~/.local/share/konsole/
```

And `konsoleprofile` must be installed (usually via `kde-cli-tools`).

---

## Installation

### Oh My Zsh

```bash
git clone https://github.com/shanemcd/zsh-kde-tinty   ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/kde-tinty
```

Then enable in `~/.zshrc`:

```zsh
plugins+=(kde-tinty)
```

Reload:

```bash
exec zsh
```

---

## Configuration

In your `~/.zshrc`:

```zsh
export ZSH_TINTY_LIGHT="base16-ia-light"
export ZSH_TINTY_DARK="base16-ia-dark"
```

Optional debug:

```zsh
export ZSH_TINTY_LOG=1
```

---

## How it works

### 1. Only activates in Konsole
Avoids running watchers in other terminals.

### 2. ZLE-safe initialization
Uses `zle-line-init` so cursor and widgets are stable.

### 3. D-Bus watcher
Monitors KDE signals for theme changes.

### 4. Debouncing
KDE fires multiple events → plugin waits 200ms and applies once.

### 5. Locking
Ensures only one tab writes to Konsole's scheme files.

### 6. Light/dark mapping
Simple scheme-name detection; easy to extend.

---

## Troubleshooting

### `os error 39: Directory not empty`
Solved by plugin’s debounce + lock system.

### Missing commands
Verify:

```bash
command -v tinty
command -v kreadconfig6
command -v dbus-monitor
```

### Cursor disappears
Ensure you're running the latest version with ZLE-safe initialization.

---

## Repository Best Practices

- README with install & config instructions
- MIT license
- Standard plugin filename: `kde-tinty.plugin.zsh`
- GitHub-friendly structure:
  ```
  zsh-kde-tinty/
    README.md
    LICENSE
    kde-tinty.plugin.zsh
  ```
- Optional: issue template, PR template, changelog
- Tag versions (`v0.x.x`)

---

## Contributing

- PRs welcome  
- Keep plugin lightweight and ZLE-safe  
- Open issues for new terminals or color detection enhancements  

---

## License

MIT

