#!/bin/bash

wget https://github.com/supramaxis/scripts/raw/main/.bash_aliases

# Reload the bashrc

mv .bash_aliases ~/

source ~/.bashrc

source ~/.bash_aliases

echo 'bashrc updated'
