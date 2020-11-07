# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# examples https://github.com/bhilburn/powerlevel9k/wiki/Show-Off-Your-Config
# ---> POWERLEVEL 9k <---
# UTIL
# Checks if working tree is dirty
function _parse_git_dirty() {
  local STATUS=''
  local -a FLAGS
  FLAGS=('--porcelain')
  if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if [[ $POST_1_7_2_GIT -gt 0 ]]; then
      FLAGS+='--ignore-submodules=dirty'
    fi
    if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
      FLAGS+='--untracked-files=no'
    fi
    STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  fi
  if [[ -n $STATUS ]]; then
    echo "$_GIT_PROMPT_DIRTY"
  else
    echo "$_GIT_PROMPT_CLEAN"
  fi
}

# GLOBAL
# https://github.com/ryanoasis/nerd-fonts | PS: in Iterm2 always works InconsolataGo Nerd Font Complete
POWERLEVEL9K_MODE='nerdfont-complete'
ZSH_THEME="powerlevel9k/powerlevel9k"

# ICONS http://nerdfonts.com/?set=nf-dev-#cheat-sheet
POWERLEVEL9K_NODE_ICON='\uf898'
POWERLEVEL9K_RAM_ICON='\uf608'

# COLORS
POWERLEVEL9K_OS_ICON_BACKGROUND="016"
POWERLEVEL9K_OS_ICON_FOREGROUND="015"

POWERLEVEL9K_RAM_BACKGROUND="017"
POWERLEVEL9K_RAM_FOREGROUND="015"

POWERLEVEL9K_IP_BACKGROUND="018"
POWERLEVEL9K_IP_FOREGROUND="015"

POWERLEVEL9K_PUBLIC_IP_BACKGROUND="019"
POWERLEVEL9K_PUBLIC_IP_FOREGROUND="015"

POWERLEVEL9K_NODE_VERSION_BACKGROUND='020'
POWERLEVEL9K_NODE_VERSION_FOREGROUND='015'

POWERLEVEL9K_VCS_BACKGROUND="020"
POWERLEVEL9K_VCS_FOREGROUND="015"
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='020'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='015'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='005'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='015'



# SET PROMPTS
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon ram ip public_ip node_version)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(vcs)
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=" %K{015}%F{021}%~ %f%k$(_parse_git_dirty) "
