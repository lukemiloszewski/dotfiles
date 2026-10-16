# --- Dotfiles ---

files=(.aliases .exports .zshrc.local)

for file ($files); do
	if [[ -f "$HOME/$file" ]]; then
		source "$HOME/$file"
	fi
done
unset file

# --- Keybindings ---

move-backward-char() { zle backward-char }
move-forward-char()  { zle forward-char }
zle -N move-backward-char
zle -N move-forward-char

for cmd in backward-word forward-word beginning-of-line end-of-line; do
  eval "move-$cmd() { zle $cmd }"
  zle -N move-$cmd
done

bindkey $'\e[1;2D' move-backward-char        # Shift+Left
bindkey $'\e[1;2C' move-forward-char         # Shift+Right
bindkey $'\e[1;2H' move-beginning-of-line    # Shift+Home
bindkey $'\e[1;2F' move-end-of-line          # Shift+End

# --- zsh ---

plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case insensite for lowercase
zstyle ':completion:*' insert-tab pending  # pasting with tabs doesn't perform completion
zstyle ':completion:*' completer _expand _complete _files _correct _approximate  # default to file completion

# --- Rust ---

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# --- Node ---

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export NODE_OPTIONS="--max-old-space-size=2048"

# --- Starship ---

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# --- Entire ---

if command -v entire >/dev/null 2>&1; then
	autoload -Uz compinit && compinit && source <(entire completion zsh)
fi
