#!/bin/bash
set -e

BASE=$(realpath --relative-to="$HOME" "$(dirname $BASH_SOURCE)")

mkdir -p ~/.config/{git,tmux,zsh}
ln -si ../$BASE/inputrc ~/.config
ln -si ../$BASE/npmrc ~/.config
ln -si ../$BASE/nvim ~/.config
ln -si ../../$BASE/gitconfig ~/.config/git/config
ln -si ../../$BASE/tmux.conf ~/.config/tmux
ln -si ../../$BASE/zshrc ~/.config/zsh
ln -si ../../$BASE/zshrc ~/.config/zsh/.zshrc

ln -si $BASE/bashrc ~/.bashrc
ln -si $BASE/zshenv ~/.zshenv
ln -siT $BASE/vim ~/.vim

if [ ! -d ~/.config/tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm
fi
~/.local/share/tmux/plugins/tpm/bin/install_plugins
