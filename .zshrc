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

# --- Starship ---

eval "$(starship init zsh)"
