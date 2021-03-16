ZDOTDIR=$HOME/.config/zsh
skip_global_compinit=1 # prevents /etc/zsh/zshrc from calling compinit

mkdir -p $HOME/.local/share
export INPUTRC=$HOME/.config/inputrc
export IPYTHONDIR=$HOME/.config/ipython
export LESSHISTFILE=$HOME/.local/share/lesshst
export NODE_REPL_HISTORY=$HOME/.local/share/node_repl_history
export NPM_CONFIG_USERCONFIG=$HOME/.config/npmrc
export P4ENVIRO=$HOME/.config/p4enviro
export P4TICKETS=$HOME/.local/share/p4tickets
export PYLINTHOME=$HOME/.cache/pylint

# set PATH so it includes user's private bin directories
typeset -U PATH path
path=(
    $HOME/bin
    $HOME/.local/bin
    $path)
export PATH

if [[ -f ~/.config/zsh/zshenv.local ]]; then
    source ~/.config/zsh/zshenv.local
fi
