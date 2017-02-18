#!/bin/bash
set -e
cd ~
ln -si config/tmux.conf .tmux.conf
ln -si config/bashrc.sh .bashrc
ln -si config/inputrc .inputrc
ln -si config/zshrc .zshrc
ln -si config/vim/gvimrc.vim .gvimrc
ln -si config/vim/vimrc.vim .vimrc
ln -siT config/vim/vimfiles .vim
