# ---------------------------------------------------------------------------
# LEGACY — not wired into ./index.sh any more.
#
# This script predates the per-topic installers in this directory. It is
# destructive (rm -rf on your real dotfiles, no backups) and parts of it are
# stale. Kept for reference only while zsh / tmux / vim are migrated to
# install/<topic>.sh one at a time. Do not run it wholesale.
# ---------------------------------------------------------------------------

# install homebrew 
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# !bin/sh
set -x #echo on

# install tmux
brew install --force tmux

# install zsh
brew install --force zsh
chmod 755 /usr/local/share/zsh
chmod 755 /usr/local/share/zsh/site-functions

# install vim
brew install --force cmake
brew install --force vim

# install git
brew install --force git

# install node
brew install --force node
npm i -g yarn
npm i -g n
