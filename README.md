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
stown vim
```

## Themes

The themes folder contains my favorite themes.

## iTerm2

```
open ~/dotfiles/themes/iterm/TokyoNight.itermcolors
```

