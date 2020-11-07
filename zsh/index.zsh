
# global
# --------------------------------------------------------------------
export TERM="xterm-256color"
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH=/Users/avmax/.oh-my-zsh

source ${HOME}/.dotfiles/zsh/aliases.zsh
source ${HOME}/.dotfiles/zsh/functions.zsh
source ${HOME}/.dotfiles/zsh/variables.zsh
source ${HOME}/.dotfiles/zsh/prompt.zsh

# tns-completion-start
if [ -f /Users/avmax/.tnsrc ]; then
    source /Users/avmax/.tnsrc
fi

# tmux
if [ "$TMUX" = "" ]; then
    tmux;
fi


# settings
# --------------------------------------------------------------------
# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# export MANPATH="/usr/local/man:$MANPATH"
# You may need to manually set your language environment
export LANG=en_US.UTF-8

autoload -U colors
colors

# Prefer015 editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"


# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# autocorrection question
SPROMPT='zsh:  '\''%R'\'' to '\''%r'\'' ? [Yes/No/Abort/Edit] '

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# history file
HISTFILE=~/.zhistory
SAVEHIST=5000
setopt  APPEND_HISTORY
setopt  HIST_IGNORE_ALL_DUPS
setopt  HIST_IGNORE_SPACE

# Add wisely, as too many plugins slow down shell startup.
plugins=(git cp ssh-agent osx zsh-completions)

# ssh-agent enabling
zstyle :omz:plugins:ssh-agent agent-forwarding on

source $ZSH/oh-my-zsh.sh



# zsh-completions
# --------------------------------------------------------------------
autoload -U compinit
compinit
zmodload -i zsh/complist
setopt hash_list_all                 # hash everything before completion
setopt completealiases           # complete alisases
setopt always_to_end            # when completing from the middle of a word, move the cursor to the end of the word    
setopt complete_in_word       # allow completion from within a word/phrase
setopt correct                         # spelling correction for commands
setopt list_ambiguous            # complete as much of a completion until it gets ambiguous.

zstyle ':completion::complete:*' use-cache on                   # completion caching, use rehash to clear
zstyle ':completion:*' cache-path ~/.zsh/cache                  # cache path
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'    # ignore case
zstyle ':completion:*' menu select=2                                  # menu if nb items > 2
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}         # colorz !
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate # list of completers to use

# sections completion !
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'\e[00;34m%d'
zstyle ':completion:*:messages' format $'\e[00;31m%d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true

zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=29=34"
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always
users=(jvoisin root)           # because I don't care about others
zstyle ':completion:*' users $users

#generic completion with --help
compdef _gnu_generic gcc
compdef _gnu_generic gdb

# 015 dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="false"



# zsh-syntax-highlighting
# --------------------------------------------------------------------
source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=003'


# zsh-syntax-highlighting !must be imported or sourced as last plugin
# --------------------------------------------------------------------
source $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets line pattern cursor)

#ZSH_HIGHLIGHT_STYLES[line]='fg=093, bold'
# cursor
ZSH_HIGHLIGHT_STYLES[cursor]='bg=008'
# path
ZSH_HIGHLIGHT_STYLES[path]='fg=020'
# alias
ZSH_HIGHLIGHT_STYLES[alias]='fg=020, bold'
# function
ZSH_HIGHLIGHT_STYLES[function]='fg=201, bold'
# unknown toker
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=016, bold'
# quoted
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=235, bold'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=235, bold'
# custom
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=009, bold')
ZSH_HIGHLIGHT_PATTERNS+=('sudo *' 'fg=009, bold')
# brackets
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=235, bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=237, bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=239, bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=241, bold'

# ls colors. use online LSCOLORS generator to create these codes
export LSCOLORS="exgxexexbxfxexexexfxfx"
export LS_COLORS="di=34:ln=36:so=34:pi=34:ex=31:bd=35:cd=34:su=34:sg=34:tw=35:ow=35"



# bind keys
# --------------------------------------------------------------------
bindkey "^[OH"  beginning-of-line 
bindkey "^[OF"  end-of-line
bindkey '^[[1;5D'   backward-word
bindkey '^[[1;5C'   forward-word

# Key bindings
# Lookup in /etc/termcap or /etc/terminfo else, you can get the right keycode
# by typing ^v and then type the key or key combination you want to use.
# "man zshzle" for the list of available actions
bindkey -e                      # emacs keybindings
bindkey '\e[1;5C' forward-word            # C-Right
bindkey '\e[1;5D' backward-word           # C-Left
bindkey '\e[2~'   overwrite-mode          # Insert
bindkey '\e[3~'   delete-char             # Del
bindkey '\e[5~'   history-search-backward # PgUp
bindkey '\e[6~'   history-search-forward  # PgDn
bindkey '^A'      beginning-of-line       # Home
bindkey '^D'      delete-char             # Del
bindkey '^E'      end-of-line             # End
bindkey '^R'      history-incremental-pattern-search-backward
