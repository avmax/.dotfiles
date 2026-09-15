# Aliases, plus the app launchers. General-purpose functions live in custom-functions.zsh.

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias projects='cd ~/Code'

# listing (colors come from CLICOLOR / LSCOLORS in options.zsh)
alias ll='ls -lh'
alias la='ls -lah'
alias lr='ls -l'
alias ld='ls -ld -- */'
alias lh='ls -ld -- .?*'
alias lf='find . -maxdepth 1 -type f'

# removing: ask by default, opt out explicitly
alias rm='nocorrect rm -i'
alias rmf='nocorrect rm -f'
alias rmrf='nocorrect rm -rf'

alias grep='grep --color=auto'

# apps
#
#   chrome                      open or bring Chrome to the front
#   chrome example.com          -> https://example.com
#   chrome localhost:5173       -> http://localhost:5173
#   safari index.html           an existing file opens as a file
#
# Browsers are functions rather than aliases: a bare `open -a Safari example.com`
# fails, because open looks for a *file* called example.com.
_open_in() {  # _open_in <app> [url | domain | file]...
  local app=$1 arg
  local -a targets
  shift
  for arg in "$@"; do
    if [[ -e $arg || $arg == *://* ]]; then
      targets+=("$arg")
    elif [[ $arg == (localhost|127.0.0.1|0.0.0.0)(|:*|/*) ]]; then
      targets+=("http://$arg")
    else
      targets+=("https://$arg")
    fi
  done
  open -a "$app" "${targets[@]}"
}
chrome()  { _open_in 'Google Chrome' "$@" }
firefox() { _open_in Firefox "$@" }
safari()  { _open_in Safari "$@" }
alias telegram='open -a Telegram'

# system
alias off='pmset displaysleepnow'   # screen off now

# shell
alias szrc='exec zsh'               # reload config in a fresh shell
