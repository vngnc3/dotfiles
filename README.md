# Dotfiles

Personal configuration files for new systems.

## Installation

Most files should be placed directly in the home directory (`~`).

- `.zshrc`, `.zshenv`, `.tmux.conf`, `.aerospace.toml` → `~`
- `.config/nvim/`, `.config/crush/`, `.config/vdirsyncer/` → `~/.config/`
- `.ssh/config` → `~/.ssh/config`
- `houdini/` → Houdini preferences directory (e.g., `~/Library/Preferences/houdini/XX.X/` on macOS)
- `ghostty/` → `~/Library/Application Support/com.mitchellh.ghostty/`
- `utils/` → any location; `.zshrc` expects it at `~/Work/dotfiles/utils`
- `Brewfile` → run `brew bundle` from the repo root

## Homebrew packages

`Brewfile` snapshots the directly installed formulae, casks, and taps. On a new
machine:

```sh
brew bundle
```

Homebrew resolves dependencies automatically, so only explicitly installed
packages are listed.

## Ghostty

Copy `ghostty/config` to
`~/Library/Application Support/com.mitchellh.ghostty/config`. The
`Scarlet Protocol` theme ships with Ghostty, so no theme file is tracked.
`Berkeley Mono` is a commercial font and must be installed manually; without it,
Ghostty falls back to the system default.

## Shell prompt

The prompt is [Starship](https://starship.rs), installed via Homebrew:

```sh
brew install starship
```

`.zshrc` initializes it with `eval "$(starship init zsh)"`. No `starship.toml`
is tracked — the built-in default configuration is used as-is.

## Contents

- **`.zshrc`** / **`.zshenv`** - Zsh shell configuration
- **`.tmux.conf`** - Tmux terminal multiplexer settings
- **`.aerospace.toml`** - Aerospace window manager configuration (macOS)
- **`.config/nvim/`** - Neovim editor configuration
- **`.config/crush/`** - Crush AI assistant configuration
- **`.config/vdirsyncer/`** - Calendar syncing configuration
- **`.ssh/config`** - SSH client settings
- **`Brewfile`** - Homebrew formulae, casks, and taps (`brew bundle`)
- **`ghostty/`** - Ghostty terminal configuration
- **`houdini/`** - Place in Houdini preferences directory (e.g., `~/Library/Preferences/houdini/XX.X/` on macOS). Contains environment variables and OTL scan paths.
- **`utils/`** - Standalone helper scripts:
  - `batch-rename/` - Batch file renaming helpers
  - `check-missing-frames/` - Missing-frame checker for image sequences
  - `frames-to-video.sh` / `frames-to-video.ps1` - Encode image sequences to video
  - `no-blend1/` - Find and delete Blender `.blend1` backup files

## Placeholders

Anything in angle brackets (e.g. `<EMAIL>`, `<CALENDAR_ID>`) must be filled in
after copying. Credentials are intentionally left blank — keep passwords in the
macOS Keychain or a password manager, never in this repository.
