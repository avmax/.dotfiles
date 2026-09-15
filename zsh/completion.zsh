# Completion.

ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p "$ZSH_CACHE_DIR"

# Extra definitions: zsh-completions first, Homebrew's (brew, deno, …) last.
#
# `brew shellenv` puts Homebrew's directory at the *front* of fpath. That lets
# its files shadow zsh's own: node's _npm is a bash-style script zsh can't
# register (so npm got no completion at all), and git's _git is thinner than
# zsh's built-in one. Moved to the back, it only fills in what zsh lacks.
typeset -U fpath
_brew_site_functions="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions"
fpath=(
  "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-completions/src"(N-/)
  ${fpath:#$_brew_site_functions}
  $_brew_site_functions(N-/)
)
unset _brew_site_functions

zmodload zsh/complist
autoload -Uz compinit compaudit

() {
  setopt local_options extended_glob
  local dump="$ZSH_CACHE_DIR/zcompdump-$ZSH_VERSION"

  # Fast path: the dump was checked within the last 24h, so trust it.
  if [[ -f $dump && -z $dump(#qN.mh+24) ]]; then
    compinit -C -d "$dump"
    return
  fi

  # Otherwise audit fpath first. compinit would stop and *ask* about insecure
  # directories on every new shell, so decide up front instead.
  local -a insecure=(${(f)"$(compaudit 2>/dev/null)"})
  local brew="${HOMEBREW_PREFIX:-/opt/homebrew}"

  if (( ! $#insecure )); then
    compinit -d "$dump"
  elif (( ! ${#${insecure:#$brew/*}} )); then
    # Only Homebrew's own directories are flagged — they belong to a different
    # account than this user. Use them rather than lose git/npm/brew
    # completion. Permanent fix: give this user ownership of Homebrew (README).
    compinit -u -d "$dump"
  else
    print -u2 "zsh: skipped insecure completion directories — run compaudit to list them"
    compinit -i -d "$dump"
  fi
  touch "$dump"   # compinit only rewrites the dump when fpath changes
}

setopt ALWAYS_TO_END          # cursor to end of word after completing
setopt COMPLETE_IN_WORD       # complete from the middle of a word

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/compcache"
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' menu select=2                        # arrow-key menu past 2 matches

# group matches under headings (list and heading colors are in colors.zsh)
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true

# kill / killall: pick from your own processes in a menu
zstyle ':completion:*:processes' command "ps -u $USER -o pid,user,comm"
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:*:killall:*' force-list always
