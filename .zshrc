# --- Dotfiles ---

files=(.aliases .exports .functions)

for file ($files); do
	if [[ -f "$HOME/$file" ]]; then
		source "$HOME/$file"
	fi
done
unset file

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
