# dotfiles, configs, and applications

This set of files includes dotfiles for GNU Stow,
a Brewfile for installing applications,
and commands for installing developer tools.

## First Steps

Generate or restore ssh keys.

https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

Fix DNS settings to point to Cloudflare 1.1.1.1 and 1.0.0.1

## XCode tools for MacOS

```
xcode-select --install
sudo xcodebuild -license accept
```

## oh my zsh

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

After running stow git, you will need to set your git username and email,
and then also save your email out to an environment variable for pgAdmin.

```
git config --global user.name "Mona Lisa"
git config --global user.email "overdrive@gibson.com"
```

## Homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the install directions and immediately install stow.

```
brew install stow
cd dotfiles
stow --dotfiles zsh
```

Open a new tab

## On MacOS
```
cd dotfiles
brew bundle
```

## Cursor Extensions
Manually install [Cursor](https://www.cursor.com/) and the command line extension.
```
./setup_cursor.sh
```

## dotfiles setup with Stow

```
cd ~
mv .zshrc .zshrc.ohmyzshdefault
mv .zprofile .zprofile.default
git clone git@github.com:cwsaylor/dotfiles.git
cd dotfiles
stow --dotfiles .
```

## Docker

Install Docker Desktop
https://www.docker.com/products/docker-desktop/

There are some environment varaibles that need setup before running the docker commands.

```
echo "export EMAIL=overdrive@gibson.com" >> ~/.env_vars
echo "export DOCKER_USERNAME=monalisa" >> ~/.env_vars
echo "export JUPYTER_TOKEN=token" >> ~/.env_vars

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
For adminer, vist http://127.0.0.1:8082

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
* ctrl + j - Move to split down
* ctrl + k - Move to split up
* ctrl + l - Move to split right
* ctrl + h - Move to split left
* ctrl + c - Close buffer
* space + t - Run nearest test
* space + T - Run test file
* space + a - Run test suite
* space + l - Run last test 
* space + g - Switch to last test file
* space + s - Split below and open netrw
* space + v - Split right and open netrw

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

## Deno

curl -fsSL https://deno.land/install.sh | sh

## Flutter Development

* https://flutter.dev/

## Manual Installs

* https://one.one.one.one/
* https://www.techsmith.com/camtasia/
* https://www.techsmith.com/snagit/
