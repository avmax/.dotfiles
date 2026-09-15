# ---------------------------------------------------------------------------
# LEGACY — not wired into ./index.sh any more.
#
# This script predates the per-topic installers in this directory. It is
# destructive (rm -rf on your real dotfiles, no backups) and parts of it are
# stale. Kept for reference only while zsh / tmux / vim are migrated to
# install/<topic>.sh one at a time. Do not run it wholesale.
# ---------------------------------------------------------------------------

# !bin/sh
set -x #echo on

# setup tmux
rm -rf ~/.tmux.conf
ln -s ~/.dotfiles/tmux/index.conf ~/.tmux.conf

# setup zsh
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
rm -rf ~/.zshrc
ln -s ~/.dotfiles/zsh/index.zsh ~/.zshrc

git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

zsh
chsh -s $(which zsh)
source ~/.zshrc

# setup vim
rm -rf ~/.vim
rm -rf ~/.vimrc
ln -s ~/.dotfiles/vim ~/.vim
ln -s ~/.dotfiles/vim/index.vim ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
~/.vim/bundle/YouCompleteMe/install.py

# setup git -> migrated to install/git.sh (run: ./index.sh git)
