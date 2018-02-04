#!/bin/bash

sudo apt-get update

sudo apt-get install -y vim
sudo apt-get install -y guake
sudo apt-get install -y openssh-server
sudo apt-get install -y git
sudo apt-get install -y make

sudo apt-get install -y python-pip

MY_SCRIPTS_PATH=~/.myscripts
mkdir $MY_SCRIPTS_PATH
wget https://raw.githubusercontent.com/rupa/z/master/z.sh -P $MY_SCRIPTS_PATH
chmod 775 $MY_SCRIPTS_PATH/z.sh
echo -e "\n. $MY_SCRIPTS_PATH/z.sh" >> ~/.bashrc

echo ":highlight Comment ctermfg=green" >> ~/.vimrc

sudo apt-get install -y meld

git config --global user.email "szwagier90@gmail.com"
git config --global user.name "Pawel Szwagierek"
git config --global core.editor "vim"
git config --global merge.tool meld
cp meld_diff.py $MY_SCRIPTS_PATH
git config --global mergetool.keepBackup false
git config --global alias.tree "log --decorate --oneline --graph"
