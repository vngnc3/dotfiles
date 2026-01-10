# Load existing .zshenv content if needed
if [ -f "$HOME/.zshenv" ]; then
    source "$HOME/.zshenv"
fi 

# ls with highlighting
alias ls='ls -G'

# icloud path
export ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/"

# editor
export EDITOR="/opt/homebrew/bin/nvim"

# pyenv initialization
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
# You might want to add this if you use pyenv-virtualenv
# eval "$(pyenv virtualenv-init -)"

# rsync path 
alias openrsync='/opt/homebrew/bin/rsync'

# bun completions
[ -s "/Users/izzy/.bun/_bun" ] && source "/Users/izzy/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# houdini env
export HOUDINI_PREF='/Users/izzy/Library/Preferences/houdini/21.0/'

# blender
alias blender='/Applications/Blender.app/Contents/MacOS/Blender'

# llama.cpp config
alias llama-serve-hermes-4='llama-server --model /Users/izzy/models/llama-cpp/Mungert_Hermes-4-14B-GGUF_Hermes-4-14B-bf16.gguf --alias hermes-4 --jinja --ctx-size 40960'

# yt-dlp 
alias ytdl-audio='yt-dlp -x --audio-format mp3 --audio-quality 0 --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"'

# pnpm
export PNPM_HOME="/Users/izzy/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# zoxide
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# starship.rs
eval "$(starship init zsh)"

# Text selection keybinding
# Enable text selection with shift+arrows in ZSH prompt
autoload -U select-word-style
select-word-style bash

zle -N select-left-char
zle -N select-right-char  
zle -N select-left-word
zle -N select-right-word
zle -N select-to-start
zle -N select-to-end

function select-left-char() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle backward-char
}

function select-right-char() {
    ((REGION_ACTIVE)) || zle set-mark-command  
    zle forward-char
}

function select-left-word() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle backward-word
}

function select-right-word() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle forward-word  
}

function select-to-start() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle beginning-of-line
}

function select-to-end() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle end-of-line
}

# Bind the selection functions
bindkey '^[[1;2D' select-left-char    # Shift+Left
bindkey '^[[1;2C' select-right-char   # Shift+Right  
bindkey '^[[1;6D' select-left-word    # Shift+Ctrl+Left
bindkey '^[[1;6C' select-right-word   # Shift+Ctrl+Right
bindkey '^[[1;10D' select-to-start    # Shift+Cmd+Left (macOS)
bindkey '^[[1;10C' select-to-end      # Shift+Cmd+Right (macOS)

