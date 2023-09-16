#!/bin/bash

# Check if the script is being run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Install Zsh if it's not already installed
if ! [ -x "$(command -v zsh)" ]; then
  echo "Installing Zsh..."
  apt update
  apt install -y zsh
fi



# Create a backup directory for existing Zsh configuration files
mkdir -p ~/zsh-backup

# Loop through the Zsh configuration files and backup or remove them
for rc in ~/.zshenv ~/.zprofile ~/.zshrc ~/.zlogin ~/.zlogout ~/.oh-my-zsh; do
  if [ -e "$rc" ]; then
    if [ ! -e ~/zsh-backup/"$(basename "$rc")" ]; then
      cp -r "$rc" ~/zsh-backup/"$(basename "$rc")"
      rm -rf "$rc"
    else
      rm -rf "$rc"
    fi
  fi
done

# Clone Oh My Zsh and Powerlevel10k themes
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Configure Zsh to use Powerlevel10k theme
sed 's|robbyrussell|powerlevel10k/powerlevel10k|' ~/.oh-my-zsh/templates/zshrc.zsh-template > ~/.zshrc

# Set ZDOTDIR and start a new Zsh session
ZDOTDIR=~ exec zsh -i