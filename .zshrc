# --- Dotfiles ---

for file in "$HOME"/code/dotfiles/.{aliases,functions,exports}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# --- Keybindings ---

# === Selection Functions ===
# Main function to enable selection and movement
select-and-move() {
  ((REGION_ACTIVE)) || zle set-mark-command
  zle $1
}

# === Widget Definitions ===
# Word and line level selection widgets
for cmd in backward-word forward-word beginning-of-line end-of-line; do
  eval "select-and-$cmd() { select-and-move $cmd }"
  zle -N select-and-$cmd
done

# Character-by-character selection widgets
select-and-backward-char() { select-and-move backward-char }
select-and-forward-char() { select-and-move forward-char }
zle -N select-and-backward-char
zle -N select-and-forward-char

# === Selection Deletion Widget ===
# Widget to handle deleting selected text
delete-selection() {
  if ((REGION_ACTIVE)); then
    # Delete the selected region
    zle kill-region
  else
    # Normal character deletion
    zle delete-char
  fi
}
zle -N delete-selection

# === Key Bindings ===
# Character selection (Shift + Arrow)
bindkey $'\e[1;2D' select-and-backward-char     # Shift+Left
bindkey $'\e[1;2C' select-and-forward-char      # Shift+Right

# Line selection (Shift + Home/End)
bindkey $'\e[1;2H' select-and-beginning-of-line # Shift+Home
bindkey $'\e[1;2F' select-and-end-of-line       # Shift+End

# Selection management
bindkey $'\e' deactivate-region                 # Escape to cancel selection
bindkey "^?" delete-selection                   # Backspace to delete selection

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
