autoload -Uz promptinit
promptinit

autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search

# vi mode
bindkey -v
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
bindkey '^?' backward-delete-char

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -a '^V' edit-command-line

bindkey '^R' history-incremental-search-backward
if [[ "${terminfo[kpp]}" != "" ]]; then
  bindkey "${terminfo[kpp]}" up-line-or-history     # PageUp
fi
if [[ "${terminfo[knp]}" != "" ]]; then
  bindkey "${terminfo[knp]}" down-line-or-history   # PageDown
fi
if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete # Shift-Tab
fi

bindkey ' ' magic-space # do history expansion
bindkey '^[[1;5C' forward-word  # Ctrl-RightArrow
bindkey '^[[1;5D' backward-word # Ctrl-LeftArrow

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

setopt interactivecomments

# Keep 10000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

autoload -U colors && colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
alias ls='ls --color=auto'
alias grep='grep --color=auto --exclude-dir={.git,.hg,.svn}'
alias rg='rg --no-heading'

if [ -n "$SSH_CLIENT" -a -z "$TMUX" ]; then
    local win_name="%n@%m: %~"
    local prompt='[%m] %1~'
else
    local win_name="%~"
    local prompt='%1~'
fi

function precmd() {
    local tab_name="%15<..<%~%<<" #15 char left truncated PWD
    case "$TERM" in
        cygwin|xterm*|putty*|rxvt*|ansi)
            print -Pn "\e]2;$win_name:q\a" # set window name
            print -Pn "\e]1;$tab_name:q\a" # set tab name
            ;;
        screen*|tmux*)
            print -Pn "\ek$tab_name:q\e\\" # set screen hardstatus
            ;;
    esac

    if [ -n "$TMUX" ]; then
        eval "$(tmux show-environment -s DISPLAY)"
    fi
}

local ret_status="%(?:%{$fg[green]%}$:%{$fg[red]%}$)"
PROMPT="%{$fg[blue]%}$prompt ${ret_status}%{$reset_color%} "

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
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

zstyle '*' single-ignored show

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

export EDITOR=vi
export GPG_TTY=`tty`

if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --no-ignore --follow'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --no-ignore --type d --follow'

    _fzf_compgen_path() {
        fd --no-ignore --hidden --follow --exclude ".git" --exclude ".svn" . "$1"
    }

    _fzf_compgen_dir() {
        fd --no-ignore --type d --hidden --follow --exclude ".git" --exclude ".svn" . "$1"
    }
fi

if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh
