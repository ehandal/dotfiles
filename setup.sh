#!/bin/bash
set -e

BASE=$(realpath --relative-to="$HOME" "$(dirname $BASH_SOURCE)")

mkdir -p ~/.config/tmux ~/.config/zsh
ln -si ../../$BASE/inputrc ~/.config
ln -si ../../$BASE/tmux.conf ~/.config/tmux
ln -si ../../$BASE/zshrc ~/.config/zsh
ln -siT ../../$BASE/zshrc ~/.config/zsh/.zshrc

ln -siT $BASE/bashrc ~/.bashrc
ln -siT $BASE/gitconfig ~/.gitconfig
ln -siT $BASE/vim ~/.vim

if [ ! -d ~/.config/tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi
~/.config/tmux/plugins/tpm/bin/install_plugins
