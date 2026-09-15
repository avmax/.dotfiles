# Line-editor plugins, cloned into ~/.local/share/zsh/plugins by install/zsh.sh.
# A missing plugin is skipped, so the shell still starts before the installer
# has run. zshrc sources this file after the prompt: syntax highlighting has to
# wrap every widget defined before it, powerlevel10k's included.
# Their colors are in colors.zsh.

# Both redraw the command line with escape codes, which a dumb terminal (IDE
# task runners, Emacs shell) can't show.
[[ $TERM == dumb ]] && return

: ${ZSH_PLUGIN_DIR:=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins}

# fish-style suggestions as you type; → or End accepts
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
[[ -r $ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# syntax highlighting — must be the last plugin: it wraps the widgets above.
# Highlighters run in this order, and each one paints over the ones before:
#
#   main      commands, arguments, paths, quoted text
#   brackets  brackets by nesting depth
#   quotes    darker quote marks                     (below)
#   regexp    dangerous commands, patterns in colors.zsh
#   typo      fades everything after a mistyped command (below)
#   cursor    the character under the cursor
if [[ -r $ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets quotes regexp typo cursor)
  source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  # The two custom highlighters build on what `main` already worked out. The
  # plugin keeps main's results in _zsh_highlight__highlighter_main_cache, one
  # "start end style memo=…" entry per region, and runs these after it. They
  # find regions by style, so the unknown-token and quoted-text colors in
  # colors.zsh must not be shared with any other style.

  # quotes: paint the quote marks of every quoted string main found
  _zsh_highlight_highlighter_quotes_predicate() { _zsh_highlight_buffer_modified }
  _zsh_highlight_highlighter_quotes_paint() {
    local text=$ZSH_HIGHLIGHT_STYLES[double-quoted-argument] entry
    local -a region
    integer start end open
    for entry in $_zsh_highlight__highlighter_main_cache; do
      region=(${(s: :)entry})                                    # start end style memo=…
      [[ $region[3] == $text ]] || continue
      start=$region[1] end=$region[2] open=1
      [[ $BUFFER[start+1] == '$' ]] && open=2                    # $'…'
      [[ $BUFFER[start+open] == [\'\"] ]] || continue
      _zsh_highlight_add_highlight $start $(( start + open )) quote-mark
      if (( end - start > open )) && [[ $BUFFER[end] == $BUFFER[start+open] ]]; then
        _zsh_highlight_add_highlight $(( end - 1 )) $end quote-mark
      fi
    done
  }

  # typo: when main marks a command as unknown, fade the rest of that command
  # too — up to the next ; & | or newline that isn't inside quotes
  _zsh_highlight_highlighter_typo_predicate() { _zsh_highlight_buffer_modified }
  _zsh_highlight_highlighter_typo_paint() {
    local unknown=$ZSH_HIGHLIGHT_STYLES[unknown-token] entry char quote
    local -a region
    integer end i
    for entry in $_zsh_highlight__highlighter_main_cache; do
      region=(${(s: :)entry})                                    # start end style memo=…
      [[ $region[3] == $unknown ]] || continue
      end=$region[2] quote=
      for (( i = end; i < $#BUFFER; i++ )); do
        char=$BUFFER[i+1]
        if [[ $char == \\ && $quote != \' ]]; then
          (( i++ ))                                              # skip the escaped character
        elif [[ -n $quote ]]; then
          [[ $char == $quote ]] && quote=
        elif [[ $char == [\'\"] ]]; then
          quote=$char
        elif [[ $char == ($'\n'|';'|'&'|'|') ]]; then
          break
        fi
      done
      (( i > end )) && _zsh_highlight_add_highlight $end $i unknown-token
    done
  }
fi
