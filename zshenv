# set PATH so it includes user's private bin directories
typeset -U path
path=(
    $HOME/bin
    $HOME/.local/bin
    $path)
export PATH
