# dotfiles, configs, and applications

This set of files includes dotfiles for GNU Stow, a Brewfile for installing applications, and commands for installing developer tools.

## Clone the repo into your home folder

```
cd ~
git clone git@github.com:cwsaylor/dotfiles.git
cd dotfiles
./scripts/setup.sh
```

## Setup Git and SSH keys

Generate your ssh keys via the instructions here:

https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

Now set your git username and email. It's set to load your local username and email from a separate gitconfig file that is not checked into the repo.

```
git config --file "$HOME/.gitconfig.local" user.name  "Mona Lisa"
git config --file "$HOME/.gitconfig.local" user.email  "overdrive@gibson.com"
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

## Neovim

I'm using the new built in package manager for neovim to manage plugins so the nightly needs to be installed.

* Leader set to space
* Leader + w - Write file
* Leader + q - Quit
* Leader + gb - Git blame line toggle
* Leader + o - Oil file explorer
* Leader + ff - Fuzzy find files
* Leader + ce - Copilot enable
* Leader + cd - Copilot disable
* Leader + cs - Copilot status
* Ctrl + l - Copilot suggestion accept
* Ctrl + ] - Copilot next suggestion
* Ctrl + \ - Copilot dismiss

## Vim

I'm using vim-plug to install my vim plugins. vim-plug will be auto-installed on first run.
Run `:PlugInstall` in vim if you add more plugins.

### Custom Vim Shortcuts

* Leader is set to space
* Ctrl + n — Toggle Explorer (netrw) in the same pane
* Ctrl + b — Toggle between last two open buffers
* Ctrl + h/j/k/l — Move to split left/down/up/right (Ctrl + l also redraws)
* space + w — Save file
* space + ff — Fuzzy find files (fzf :Files)
* space + q — Close current split/window
* space + t — Run nearest test
* space + T — Run test file
* space + a — Run test suite
* space + l — Run last test
* space + g — Switch to last test file
* space + s — Split below and open Explorer
* space + v — Split right and open Explorer
* space + L — Toggle display of invisible characters

## Flutter Development

```
sudo softwareupdate --install-rosetta --agree-to-license
```

Download flutter and install to ~/.flutter

* https://flutter.dev/
* https://developer.android.com/studio

