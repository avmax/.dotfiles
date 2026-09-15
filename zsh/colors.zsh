# Every color in the shell, in one scheme tuned for iTerm's Solarized Light
# preset (background #fdf6e3, text #657b83): ls, completion lists, the command
# line as you type, and the prompt. Sourced before completion and the plugins,
# which keep whatever is set here and fill in the rest with defaults. The
# prompt colors go on later — zshrc calls apply_prompt_colors, at the end.
#
# Hex colors need 24-bit color. iTerm2, VS Code and Cursor have it and say so
# in $COLORTERM; anywhere else zsh/nearcolor swaps each hex color for the
# closest of the standard 256.
[[ $COLORTERM == (truecolor|24bit) ]] || zmodload zsh/nearcolor

# --- ls and completion lists --------------------------------------------------

# BSD ls reads CLICOLOR/LSCOLORS; LS_COLORS feeds the completion lists.
export CLICOLOR=1
export LSCOLORS="exgxexexbxfxexexexfxfx"
export LS_COLORS="di=34:ln=36:so=34:pi=34:ex=31:bd=35:cd=34:su=34:sg=34:tw=35:ow=35"

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '%F{blue}%d%f'
zstyle ':completion:*:messages' format '%F{red}%d%f'
zstyle ':completion:*:warnings' format '%F{red}no matches for: %d%f'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=34'

# --- the command line ---------------------------------------------------------
#
#   #449630  a command that exists, and everything typed after it
#   #3fad1e  your aliases and functions: a brighter shade of that green, bold
#   #87a181  a command that doesn't exist, and everything after it: faded green
#   #0068a7  a file or folder that exists; #5b92bf while you're still typing it
#   #7d7a75  text in quotes; #302d29 the quote marks themselves
#   violet   brackets, darkest outermost
#   #dc322f  dangerous commands
#   #657b83  the suggestion after the cursor: the terminal's plain text color
#
# Two of these aren't plain settings — fading everything after a mistyped
# command, and darker quote marks. The `typo` and `quotes` highlighters in
# plugins.zsh paint those, using the styles defined here.

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#657b83'

typeset -gA ZSH_HIGHLIGHT_STYLES ZSH_HIGHLIGHT_REGEXP

# a command that exists, and what you type after it
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#449630'                     # programs, and builtins like cd
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#449630,underline'     # runs the next word: sudo, exec, time
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#449630,underline'  # a directory typed as a command
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#449630,underline'
ZSH_HIGHLIGHT_STYLES[default]='fg=#449630'                  # plain arguments: status, origin
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#449630'     # -m
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#449630'     # --force
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#449630'                 # *.txt (blue by default, like a path)
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#449630'        # !!
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#449630'              # > out.txt

# your aliases and functions
ZSH_HIGHLIGHT_STYLES[alias]='fg=#3fad1e,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#3fad1e,bold'

# a command that doesn't exist (the typo highlighter fades the rest with it)
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#87a181'

# files and folders
ZSH_HIGHLIGHT_STYLES[path]='fg=#0068a7,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#5b92bf,underline'    # a path you're still typing

# text in quotes, and the quote marks (painted by the quotes highlighter)
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#7d7a75'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#7d7a75'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#7d7a75'
ZSH_HIGHLIGHT_STYLES[quote-mark]='fg=#302d29'

# brackets, by nesting depth: violet, darkest outermost
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#462f80,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#5c42a3,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#725abd,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=#8671cf,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=#9787d9,bold'

ZSH_HIGHLIGHT_STYLES[cursor]='bg=008'                        # the character under the cursor

# Dangerous commands: the whole command in #dc322f. Matched only where a
# command starts — line start, or after ; & | ( { — so `git add` isn't taken
# for `dd`, nor `echo sudo` for sudo. Add your own to the list.
() {
  local at='(^|[;&|({][[:space:]]*)((command|exec|nocorrect|noglob|time)[[:space:]]+)*'
  local rest='([[:space:]].*|$)'
  local -a dangerous=(
    "sudo$rest"                                                                  # runs as root
    "rm[[:space:]]+(-[[:alnum:]]*[rRf][[:alnum:]]*|--recursive|--force)$rest"    # rm -r, rm -f
    "(rmf|rmrf)$rest"                                                            # the rm -f aliases
    "git[[:space:]]+push([[:space:]].*)?[[:space:]](-f|--force[[:alnum:]-]*)$rest"
    "git[[:space:]]+reset([[:space:]].*)?[[:space:]]--hard$rest"
    "git[[:space:]]+clean([[:space:]].*)?[[:space:]]-[[:alnum:]]*f[[:alnum:]]*$rest"
    "git[[:space:]]+branch([[:space:]].*)?[[:space:]]-D$rest"
    "git[[:space:]]+(checkout|restore)[[:space:]]+(--[[:space:]]+)?\\.$rest"     # discard all changes
    "(chmod|chown)[[:space:]]+(.*[[:space:]])?-[[:alnum:]]*R[[:alnum:]]*$rest"   # recursive
    "(dd|mkfs[[:alnum:]._]*|newfs[[:alnum:]._]*)$rest"                           # raw disk writes
    "diskutil[[:space:]]+(erase[[:alnum:]]*|zeroDisk|randomDisk|secureErase|partitionDisk)$rest"
    "(shutdown|reboot|halt)$rest"
  )
  local re
  for re in $dangerous; do
    ZSH_HIGHLIGHT_REGEXP[$at$re]='fg=#dc322f,bold'
  done
}

# --- the prompt (powerlevel10k) -----------------------------------------------
#
#   #0068a7  folders; #5b92bf for the shortened parts of a path
#   #449630  git branch, and ❯ after a command that worked
#   #725abd  changed files, background jobs, tool versions (node, python, aws…)
#   #87a181  untracked files
#   #dc322f  conflicts, ❯ and the status after a failed command, root, sudo
#   #7d7a75  the connecting words: on, took, at
#   #657b83  command duration, clock, and other plain information
#   #302d29  the OS icon
#
# zshrc calls this right after sourcing zsh/p10k.zsh: that file begins by
# unsetting every POWERLEVEL9K_* variable, so nothing set earlier survives.
# Applied afterwards, these colors also survive `p10k configure` rewriting
# p10k.zsh. After editing either file, open a new tab or run `exec zsh`
# (`p10k reload` only redraws from the settings already loaded).
apply_prompt_colors() {
  setopt localoptions extendedglob
  local green='#449630' faded='#87a181' blue='#0068a7' light_blue='#5b92bf'
  local violet='#725abd' red='#dc322f' gray='#7d7a75' plain='#657b83' dark='#302d29'
  local color='(FOREGROUND|VISUAL_IDENTIFIER_COLOR)' name

  # Start every segment violet — the long tail of tools and environments
  # (nvm, virtualenv, aws, kubecontext, …) — then override the rest.
  for name in ${(k)parameters[(I)POWERLEVEL9K_*_$~color]}; do
    typeset -g $name=$violet
  done

  # plain information
  for name in ${(k)parameters[(I)POWERLEVEL9K_(RAM|SWAP|LOAD_NORMAL|DISK_USAGE_NORMAL|BATTERY_(CHARGING|CHARGED|DISCONNECTED)|WIFI|IP|PUBLIC_IP|VPN_IP|PROXY|NORDVPN*|CPU_ARCH|CONTEXT|CONTEXT_REMOTE|TODO|TIMEWARRIOR|TASKWARRIOR|PER_DIRECTORY_HISTORY_*|TIME|COMMAND_EXECUTION_TIME)_$~color]}; do
    typeset -g $name=$plain
  done

  # problems (warnings stay violet)
  for name in ${(k)parameters[(I)POWERLEVEL9K_(*_CRITICAL|BATTERY_LOW|CONTEXT_ROOT|CONTEXT_*SUDO|STATUS_ERROR*|PROMPT_CHAR_ERROR_*)_$~color]}; do
    typeset -g $name=$red
  done

  # things that went right
  for name in ${(k)parameters[(I)POWERLEVEL9K_(STATUS_OK*|PROMPT_CHAR_OK_*)_$~color]}; do
    typeset -g $name=$green
  done

  # folders — DIR and DIR_*, but not DIRENV
  for name in ${(k)parameters[(I)POWERLEVEL9K_DIR(|_*)_$~color]}; do
    typeset -g $name=$blue
  done
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$light_blue
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$blue POWERLEVEL9K_DIR_ANCHOR_BOLD=true

  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$dark
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=$green
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED}_FOREGROUND=$green POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$violet
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=$gray
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$violet
  typeset -g POWERLEVEL9K_{RULER,MULTILINE_FIRST_PROMPT_GAP}_FOREGROUND=$gray

  # the connecting words — on, took, at, with, in — are prefixes starting with %f
  for name in ${(k)parameters[(I)POWERLEVEL9K_*_PREFIX]}; do
    [[ ${(P)name} == '%f'* ]] && typeset -g $name="%F{$gray}${${(P)name}#%f}"
  done

  # The git status in p10k.zsh has its colors inline, as `local clean='%76F'`
  # lines inside my_git_formatter: a first set for the status, then a second
  # set, all grey, used while git is still loading. Rewrite both in place.
  if (( $+functions[my_git_formatter] )); then
    local -A status_colors=(meta $gray clean $green modified $violet untracked $faded conflicted $red)
    local -A seen
    local -a lines=("${(@f)functions[my_git_formatter]}")
    local i
    for (( i = 1; i <= $#lines; i++ )); do
      [[ $lines[i] == (#b)([[:space:]]#local[[:space:]]##)(meta|clean|modified|untracked|conflicted)=\'[^\']#\'(*) ]] || continue
      if (( $+seen[$match[2]] )); then
        lines[i]="$match[1]$match[2]='%F{$gray}'$match[3]"
      else
        lines[i]="$match[1]$match[2]='%F{$status_colors[$match[2]]}'$match[3]"
        seen[$match[2]]=1
      fi
    done
    functions[my_git_formatter]=${(F)lines}
  fi
}
