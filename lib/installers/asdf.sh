git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"

shell=$(basename $SHELL)

case $shell in
"bash")
    echo -e "\n. $HOME/.asdf/asdf.sh" >>~/.bashrc
    echo -e "\n. $HOME/.asdf/completions/asdf.bash" >>~/.bashrc
    source ~/.bashrc
    ;;
"zsh")
    echo -e "\n. $HOME/.asdf/asdf.sh" >>~/.zshrc
    source ~/.zshrc
    ;;
"fish")
    echo -e "\n. source ~/.asdf/asdf.fish" >>~/.config/fish/config.fish

    mkdir -p ~/.config/fish/completions
    and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
    source ~/.config/fish/config.fish
    ;;
esac
