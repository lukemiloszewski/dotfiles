# --- Dotfiles ---

for file in "$HOME"/code/dotfiles/.{aliases,functions,exports}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

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

# --- Autocomplete ---

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case insensite for lowercase
zstyle ':completion:*' insert-tab pending  # pasting with tabs doesn't perform completion
zstyle ':completion:*' completer _expand _complete _files _correct _approximate  # default to file completion

# --- Plugins ---

plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# --- Node ---

# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# --- Starship ---

eval "$(starship init zsh)"
