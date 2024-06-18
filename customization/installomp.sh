#!/bin/bash

# Check if the script is being run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Get the username of the user who ran the script with sudo
USER_NAME=${SUDO_USER:-$(whoami)}

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

# Install required packages if they are not already installed
for pkg in fontconfig unzip git wget nano curl; do
  if [ "$(is_installed "$pkg")" -eq 0 ]; then
    log "${GREEN}Installing $pkg${RESET}"
    apt install -y "$pkg"
  else
    log "${GREEN}$pkg is already installed${RESET}"
  fi
done

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

log "${GREEN}Downloading Oh My Posh${RESET}"
curl -s https://ohmyposh.dev/install.sh | bash -s

sudo -u ${USER_NAME} bash << 'EOF'

mkdir -p $HOME/.config/ohmyposh/
cd ~
echo -e "[init] \033[0;32mDownloading .zshrc and Oh My Posh config\033[0m"
wget -O ~/.zshrc https://raw.githubusercontent.com/supramaxis/scripts/main/customization/omp.zshrc
wget -O ~/.config/ohmyposh/spm.toml https://raw.githubusercontent.com/supramaxis/scripts/main/customization/spm.toml

echo -e "[init] \033[0;32mCloning and installing fzf\033[0m"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
bash ~/.fzf/install --all

echo -e "[init] \033[0;32mInstalling Zoxide\033[0m"
wget -O ~/zinstall.sh https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh
chmod +x ~/zinstall.sh
bash ~/zinstall.sh

EOF

log "${GREEN}Installing lsd${RESET}"
wget https://github.com/lsd-rs/lsd/releases/download/v1.1.2/lsd-musl_1.1.2_arm64.deb
dpkg -i lsd-musl_1.1.2_arm64.deb
rm lsd-musl_1.1.2_arm64.deb

# Export zoxide path based on where it's installed
if [ -x "/home/${USER_NAME}/.local/bin/zoxide" ]; then
  echo "export PATH=\$PATH:/home/${USER_NAME}/.local/bin" >> "/home/${USER_NAME}/.zshrc"
elif [ -x "/root/.local/bin/zoxide" ]; then
  echo "export PATH=\$PATH:/root/.local/bin" >> /root/.zshrc
fi

log "${GREEN}Process complete changing to zsh. Please run source ~/.zshrc${RESET}"

# Determine ZDOTDIR based on whether running as root or not
if [ "$EUID" -eq 0 ]; then
  ZDOTDIR=/root
else
  ZDOTDIR=/home/${USER_NAME}
fi

exec zsh -i
