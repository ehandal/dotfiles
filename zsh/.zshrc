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
if [[ -n "${terminfo[kpp]}" ]]; then
    bindkey "${terminfo[kpp]}" up-line-or-history     # PageUp
fi
if [[ -n "${terminfo[knp]}" ]]; then
    bindkey "${terminfo[knp]}" down-line-or-history   # PageDown
fi
if [[ -n "${terminfo[kcbt]}" ]]; then
    bindkey "${terminfo[kcbt]}" reverse-menu-complete # Shift-Tab
fi
if [[ -n "${terminfo[kRIT5]}" ]]; then
    bindkey "${terminfo[kRIT5]}" forward-word  # Ctrl-RightArrow
fi
if [[ -n "${terminfo[kLFT5]}" ]]; then
    bindkey "${terminfo[kLFT5]}" backward-word # Ctrl-LeftArrow
fi
bindkey ' ' magic-space # do history expansion

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

mkdir -p ~/.local/share/zsh
HISTFILE=~/.local/share/zsh/history
HISTSIZE=10000
SAVEHIST=10000

autoload -U colors && colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
alias ls='ls --color=auto'
alias grep='grep --color=auto --exclude-dir={.git,.hg,.svn}'
alias rg='rg --no-heading'
alias vi=nvim
alias view='nvim -R'

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
        mintty*|vte*|xterm*)
            print -Pn "\e]2;$win_name:q\a" # set window name
            print -Pn "\e]1;$tab_name:q\a" # set tab name
            ;;
        tmux*)
            print -Pn "\ek$tab_name:q\e\\" # set screen hardstatus
            ;;
    esac

    if [ -n "$TMUX" ]; then
        eval "$(tmux show-environment -s DISPLAY)"
    fi
}

function preexec() {
    print -Pn "\e]133;C\a" # start of command output (OSC 133)
}

function () {
    # OSC 133
    local prompt_start=$'\e]133;A\a'
    local prompt_end=$'\e]133;B\a'

    local ret_status="%(?:%{$fg[green]%}$:%{$fg[red]%}$)"
    PROMPT="$prompt_start%{$fg[blue]%}$prompt ${ret_status}%{$reset_color%} $prompt_end"
}

if [[ -d ~/.local/share/zsh/functions ]] then
    fpath=(~/.local/share/zsh/functions $fpath)
fi

# Use modern completion system
mkdir -p ~/.cache/zsh/zcompcache
zmodload -i zsh/complist
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.cache/zsh/zcompcache

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

zstyle '*' single-ignored show

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

export EDITOR=nvim
export GPG_TTY=`tty`
export BAT_THEME=base16

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

export MANPAGER='nvim +Man!'
export MANWIDTH=999

[[ -f ~/.local/share/base16-fzf/bash/base16-tomorrow-night.config ]] && source ~/.local/share/base16-fzf/bash/base16-tomorrow-night.config
[[ -f ~/.config/zsh/zshrc.local ]] && source ~/.config/zsh/zshrc.local

if (( $+commands[pyenv] )); then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

if (( $+commands[uv] )); then
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
fi

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh
