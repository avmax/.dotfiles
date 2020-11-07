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
