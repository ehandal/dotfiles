export ZDOTDIR=~/.config/zsh
skip_global_compinit=1 # prevents /etc/zsh/zshrc from calling compinit

mkdir -p ~/.local/{share,state}

# state
export LESSHISTFILE=~/.local/state/lesshst
export NODE_REPL_HISTORY=~/.local/state/node_repl_history
export P4TICKETS=~/.local/state/p4tickets
export SQLITE_HISTORY=~/.local/state/sqlite_history

# config
export INPUTRC=~/.config/inputrc
export NPM_CONFIG_USERCONFIG=~/.config/npmrc
export P4ENVIRO=~/.config/p4enviro

# data
export CARGO_HOME=~/.local/share/cargo
export PYENV_ROOT=~/.local/share/pyenv
export RUSTUP_HOME=~/.local/share/rustup

# cache
export PYLINTHOME=~/.cache/pylint

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
elif [[ "$OSTYPE" == "darwin"* ]]; then
    typeset -TU INFOPATH infopath
    typeset -U MANPATH manpath FPATH fpath
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi
path=(
    ~/bin
    ~/.local/bin
    $path)
export PATH

export P4CONFIG=.p4config
export P4DIFF="diff -u"

if [[ -f ~/.config/zsh/zshenv.local ]]; then
    source ~/.config/zsh/zshenv.local
fi
