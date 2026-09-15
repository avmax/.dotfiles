# Environment and shell options.

export LANG="${LANG:-en_US.UTF-8}"
export EDITOR=vim
export VISUAL="$EDITOR"
export PAGER=less
export LESS='-FRi'   # quit if it fits one screen, keep colors, smart-case search

# BSD ls reads CLICOLOR/LSCOLORS; LS_COLORS feeds completion list colors.
export CLICOLOR=1
export LSCOLORS="exgxexexbxfxexexexfxfx"
export LS_COLORS="di=34:ln=36:so=34:pi=34:ex=31:bd=35:cd=34:su=34:sg=34:tw=35:ow=35"

# history — ~/.zsh_history is the file macOS and the old setup both used
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY       # store timestamps
setopt SHARE_HISTORY          # write as you go, visible in every open shell
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE      # a leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # !! expands onto the line instead of running

# directories
setopt AUTO_CD                # `Code` alone cds into it
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT   # `cd -<Tab>` lists recent dirs

# misc
setopt INTERACTIVE_COMMENTS   # allow # comments at the prompt
setopt NO_BEEP
setopt CORRECT                # offer to fix mistyped command names
SPROMPT="zsh: correct '%F{red}%R%f' to '%F{green}%r%f'? [Yes/No/Abort/Edit] "

# Alt-Backspace / Alt-arrows stop at path separators
WORDCHARS="${WORDCHARS//\/}"
