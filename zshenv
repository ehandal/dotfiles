ZDOTDIR=~/.config/zsh
skip_global_compinit=1 # prevents /etc/zsh/zshrc from calling compinit

mkdir -p ~/.local/share
export INPUTRC=~/.config/inputrc
export IPYTHONDIR=~/.config/ipython
export LESSHISTFILE=~/.local/share/lesshst
export NODE_REPL_HISTORY=~/.local/share/node_repl_history
export NPM_CONFIG_USERCONFIG=~/.config/npmrc
export P4ENVIRO=~/.config/p4enviro
export P4TICKETS=~/.local/share/p4tickets
export PYLINTHOME=~/.cache/pylint

# set PATH so it includes user's private bin directories
typeset -U PATH path
path=(
    ~/bin
    ~/.local/bin
    $path)
export PATH

if [[ -f ~/.config/zsh/zshenv.local ]]; then
    source ~/.config/zsh/zshenv.local
fi
