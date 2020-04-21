autoload -Uz promptinit
promptinit

# vi mode
bindkey -v
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

typeset -A key
key=(
    BackSpace  "${terminfo[kbs]}"
    Home       "${terminfo[khome]}"
    End        "${terminfo[kend]}"
    Insert     "${terminfo[kich1]}"
    Delete     "${terminfo[kdch1]}"
    Up         "${terminfo[kcuu1]}"
    Down       "${terminfo[kcud1]}"
    Left       "${terminfo[kcub1]}"
    Right      "${terminfo[kcuf1]}"
    PageUp     "${terminfo[kpp]}"
    PageDown   "${terminfo[knp]}"
    ShiftTab   "${terminfo[kcbt]}"
)

bindkey '^r' history-incremental-search-backward      # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
if [[ "${key[PageUp]}" != "" ]]; then
  bindkey "${key[PageUp]}" up-line-or-history         # [PageUp] - Up a line of history
fi
if [[ "${key[PageDown]}" != "" ]]; then
  bindkey "${key[PageDown]}" down-line-or-history     # [PageDown] - Down a line of history
fi

# start typing + [Up-Arrow] - fuzzy find history forward
if [[ "${key[Up]}" != "" ]]; then
  autoload -U up-line-or-beginning-search
  zle -N up-line-or-beginning-search
  bindkey "${key[Up]}" up-line-or-beginning-search
fi
# start typing + [Down-Arrow] - fuzzy find history backward
if [[ "${key[Down]}" != "" ]]; then
  autoload -U down-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey "${key[Down]}" down-line-or-beginning-search
fi

if [[ "${key[Home]}" != "" ]]; then
  bindkey "${key[Home]}" beginning-of-line            # [Home] - Go to beginning of line
fi
if [[ "${key[End]}" != "" ]]; then
  bindkey "${key[End]}"  end-of-line                  # [End] - Go to end of line
fi

bindkey ' ' magic-space                               # [Space] - do history expansion

bindkey '^[[1;5C' forward-word                        # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word                       # [Ctrl-LeftArrow] - move backward one word

if [[ "${key[ShiftTab]}" != "" ]]; then
  bindkey "${key[ShiftTab]}" reverse-menu-complete    # [Shift-Tab] - move through the completion menu backwards
fi

bindkey "${key[BackSpace]}" backward-delete-char      # [Backspace] - delete backward
if [[ "${key[Delete]}" != "" ]]; then
  bindkey "${key[Delete]}" delete-char                # [Delete] - delete forward
else
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char
  bindkey "\e[3~" delete-char
fi

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
        *)
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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
