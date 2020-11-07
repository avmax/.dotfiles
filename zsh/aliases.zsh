# apps
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl -a"
alias mvim="open -a /Applications/MacVim.app/contents/MacOS/MacVim"
alias telegram="open -a /Applications/Telegram.app/contents/MacOS/Telegram"
alias skype="open -a /Applications/Skype.app/Contents/MacOS/Skype"
alias safari="open -a /Applications/Safari.app/Contents/MacOS/Safari"
alias canary="open -a /Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
alias firefox="open -a /Applications/FirefoxDeveloperEdition.app/Contents/MacOS/FirefoxDeveloperEdition"
alias teamviewer="open -a /Applications/TeamViewer.app/Contents/MacOS/TeamViewer"
alias pokerstars="open -a /Applications/PokerStars.app/Contents/MacOS/PokerStars"
# alias chrome=="open -a \"Google Chrome\""
alias ws="open -a /Applications/WebStorm.app/Contents/MacOS/webstorm"
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# system
alias off="sleep 1; xset dpms force off"
alias reboot="sudo reboot"

# web

# db
alias mongodb="mongod --fork --logpath /data/db/mongodb.log"

# grep
alias grep="grep --color=auto"

# dir jumping
alias sandbox="cd ~/sandbox"
alias projects="cd ~/sandbox/web/projects/"

# show flies and dirs
alias lr="ls -l"
alias la="ls -la"
alias ld="ls -ld */"
alias lh="ls -ld .?*"
alias lf="find . -maxdepth 1 -type f"

# removing files and dirs
alias del="rm -r -f"
alias rm="nocorrect rm -i"
alias rmf="nocorrect rm -f"
alias rmrf="nocorrect rm -fR"

# functions usage
alias rainbow="spectrum_bls"

# zsh
alias szrc="source ~/.zshrc"

