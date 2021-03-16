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
export PYENV_ROOT=~/.local/share/pyenv
export PYLINTHOME=~/.cache/pylint

typeset -U PATH path
if [[ $OSTYPE == linux-gnu ]]; then
    [[ -d /snap/bin ]] && path=(/snap/bin $path)
    path=(
        ~/.local/share/npm/bin
        $PYENV_ROOT/bin
        $path)
fi
path=(
    ~/bin
    ~/.local/bin
    $path)
export PATH

if [[ -f ~/.config/zsh/zshenv.local ]]; then
    source ~/.config/zsh/zshenv.local
fi
