#!/bin/bash
set -e
ln -sir bashrc ~/.bashrc
ln -sir gitconfig ~/.gitconfig
ln -sir gvimrc ~/.gvimrc
ln -sir inputrc ~/.inputrc
ln -sir tmux.conf ~/.tmux.conf
ln -sir vimperatorrc ~/.vimperatorrc
ln -sir vimrc ~/.vimrc
ln -sir zshrc ~/.zshrc
ln -sirT vim ~/.vim

if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
~/.tmux/plugins/tpm/bin/install_plugins
