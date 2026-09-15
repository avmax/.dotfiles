# Line-editing keys. Every binding is commented as: key — what it does.
# To see the sequence a key sends, press Ctrl-V and then the key.

bindkey -e   # emacs keymap — Ctrl-A / Ctrl-E line start / end, Ctrl-W delete word back, Esc-B / Esc-F word left / right

# Search history for commands starting with what's already typed.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search     # ↑ — previous command starting with the typed text
bindkey '^[OA' up-line-or-beginning-search     # ↑ (application mode) — same as ↑
bindkey '^[[B' down-line-or-beginning-search   # ↓ — next command starting with the typed text
bindkey '^[OB' down-line-or-beginning-search   # ↓ (application mode) — same as ↓

bindkey '^[[H'    beginning-of-line            # Home — cursor to start of line
bindkey '^[OH'    beginning-of-line            # Home (application mode) — same as Home
bindkey '^[[F'    end-of-line                  # End — cursor to end of line
bindkey '^[OF'    end-of-line                  # End (application mode) — same as End
bindkey '^[[3~'   delete-char                  # Delete (fn-⌫) — delete the character under the cursor
bindkey '^[[2~'   overwrite-mode               # Insert (external keyboards) — toggle overwrite mode
bindkey '^[[5~'   history-search-backward      # Page Up — previous command with the same first word
bindkey '^[[6~'   history-search-forward       # Page Down — next command with the same first word
bindkey '^[[1;5D' backward-word                # Ctrl-← — word left (macOS uses it for Spaces unless disabled)
bindkey '^[[1;5C' forward-word                 # Ctrl-→ — word right (macOS uses it for Spaces unless disabled)
bindkey '^[[1;3D' backward-word                # ⌥-← — word left, in terminals that send it as an arrow key
bindkey '^[[1;3C' forward-word                 # ⌥-→ — word right, in terminals that send it as an arrow key
bindkey '^R'      history-incremental-pattern-search-backward   # Ctrl-R — search history as you type; * and ? work as wildcards

bindkey '^[[Z' reverse-menu-complete                  # ⇧-Tab — cycle completions backwards
bindkey -M menuselect '^[[Z' reverse-menu-complete    # ⇧-Tab in the completion menu — previous entry

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line               # Ctrl-X Ctrl-E — open the command in $EDITOR; save and quit to run it
