# split3 — split the current iTerm2 tab into one column per project.
#
#   +--------------+--------------+--------------+
#   | cognitive-os |   here4you   | realtor-app  |
#   +--------------+--------------+--------------+
#
# Loaded by zsh/custom-functions.zsh. Edit SPLIT3_PATHS to change the projects;
# add a fourth and it makes a fourth column.
#
# It drives iTerm2 over AppleScript rather than iTerm2's Python API, so there is
# nothing to install into iTerm2 itself and nothing to keep in sync.

SPLIT3_PATHS=(
  ~/Code/cognitive-os
  ~/Code/here4you
  ~/Code/realtor-app
)

split3() {
  [[ "$TERM_PROGRAM" == "iTerm.app" ]] || {
    print -u2 "split3: only works inside iTerm2"
    return 1
  }

  local i script
  script='tell application "iTerm2"
  set p1 to current session of current tab of current window'

  # Each pane is split off the one before it, left to right.
  for (( i = 2; i <= $#SPLIT3_PATHS; i++ )); do
    script+="
  tell p$((i - 1)) to set p$i to (split vertically with same profile)"
  done

  # cd rather than per-pane profiles: the first pane is the shell this ran in,
  # which no profile setting can move. The leading space keeps the command out
  # of history under HIST_IGNORE_SPACE.
  for (( i = 1; i <= $#SPLIT3_PATHS; i++ )); do
    script+="
  tell p$i to write text \" cd ${SPLIT3_PATHS[i]:a} && clear\""
  done

  script+='
  select p1
end tell

-- Every split halves the pane it comes from, so three columns start out
-- 50/25/25. Evening them means clicking a Window menu item, and only System
-- Events can do that — which needs iTerm2 ticked in System Settings -> Privacy
-- & Security -> Accessibility. Without it the columns just stay uneven.
try
  tell application "System Events" to tell process "iTerm2"
    click menu item "Arrange Split Panes Evenly" of menu "Window" of menu bar 1
  end tell
end try'

  osascript -e "$script"
}
