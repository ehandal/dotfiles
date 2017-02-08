# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=4000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

STARTCOLOR="\[\e[1;32m\]";
ENDCOLOR="\[\e[m\]";
export PS1="$STARTCOLOR\W\$ $ENDCOLOR"

# If this is an xterm set the title to dir [user@host]
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\w [\u@\h]\a\]$PS1"
    ;;
*)
    ;;
esac

set -o vi

# enable programmable completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
