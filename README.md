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
stow ghostty
stow git
stow neovim
stow p10k
stow vim
stow vscode
stow zsh
```

## Git setup

After running stow git, you will need to set your git username and email,
and then also save your email out to an environment variable for pgAdmin.

```
git config --global user.name "Mona Lisa"
git config --global user.email "overdrive@gibson.com"
```

## Docker

There are some environment varaibles that need setup before running the docker commands.

```
echo "export EMAIL=overdrive@gibson.com" >> ~/.env_vars
echo "export DOCKER_USERNAME=monalisa" >> ~/.env_vars
echo "export JUPYTER_TOKEN=token" >> ~/.env_vars
```

### Postgresql

pgAdmin has it's own login system and uses the EMAIL environment variable as the username and password.
adminer logs in with the postgresql username and password, which are both set to your system username, USER.

```
cd ~/dotfiles/docker/postgresql
docker compose up -d
```

For pgAdmin, vist http://127.0.0.1:8081
For adminer, vist http://127.0.0.1:8080

### Jupyter

There is a docker file for running Jupyter Notebook with Python, Ruby, Javascript, and Rust.
Your notebooks are stored in ~/jupyter. Edit the compose.yml and update the path to change.

Build the Dockerfile first.

```
cd ~/dotfiles/docker/jupyter
docker build -t $DOCKER_USERNAME/jupyter_with_ruby .
mkdir ~/jupyter
docker compose up -d
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

