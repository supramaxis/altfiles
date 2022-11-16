#!/bin/bash


read -p "You want to delete or add an alias? (add/delete) " RESP
if [ "$RESP" = "add" ]; then
  echo     echo 'aliasname for bashrc: '
    read aliasname
    echo 'command for bashrc: '
    read commandname

    if [ -z "$aliasname" ] || [ -z "$commandname" ]; then
        echo "aliasname or commandname is empty"
        exit 1
    fi

    # check if aliasname and commandname exists in bash_aliases

    if grep -q "$aliasname" ~/.bash_aliases; then
        echo "aliasname exists"
        exit 1
    fi

    if grep -q "$commandname" ~/.bash_aliases; then
        echo "commandname exists"
        exit 1
    fi

    ## if check to see if the file bash_aliases exists

    if [ -f ~/.bash_aliases ]; then
        echo "creating alias in bash_aliases"
        echo "alias $aliasname='$commandname'" >> ~/.bash_aliases
    else
        echo "file does not exist, creating it, then creating alias in bash_aliases"
        touch ~/.bash_aliases
        echo "alias $aliasname='$commandname'" >> ~/.bash_aliases
    fi

    # # Append the alias to the bashrc file
    # echo "alias $aliasname='$commandname'" >> ~/.bash_aliases


    # Reload the bashrc

    source ~/.bashrc
    source ~/.bash_aliases

    echo 'bashrc updated'
    echo 'list of aliases: '
    cat ~/.bash_aliases
else
  echo 'aliasname to delete: '
read aliasname

# check if aliasname exists in bash_aliases

if grep -q "$aliasname" ~/.bash_aliases; then
    echo "aliasname exists"
else
    echo "aliasname does not exist"
    exit 1
fi

# delete the alias from bash_aliases

sed -i "/$aliasname/d" ~/.bash_aliases

# Reload the bashrc

source ~/.bashrc

source ~/.bash_aliases


echo 'bashrc updated'

#list aliases

echo 'list of aliases: '
cat ~/.bash_aliases

fi
