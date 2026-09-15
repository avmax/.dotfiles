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

# setup zsh -> migrated to install/zsh.sh (run: ./index.sh zsh)

# setup vim
rm -rf ~/.vim
rm -rf ~/.vimrc
ln -s ~/.dotfiles/vim ~/.vim
ln -s ~/.dotfiles/vim/index.vim ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
~/.vim/bundle/YouCompleteMe/install.py

# setup git -> migrated to install/git.sh (run: ./index.sh git)
