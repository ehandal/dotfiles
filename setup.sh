#!/bin/bash
set -e
cd ~
ln -si config/tmux.conf .tmux.conf
ln -si config/unix/bashrc.sh .bashrc
ln -si config/unix/inputrc .inputrc
ln -si config/vim/gvimrc.vim .gvimrc
ln -si config/vim/vimrc.vim .vimrc
ln -siT config/vim/vimfiles .vim
