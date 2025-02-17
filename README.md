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

## On MacOS
```
cd dotfiles
brew bundle
```

## Cursor Extensions
Manually install [Cursor](https://www.cursor.com/) and the command line extension.
```
cursor --install-extension clemenspeters.format-json
cursor --install-extension eamodio.gitlens
cursor --install-extension enkia.tokyo-night
cursor --install-extension ms-python.debugpy
cursor --install-extension ms-python.python
cursor --install-extension ms-python.vscode-pylance
cursor --install-extension shopify.ruby-lsp
cursor --install-extension vscodevim.vim
```

## oh my zsh

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Powerlevel 10k, auto suggestions, and syntax highlighting for ZSH

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
stow asdf
stow cursor
stow git
stow kitty
stow neovim
stow p10k
stow vim
stow vscode
stow zsh
```

## asdf

You will need to install the plugins for the programs in ~/.tool-versions.
You can do this with the following command line:
```
awk '!/^#/ {print $1}' .tool-versions | xargs -I {} asdf plugin add {}
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

Run this in vim after installation:
`:Copilot setup`

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
