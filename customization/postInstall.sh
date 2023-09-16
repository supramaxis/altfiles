#!/bin/bash

# Check if the script is being run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

apt install fontconfig unzip -y

mkdir terminess && cd terminess

curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Terminus.zip

unzip Terminus.zip

sudo mv *.ttf /usr/share/fonts

cd ..

rm -rf terminess

fc-cache -fv
mv ~/.zshrc ~/.zshrc.bak
echo "rc file renamed"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
echo "downloaded zsh-autosuggestions"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "downloaded zsh-syntax-highlighting"

curl -LJO https://raw.githubusercontent.com/supramaxis/scripts/main/customization/.zshrc
echo "downloaded new rc file"
source ~/.zshrc

wget https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd_1.0.0_amd64.deb
dpkg -i lsd_1.0.0_amd64.deb

wget https://raw.githubusercontent.com/supramaxis/scripts/main/customization/colors.sh
echo 'source ~/colors.sh' >> ~/.zshrc
echo "done!"