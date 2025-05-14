u dotfiles and configs

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
cursor --install-extension bierner.markdown-mermaid
cursor --install-extension bradlc.vscode-tailwindcss
cursor --install-extension clemenspeters.format-json
cursor --install-extension dart-code.dart-code
cursor --install-extension dart-code.flutter
cursor --install-extension dsznajder.es7-react-js-snippets
cursor --install-extension eamodio.gitlens
cursor --install-extension enkia.tokyo-night
cursor --install-extension esbenp.prettier-vscode
cursor --install-extension ms-python.debugpy
cursor --install-extension ms-python.python
cursor --install-extension ms-python.vscode-pylance
cursor --install-extension ms-vscode-remote.remote-containers
cursor --install-extension ms-vscode.makefile-tools
cursor --install-extension shopify.ruby-lsp
cursor --install-extension vscodevim.vim
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
stow cursor
stow ghostty
stow git
stow nushell
stow ohmyposh
stow ssh
stow vim
stow vscode
stow zellij
stow zsh
```

## Docker

There are some environment varaibles that need setup before running the docker commands.

```
echo "export EMAIL=overdrive@gibson.com" >> ~/.env_vars
echo "export DOCKER_USERNAME=monalisa" >> ~/.env_vars
echo "export JUPYTER_TOKEN=token" >> ~/.env_vars

```

## Git setup

After running stow git, you will need to set your git username and email,
and then also save your email out to an environment variable for pgAdmin.

```
git config --global user.name "Mona Lisa"
git config --global user.email "overdrive@gibson.com"
```

### Postgresql

pgAdmin has it's own login system and uses the EMAIL environment variable as the username and password.
adminer logs in with the postgresql username and password, which are both set to your system username, USER.

When configuring the database connection, use the hostname "db", as that's the name defined in the compose.yml file for 
communications inside of the docker network.

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

## Node Version Manager

Run the latest install inscript here:
https://github.com/nvm-sh/nvm

```
nvm install --lts
```

## Ruby

```
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install 3.4.4
rbenv global 3.4.4
```

