# dotfiles and configs

These dotfiles are to be used with GNU Stow. Let's first install some tools. 

## XCode tools for MacOS

```
xcode-select --install
```

## Homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## oh my zsh

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Powerlevel 10k, auto suggestions, and syntz highlighting for ZSH
Run these commands to install. Then open a new terminal window to run the P10k configuration editor.
```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
```

## dotfiles setup with Stow
```
cd ~
mv .zshrc .zshrc.ohmyzshdefault
git clone git@github.com:cwsaylor/dotfiles.git
cd dotfiles
stow --dotfiles stow
stow zsh
stow git
stow p10k
stow vim
stow neovim
stow asdf
```
## Themes

### iTerm2

```
open ~/dotfiles/themes/iterm/TokyoNight.itermcolors
```
## Vim
I'm using vim-plug to install my vim plugins. vim-plug will be auto-installed on first run.
Run `:PlugInstall` in vim if you add more plugins.

https://github.com/tpope/vim-sensible
https://github.com/tpope/vim-commentary
https://github.com/tpope/vim-sleuth
https://github.com/tpope/vim-surround
https://github.com/vim-test/vim-test
https://github.com/kien/ctrlp.vim
https://github.com/tpope/vim-fugitive
https://github.com/bling/vim-airline

### Custom Vim Shortcuts

* Leader is set to space
* Ctrl + n - Toggle Explorer
* ctrl + p - Fuzzy find files
* ctrl + b - Toggle between last two open buffers
* <leader> + t - Run nearest test
* <leader> + T - Run test file
* <leader> + a - Run test suite
* <leader> + l - Run last test 
* <leader> + g - Switch to last test file

## NeoVim
I'm using Lazyvim to install my Neovim plugins.

