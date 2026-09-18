autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search

# vi mode
bindkey -v
KEYTIMEOUT=3 # 30ms, so Esc is not stalled waiting for an escape sequence
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

# Cursor shape in vi mode: block in normal mode, beam in insert mode
function zle-keymap-select zle-line-init {
    if [[ $KEYMAP == vicmd ]]; then
        print -n '\e[1 q' # Blinking block cursor
    else
        print -n '\e[5 q' # Blinking beam cursor
    fi
}
function zle-line-finish { print -n '\e[1 q' } # Blinking block while a command runs
zle -N zle-keymap-select
zle -N zle-line-init
zle -N zle-line-finish

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history

setopt interactivecomments

mkdir -p ~/.local/share/zsh
HISTFILE=~/.local/share/zsh/history
HISTSIZE=20000
SAVEHIST=10000

autoload -U colors && colors
if (( $+commands[eza] )); then
    alias ls=eza
else
    alias ls='ls --color=auto'
fi
alias ll='ls -l'
alias grep='grep --color=auto --exclude-dir={.git,.hg,.svn}'
alias rg='rg --no-heading'
alias vi=nvim
alias view='nvim -R'
alias tldr='tldr --compact'

if [[ -n $SSH_CLIENT && -z $TMUX ]]; then
    win_name="%n@%m: %~"
    prompt_pwd='[%m] %1~'
else
    win_name="%~"
    prompt_pwd='%1~'
fi

# Ghostty injects its own OSC 133 marks, but only into shells it spawns
# directly: not tmux panes (TERM differs) and not ssh sessions (the env var
# isn't forwarded). Mark the prompt ourselves everywhere else.
if [[ $TERM == xterm-ghostty && -n $GHOSTTY_RESOURCES_DIR ]]; then
    typeset -gi _osc133=0
else
    typeset -gi _osc133=1
fi

# Initialize to 1 so the first prompt, which follows no command, skips the C below.
typeset -gi _preexec_ran=1

function _precmd() {
    local exit_status=$?
    local tab_name="%15<..<%~%<<" #15 char left truncated PWD

    if (( _osc133 )); then
        # An empty line or ^C never reaches preexec, so the C that opens this
        # command is missing. Emit it here so every D has a matching C.
        (( _preexec_ran )) || print -n '\e]133;C\a' # start of command output
        print -n "\e]133;D;$exit_status\a" # command finished
        _preexec_ran=0
    fi

    case "$TERM" in
        mintty*|vte*|xterm*)
            print -Pn "\e]2;$win_name\a" # set window name
            print -Pn "\e]1;$tab_name\a" # set tab name
            ;;
        tmux*)
            print -Pn "\ek$tab_name\e\\" # set screen hardstatus
            ;;
    esac

    if [ -n "$TMUX" ]; then
        eval "$(tmux show-environment -s DISPLAY)"
    fi
}

function _preexec() {
    if (( _osc133 )); then
        _preexec_ran=1
        print -n '\e]133;C\a' # start of command output (OSC 133)
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _precmd
add-zsh-hook preexec _preexec

function () {
    local prompt_start prompt_end
    if (( _osc133 )); then
        prompt_start=$'\e]133;A\a'
        prompt_end=$'\e]133;B\a'
    fi

    local ret_status="%(?:%{$fg[green]%}$:%{$fg[red]%}$)"
    PROMPT="%{$prompt_start%}%{$fg[blue]%}$prompt_pwd ${ret_status}%{$reset_color%} %{$prompt_end%}"
}

if [[ -d ~/.local/share/zsh/functions ]]; then
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
(( $+commands[dircolors] )) && eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

zstyle '*' single-ignored show

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

export GPG_TTY=$(tty)
export BAT_THEME="Catppuccin Mocha"

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
export FZF_TMUX=1

export MANPAGER='nvim +Man!'
export MANWIDTH=999

# fzf catppuccin mocha
export FZF_DEFAULT_OPTS=" \
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
    --color=selected-bg:#45475a \
    --multi"

[[ -f ~/.config/zsh/zshrc.local ]] && source ~/.config/zsh/zshrc.local

(( $+commands[fzf] )) && source <(fzf --zsh)

if (( $+commands[brew] )); then
    zsh_highlight=$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    [[ -f $zsh_highlight ]] && source $zsh_highlight
    unset zsh_highlight
fi
