# --- Dotfiles ---

for file in ~/dotfiles/.{aliases,functions,exports}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# --- Keybindings ---

bindkey "[D" backward-word
bindkey "^[[1;5D" backward-word                     # [Ctrl-left] - backward one word
bindkey '^[^[[D' backward-word                      # [Ctrl-left] - backward one word
bindkey "[C" forward-word
bindkey "^[[1;5C" forward-word                      # [Ctrl-right] - forward one word
bindkey '^[^[[C' forward-word                       # [Ctrl-right] - forward one word
bindkey "^[a" beginning-of-line
bindkey '^[[1;3D' beginning-of-line                 # [Alt-left] - beginning of line
bindkey '^[[5D' beginning-of-line                   # [Alt-left] - beginning of line
bindkey "^[e" end-of-line
bindkey '^[[1;3C' end-of-line                       # [Alt-right] - end of line
bindkey '^[[5C' end-of-line                         # [Alt-right] - end of line

# --- Autocomplete ---

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case insensite for lowercase
zstyle ':completion:*' insert-tab pending  # pasting with tabs doesn't perform completion
zstyle ':completion:*' completer _expand _complete _files _correct _approximate  # default to file completion

# --- Plugins ---

plugins=(git z zsh-autosuggestions zsh-syntax-highlighting web-search copybuffer history)

source $ZSH/oh-my-zsh.sh

# --- Python ---

eval "$(pyenv init -)"

# --- Node ---

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# --- Starship ---

eval "$(starship init zsh)"
