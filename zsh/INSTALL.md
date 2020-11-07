# Installation
1) brew install zsh
2) sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
3) ln -s ~/dotfiles/.zsh
4) ln -s ~/dotfiles/.zsh/.zshrc

# completions
5) git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

# syntax highlighting
6) git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# fish-like autosuggestions
7) git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# powerlevel9l
8) git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
9) git clone https://github.com/ryanoasis/nerd-fonts
10) build inconsalanta font and choose it in iTerm as ASCII font

# switching to zsh and launching
11) zsh
12) chsh -s $(which zsh)
13) source ~/.zshrc 
14) restart terminal
