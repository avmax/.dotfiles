# install homebrew 
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#!bin/sh
set -x #echo on

# install tmux
brew install --force tmux

rm -rf ~/.tmux.conf
ln -s ~/.dotfiles/tmux/index.conf ~/.tmux.conf

# install zsh
brew install --force zsh

rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
rm -rf ~/.zshrc
ln -s ~/.dotfiles/zsh/index.zsh ~/.zshrc

chmod 755 /usr/local/share/zsh
chmod 755 /usr/local/share/zsh/site-functions

git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

zsh
chsh -s $(which zsh)
source ~/.zshrc

# install vim
brew install --force cmake
brew install --force vim
ln -s ~/.dotfiles/vim ~/.vim
ln -s ~/.dotfiles/vim/index.vim ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
~/.vim/bundle/YouCompleteMe/install.py

# install git
brew install --force git
rm -rf ~/.gitconfig
ln -s ~/.dotfiles/git/gitconfig ~/.gitconfig

# install node
brew install --force node
npm i -g yarn
npm i -g n
