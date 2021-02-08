# set PATH so it includes user's private bin directories
typeset -U PATH path
path=(
    $HOME/bin
    $HOME/.local/bin
    $path)
