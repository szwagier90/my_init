#!/bin/bash

sudo apt-get update

sudo apt-get install vim
sudo apt-get install guake
sudo apt-get install openssh-server
sudo apt-get install git

MY_SCRIPTS_PATH=~/.myscripts
mkdir $MY_SCRIPTS_PATH
wget https://raw.githubusercontent.com/rupa/z/master/z.sh -P $MY_SCRIPTS_PATH
chmod 775 $MY_SCRIPTS_PATH/z.sh
echo -e "\n. $MY_SCRIPTS_PATH/z.sh" >> ~/.bashrc


sudo apt-get install meld

git config --global user.email "szwagier90@gmail.com"
git config --global user.name "Pawel Szwagierek"
git config --global core.editor "vim"
git config --global merge.tool meld
cp meld_diff.py $MY_SCRIPTS_PATH
git config --global diff.external $MY_SCRIPTS_PATH/meld_diff.py
git config --global mergetool.keepBackup false

