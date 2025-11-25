# KDE → tinty auto-sync plugin (ZLE-safe, debounced, race-free)

# Only run in Konsole
if [[ -z "$KONSOLE_VERSION" && "$TERM" != xterm-kde* ]]; then
  return
fi

# Safe initialization once ZLE is active & PATH is ready
autoload -Uz add-zle-hook-widget

kde_tinty_zle_init() {
  # Prevent duplicates - only run once per shell session
  if [[ -n "$KDE_TINTY_WATCHER_RUNNING" ]]; then
    return 0
  fi
  export KDE_TINTY_WATCHER_RUNNING=1

  # Remove the hook so it doesn't run again
  add-zle-hook-widget -d zle-line-init kde_tinty_zle_init

  # Resolve binaries AFTER PATH is ready
  local KREAD=$(command -v kreadconfig6)
  local DBUSM=$(command -v dbus-monitor)
  local TINTY=$(command -v tinty)

  # If anything is missing, bail silently
  [[ -z "$KREAD" || -z "$DBUSM" || -z "$TINTY" ]] && return 0

  # User-overridable theme names
  local ZSH_TINTY_LIGHT="${ZSH_TINTY_LIGHT:-base16-ia-light}"
  local ZSH_TINTY_DARK="${ZSH_TINTY_DARK:-base16-ia-dark}"

  # Debounced tinty apply (race-safe)
  local debounce_apply_tinty() {
    (
      sleep 0.2

      local lockfile="/tmp/kde-tinty.lock"
      {
        flock -n 9 || exit 0  # If another tab is applying, skip

        local scheme desired
        scheme="$("$KREAD" --file kdeglobals --group General --key ColorScheme)"

        if [[ "$scheme" =~ [Dd]ark ]]; then
          desired="$ZSH_TINTY_DARK"
        else
          desired="$ZSH_TINTY_LIGHT"
        fi

        "$TINTY" apply "$desired" 2>/dev/null
      } 9>"$lockfile"
    ) &!
  }

  # Initial application (safe because ZLE is ready)
  debounce_apply_tinty

  # DBus watcher — debounced, safe for ZLE
  # Run completely silently with setopt LOCAL_OPTIONS to avoid job messages
  {
    setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR
    {
      "$DBUSM" --session "type='signal',interface='org.kde.KWin'" |
      while read -r line; do
        if [[ "$line" == *"colorsChanged"* || "$line" == *"reloadConfig"* ]]; then
          debounce_apply_tinty
        fi
      done
    } >/dev/null 2>&1 &
    KDE_TINTY_WATCHER_PID=$!
    disown
  }

  # Clean up on shell exit
  kde_tinty_cleanup() {
    [[ -n "$KDE_TINTY_WATCHER_PID" ]] && kill "$KDE_TINTY_WATCHER_PID" 2>/dev/null
  }

  add-zsh-hook zshexit kde_tinty_cleanup

  return 0
}

# Run watcher only after ZLE has fully initialized (cursor is set, prompt ready)
add-zle-hook-widget zle-line-init kde_tinty_zle_init
