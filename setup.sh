#!/bin/bash
set -e

BASE=$(realpath --relative-to="$HOME" "$(dirname $BASH_SOURCE)")

ln -siT $BASE/bashrc ~/.bashrc
ln -siT $BASE/gitconfig ~/.gitconfig
ln -siT $BASE/inputrc ~/.inputrc
ln -siT $BASE/zshrc ~/.zshrc
ln -siT $BASE/vim ~/.vim

if [ ! -d ~/.config/tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi
ln -si ../../$BASE/tmux.conf ~/.config/tmux
~/.config/tmux/plugins/tpm/bin/install_plugins
