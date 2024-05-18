#!/bin/bash

# Check if the script is being run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Define color codes
# RED='\033[0;31m'
GREEN='\033[0;32m'
# YELLOW='\033[0;33m'
RESET='\033[0m'

function log() {
  echo -e "[init] $*"
}

# Install Zsh if it's not already installed
if ! [ -x "$(command -v zsh)" ]; then
  echo "Installing Zsh..."
  apt update
  apt install -y zsh
fi

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

# Function to check if a package is installed
function is_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -c "ok installed"
}

# Install fontconfig and unzip if they are not already installed
if [ "$(is_installed fontconfig)" -eq 0 ]; then
  log "${GREEN}Installing fontconfig${RESET}"
  apt install fontconfig -y
else
  log "${GREEN}fontconfig is already installed${RESET}"
fi

if [ "$(is_installed unzip)" -eq 0 ]; then
  log "${GREEN}Installing unzip${RESET}"
  apt install unzip -y
else
  log "${GREEN}unzip is already installed${RESET}"
fi

# Check if fonts are already installed
if ls /usr/share/fonts/*.ttf 1> /dev/null 2>&1; then
  log "${GREEN}Fonts are already installed, skipping download.${RESET}"
else
  mkdir cascadiacode && cd cascadiacode || exit

  log "${GREEN}Installing CascadiaCode font${RESET}"

  wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip

  unzip CascadiaCode.zip

  sudo mv ./*.ttf /usr/share/fonts
  log "${GREEN}Moved downloaded fonts to /usr/share/fonts${RESET}"

  fc-cache -fv

  cd ..

  log "${GREEN}Removed workdir cascadiacode${RESET}"
  rm -rf cascadiacode
fi

sudo -u dmt bash << 'EOF'
curl -LJO https://raw.githubusercontent.com/supramaxis/scripts/main/customization/.zshrc
echo -e "[init] \033[0;32mDownloading .zshrc\033[0m"

EOF

# Check the installed version of lsd
desired_version="1.1.2"
installed_version=$(dpkg-query -W -f='${Version}' lsd 2>/dev/null)

if [ $? -eq 0 ]; then
  if dpkg --compare-versions "$installed_version" "ge" "$desired_version"; then
    log "${GREEN}lsd $installed_version is already installed and is up-to-date.${RESET}"
    return
  else
    log "${GREEN}Upgrading lsd to version $desired_version.${RESET}"
    wget https://github.com/lsd-rs/lsd/releases/download/v1.1.2/lsd-musl_1.1.2_arm64.deb
    dpkg -i lsd-musl_1.1.2_arm64.deb
    rm lsd-musl_1.1.2_arm64.deb
  fi
else
  log "${GREEN}Installing lsd version $desired_version.${RESET}"
  wget https://github.com/lsd-rs/lsd/releases/download/v1.1.2/lsd-musl_1.1.2_arm64.deb
  dpkg -i lsd-musl_1.1.2_arm64.deb
  rm lsd-musl_1.1.2_arm64.deb
fi

log "${GREEN}Process complete changing to zsh. Please run source ~/.zshrc${RESET}"

ZDOTDIR=~ exec zsh -i
