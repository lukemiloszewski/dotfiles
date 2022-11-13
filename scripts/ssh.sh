#!/usr/bin/env zsh

# generate SSH key for GitHub
ssh-keygen -t ed25519 -C "lukemiloszewski@gmail.com" -f ~/.ssh/id_ed25519

# add to agent
eval "$(ssh-agent -s)"

# create ssh folder
touch ~/.ssh/config
echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config
ssh-add -K ~/.ssh/id_ed25519

# copy public key and add to GitHub - "pbcopy < ~/.ssh/id_ed25519.pub"
