export ZDOTDIR=~/.config/zsh
skip_global_compinit=1 # prevents /etc/zsh/zshrc from calling compinit

mkdir -p ~/.local/share
export CARGO_HOME=~/.local/share/cargo
export INPUTRC=~/.config/inputrc
export LESSHISTFILE=~/.local/share/lesshst
export NODE_REPL_HISTORY=~/.local/share/node_repl_history
export NPM_CONFIG_USERCONFIG=~/.config/npmrc
export P4ENVIRO=~/.config/p4enviro
export P4TICKETS=~/.local/share/p4tickets
export PYENV_ROOT=~/.local/share/pyenv
export PYLINTHOME=~/.cache/pylint
export RUSTUP_HOME=~/.local/share/rustup

typeset -U PATH path
if [[ $OSTYPE == linux-gnu ]]; then
    if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    function () {
        local p
        for p in /snap/bin ~/.local/share/npm/bin $CARGO_HOME/bin $PYENV_ROOT/bin; do
            if [[ -d $p ]]; then
                path=($p $path)
            fi
        done
    }
fi
path=(
    ~/bin
    ~/.local/bin
    $path)
export PATH

if [[ -f ~/.config/zsh/zshenv.local ]]; then
    source ~/.config/zsh/zshenv.local
fi
