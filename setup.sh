#!/bin/bash
set -e
cd ~
ln -si config/bashrc .bashrc
ln -si config/gvimrc .gvimrc
ln -si config/inputrc .inputrc
ln -si config/tmux.conf .tmux.conf
ln -si config/vimperatorrc .vimperatorrc
ln -si config/vimrc .vimrc
ln -si config/zshrc .zshrc
ln -siT config/vim/vimfiles .vim

if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
~/.tmux/plugins/tpm/bin/install_plugins
