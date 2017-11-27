#!/bin/bash
set -e

cd $(dirname $BASH_SOURCE)
BASE=$(pwd)

ln -siT $BASE/bashrc ~/.bashrc
ln -siT $BASE/gitconfig ~/.gitconfig
ln -siT $BASE/gvimrc ~/.gvimrc
ln -siT $BASE/inputrc ~/.inputrc
ln -siT $BASE/tmux.conf ~/.tmux.conf
ln -siT $BASE/vimperatorrc ~/.vimperatorrc
ln -siT $BASE/vimrc ~/.vimrc
ln -siT $BASE/zshrc ~/.zshrc
ln -siT $BASE/vim ~/.vim

if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
~/.tmux/plugins/tpm/bin/install_plugins
