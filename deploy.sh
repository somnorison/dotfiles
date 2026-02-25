#! /bin/sh

alias stowcmd='stow -t $HOME --verbose=2'

# this needs to be the directory the dotfiles subdirectories are in.
DOTFILES=$(pwd)

pushd "$DOTFILES" 

echo "beginning the deployment process !"

stowcmd scripts
echo
stowcmd tmux
echo
# stowcmd vim
echo
stowcmd zsh
echo
stowcmd misc
echo
stowcmd emacs
echo
stowcmd lem
echo
stow -t "$HOME/.config" --verbose=2 config
echo
unzip "$(ls fonts/*.zip)" -d fonts -f
mkdir -pv ~/.local/share/fonts
stow --verbose=2 -t "$HOME/.local/share/fonts" fonts


# mkdir -pv vim/.vim/backup
# mkdir -pv vim/.vim/undo
# mkdir -pv vim/.vim/swap
# mkdir -pv vim/.vim/netrw
# 
# vim +PlugInstall +qall!

# ZPLUGIN="$HOME/dotfiles/zsh/.zplugin/bin"
# if [ ! -d "$ZPLUGIN" ]; then
#   echo "Setting up zplugin first-time install"
#   git clone https://github.com/zdharma/zplugin.git "$ZPLUGIN"
# fi

popd
