# --- Dotfiles ---

for file in "$HOME"/code/dotfiles/.{aliases,functions,exports}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# --- Keybindings ---

# Simple text selection function
select-and-move() {
  ((REGION_ACTIVE)) || zle set-mark-command
  zle $1
}

# Define word-level and line-level selection widgets
for cmd in backward-word forward-word beginning-of-line end-of-line; do
  eval "select-and-$cmd() { select-and-move $cmd }"
  zle -N select-and-$cmd
done

# Assign key bindings with corrected sequences
bindkey $'\e[1;4D' select-and-backward-word       # Option+Shift+Left
bindkey $'\e[1;4C' select-and-forward-word        # Option+Shift+Right
bindkey $'\e[1;2H' select-and-beginning-of-line   # Shift+Home
bindkey $'\e[1;2F' select-and-end-of-line         # Shift+End

# Escape exits selection mode
bindkey $'\e' deactivate-region

# Fix for Delete/Backspace to properly clear selection
delete-selection() {
  # Only delete the region if selection is active
  if ((REGION_ACTIVE)); then
    zle kill-region
  else
    # Otherwise perform normal delete
    zle delete-char
  fi  # Properly closed "if" statement
}
zle -N delete-selection
bindkey "^?" delete-selection      # Backspace
bindkey "^[[3~" delete-selection   # Delete

# Character-by-character selection
select-and-backward-char() { select-and-move backward-char }
select-and-forward-char() { select-and-move forward-char }
zle -N select-and-backward-char
zle -N select-and-forward-char
bindkey $'\e[1;2D' select-and-backward-char     # Shift+Left
bindkey $'\e[1;2C' select-and-forward-char      # Shift+Right

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
