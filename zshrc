autoload -Uz promptinit
promptinit

# vi mode
bindkey -v
bindkey '^?' backward-delete-char
bindkey '^r' history-incremental-search-backward
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history

# Keep 10000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

autoload -U colors && colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
alias ls='ls --color=tty'
alias grep='grep --color=auto --exclude-dir={.git,.hg,.svn}'

local tab_name="%15<..<%~%<<" #15 char left truncated PWD
if [ -n "$SSH_CLIENT" ]; then
    local win_name="%n@%m: %~"
    local prompt='[%m] %c'
else
    local win_name="%~"
    local prompt='%c'
fi
case "$TERM" in
    cygwin|xterm*|putty*|rxvt*|ansi)
        print -Pn "\e]2;$win_name:q\a" # set window name
        print -Pn "\e]1;$tab_name:q\a" # set tab name
        ;;
    screen*)
        print -Pn "\ek$tab_name:q\e\\" # set screen hardstatus
        ;;
    *)
        ;;
esac

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT="${ret_status} %{$fg[cyan]%}$prompt%{$reset_color%} "

# Use modern completion system
autoload -Uz compinit && compinit
zmodload -i zsh/complist

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

zstyle ':completion:*:*:*:*:*' menu select
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

zstyle '*' single-ignored show

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
