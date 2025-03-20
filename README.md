# zedro-dotfiles

Installation instructions to my favourite digital tools.

___

### Table o'Contents

<p>
    ~
    <a href="#cloning-zedro-dotfiles">Cloning</a> ~
    <a href="#setup-zsh">Setup zsh</a> ~
    <a href="#setup-vim">Setup vim</a> ~
    <a href="#setup-tmux">Setup tmux</a> ~
    <a href="#setup-terminal">Setup Terminal</a> ~
    <a href="#other-utilities">Other Utilities</a> ~
</p>

___

### Cloning `zedro-dotfiles`

```shell
git clone https://github.com/PedroZappa/zedro-dotfiles.git ~/.dotfiles
git submodule update --init --recursive --progress

# to update submodules
git submodule update --remote --merge
``` 

#### Create symlinks to .dotfiles in home directory.

```sh
~
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.gdbinit ~/.gdbinit
ln -s ~/.dotfiles/.lnav ~/.lnav
ln -s ~/.dotfiles/.xsessionrc ~/.xsessionrc
```

___
## Setup i3
```sh
ln -s ~/.dotfiles/i3/config ~/.config/i3/config
```

___
## Setup [bash](https://www.gnu.org/software/bash/)

```sh
ln -s ~/.dotfiles/.bashrc ~/.bashrc
ln -s ~/.dotfiles/.bash_aliases ~/.bash_aliases
```
___
## Setup [zsh](https://www.zsh.org/)

```sh
ln -s ~/.dotfiles/.zshenv ~/.zshenv
ln -s ~/.dotfiles/.zshrc ~/.zshrc
```

#### Setup [zap](https://github.com/zap-zsh/zap) plugin manager

```sh
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
```

#### Install [`starship`](https://starship.rs/) prompt

```sh
curl -sS https://starship.rs/install.sh | sh
ln -s ~/.dotfiles/starship.toml ~/.config/starship.toml
```

___

# Setup [vim](https://www.vim.org/)


#### Setup [vim](https://www.vim.org/)

```sh
ln -s ~/.dotfiles/.vimrc ~/.vimrc
```

#### Install [vim-plug](https://github.com/junegunn/vim-plug)

```sh
# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p ~/.vim ~/.vim/autoload ~/.vim/backup ~/.vim/colors ~/.vim/plugged

# Install desired color scheme
cd ~/.vim/colors
curl -o molokai.vim https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
curl -o dracula.vim https://raw.githubusercontent.com/dracula/vim/210e0961b9bd765b5b46a84d0631271ee8e6af64/colors/dracula.vim
```

#### Setup [neovim](https://neovim.io/doc/)

```sh
ln -s ~/.dotfiles/nvim/ ~/.config/
```

___

## Setup [tmux](https://github.com/tmux/tmux) 

```sh
ln -s ~/.dotfiles/.tmux.conf.local ~/.tmux.conf.local
```

#### Install [`oh-my-tmux`](https://github.com/gpakosz/.tmux)

```sh
cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
```

___

## Setup [kitty](https://sw.kovidgoyal.net/kitty/)

```sh
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -s ~/.dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf

# Add kitty to path
sudo ln -s ~/.local/kitty.app/bin/kitty /usr/local/bin/

# kitty dracula theme
ln -s ~/.dotfiles/kitty/dracula.conf ~/.config/kitty/dracula.conf
ln -s ~/.dotfiles/kitty/diff.conf ~/.config/kitty/diff.conf

```

___

## Other Utilities

#### Setup [btop](https://github.com/aristocratos/btop)

```sh
ln -s ~/.dotfiles/btop/btop.conf ~/.config/btop/btop.conf
```

#### Setup [Midnight Commander](https://midnight-commander.org/)

```sh
# mc config
ln -s ~/.dotfiles/mc/ini ~/.config/mc/ini
ln -s ~/.dotfiles/mc/panels.ini ~/.config/mc/panels.ini

# Dracula Color Scheme
# dracula
ln -s ~/.dotfiles/mc/skins/dracula.ini ~/.local/share/mc/skins/dracula.ini
# dracula256
ln -s ~/.dotfiles/mc/skins/dracula256.ini ~/.local/share/mc/skins/dracula256.ini
```

#### Install [neofetch](https://github.com/dylanaraps/neofetch)

```sh
sudo apt install neofetch
ln -s ~/.dotfiles/neofetch/config.conf ~/.config/neofetch/config.conf
```
#### Config [bat](https://github.com/sharkdp/bat)

```sh
ln -s ~/.dotfiles/bat/config ~/.config/bat/config
```

#### Config [WeeChat](https://github.com/weechat/weechat)

```sh
ln -s ~/.dotfiles/weechat/weechat.conf ~/.config/weechat/weechat.conf
ln -s ~/.dotfiles/weechat/plugins.conf ~/.config/weechat/plugins.conf
ln -s ~/.dotfiles/weechat/buflist.conf ~/.config/weechat/buflist.conf
ln -s ~/.dotfiles/weechat/spell.conf ~/.config/weechat/spell.conf
ln -s ~/.dotfiles/weechat/scripts.conf ~/.config/weechat/scripts.conf
```

#### Config [Spotify-tui](https://github.com/Rigellute/spotify-tui)

```sh
ln -s ~/.dotfiles/spotify-tui ~/.config/spotify-tui
```

___

## Gnome Shell Extensions

```sh
# Set gnome shell extensions
dconf load /org/gnome/shell/extensions/ < ~/.dotfiles/gnome-shell-extensions.ini

# Dump gnome shell extensions
dconf dump /org/gnome/shell/extensions/ > ~/.dotfiles/gnome-shell-extensions.ini

```
