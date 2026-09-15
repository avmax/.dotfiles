# Line-editor plugins, cloned into ~/.local/share/zsh/plugins by install/zsh.sh.
# A missing plugin is skipped, so the shell still starts before the installer
# has run. zshrc sources this file after the prompt: syntax highlighting has to
# wrap every widget defined before it, powerlevel10k's included.

# Both redraw the command line with escape codes, which a dumb terminal (IDE
# task runners, Emacs shell) can't show.
[[ $TERM == dumb ]] && return

: ${ZSH_PLUGIN_DIR:=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins}

# fish-style suggestions as you type; → or End accepts
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=003'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
[[ -r $ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# syntax highlighting — must be the last plugin: it wraps the widgets above
if [[ -r $ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
  source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  # Named colors come from the terminal theme, so they read in light and dark
  # mode alike. Styles not set here keep the plugin defaults: quoted strings
  # yellow, brackets colored by depth, unknown commands red.
  ZSH_HIGHLIGHT_STYLES[path]='fg=blue,underline'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=blue,bold'
  ZSH_HIGHLIGHT_STYLES[function]='fg=magenta,bold'
  ZSH_HIGHLIGHT_STYLES[cursor]='bg=008'

  # flag the commands that deserve a second look
  ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=009,bold')
  ZSH_HIGHLIGHT_PATTERNS+=('sudo *' 'fg=009,bold')
fi
