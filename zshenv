ZDOTDIR=$HOME/.config/zsh
skip_global_compinit=1 # prevents /etc/zsh/zshrc from calling compinit

export INPUTRC=$HOME/.config/inputrc
export LESSHISTFILE=$HOME/.local/share/less/history
mkdir -p $HOME/.local/share/less

# set PATH so it includes user's private bin directories
typeset -U PATH path
path=(
    $HOME/bin
    $HOME/.local/bin
    $path)
export PATH
