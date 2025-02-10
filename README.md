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
