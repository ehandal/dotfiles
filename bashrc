# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
mkdir -p ~/.local/share
HISTFILE=~/.local/share/bash_history
HISTSIZE=10000
HISTFILESIZE=10000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

setprompt() {
    if [ -n "$SSH_CLIENT" -a -z "$TMUX" ]; then
        local win_name="\w [\h]"
        local prompt="[\h] \W"
    else
        local win_name='\w'
        local prompt="\W"
    fi

    # OSC 133
    local PROMPT_START="\e]133;A\a"
    local PROMPT_END="\e]133;B\a"

    local STARTCOLOR="\[\e[32m\]"
    local ENDCOLOR="\[\e[m\]"
    PS1="$PROMPT_START$STARTCOLOR$prompt \$$ENDCOLOR $PROMPT_END"
    case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;$win_name\a\]$PS1"
        ;;
    *)
        ;;
    esac
}
setprompt
unset -f setprompt

set -o vi
export EDITOR=nvim
export GPG_TTY=$(tty)
alias vi=nvim
alias view='nvim -R'

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

if [[ -f ~/.bashrc.local ]]; then
    source ~/.bashrc.local
fi

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

eval "$(fzf --bash)"
