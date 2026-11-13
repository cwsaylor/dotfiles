# dotfiles

Managed with [chezmoi](https://chezmoi.io). This repo, checked out at `~/.local/share/chezmoi`,
is the source of truth; the files in `~` are generated from it by `chezmoi apply`.
Git name and email are prompted once per machine and saved to `~/.config/chezmoi/chezmoi.toml`,
which stays local. Nothing secret lives in this repo.

## What's here

| Source | Target | Purpose |
| --- | --- | --- |
| `dot_zprofile` | `~/.zprofile` | Homebrew `shellenv`, OrbStack integration |
| `dot_zshrc` | `~/.zshrc` | mise, starship, zoxide, fzf, history search, aliases, zsh plugins |
| `dot_vimrc` | `~/.vimrc` | Vim tuned for prose and markdown; vim-plug bootstraps itself on first run |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | delta pager, rebase/rerere defaults; `[user]` filled from the template |
| `dot_Brewfile` | `~/.Brewfile` | Everything Homebrew installs (formulae, casks, fonts) |
| `run_onchange_after_brew-bundle.sh.tmpl` | — | Runs `brew bundle` whenever the Brewfile changes |
| `dot_config/ghostty/config` | `~/.config/ghostty/config` | Terminal |
| `dot_config/mise/config.toml` | `~/.config/mise/config.toml` | Global Node, pnpm, Python versions |
| `dot_config/uv/uv.toml` | `~/.config/uv/uv.toml` | 7-day release cooldown, malware check |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Prompt |
| `private_dot_ssh/config` | `~/.ssh/config` (mode 0600) | SSH hosts |
| `.chezmoi.toml.tmpl` | `~/.config/chezmoi/chezmoi.toml` | Prompts for name and email on first `init` |
| `.chezmoiignore` | — | Repo-only files (this README) that must never be applied to `~` |

## New Mac from scratch

Steps 1–4 are the only ones that happen before chezmoi takes over.

1. **macOS basics.** Sign in to iCloud and the App Store. On a headless machine (the Mac mini):
   System Settings → Energy → never sleep; General → Sharing → Remote Login on.
2. **Command Line Tools.**
   ```sh
   xcode-select --install
   ```
3. **Homebrew.**
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
4. **chezmoi and the dotfiles.** No SSH keys exist yet, so clone over HTTPS and switch to SSH in step 8.
   ```sh
   brew install chezmoi
   chezmoi init --apply https://github.com/cwsaylor/dotfiles.git
   ```
   This prompts for git name and email, writes every dotfile, and runs `brew bundle`
   (slow the first time: Ghostty, OrbStack, Zed, fonts, all the CLIs). Open a new terminal when it finishes.
5. **Toolchains.**
   ```sh
   mise install                                           # Node 26/24, pnpm 12, Python 3.14/3.12
   pnpm config set minimumReleaseAge 4320 --location=user  # 3-day cooldown on npm packages
   ```
6. **Claude Code.**
   ```sh
   curl -fsSL https://claude.ai/install.sh | bash
   claude        # sign in
   ```
7. **1Password.** Install the app from the App Store. Settings → Developer: turn on
   "Integrate with 1Password CLI" and "Use the SSH agent". Then `brew install --cask 1password-cli`.
8. **Switch the dotfiles remote to SSH** now that the agent is running.
   ```sh
   chezmoi git -- remote set-url origin git@github.com:cwsaylor/dotfiles.git
   ```
9. **Sign in to CLIs.** `gh auth login`, `doppler login`, `render login`, `aws configure`, `doctl auth init` — whichever the machine needs.
10. **Apps that need a first launch.** Tailscale (App Store) → sign in, enable Tailscale SSH.
    OrbStack → open once and sign in. Ghostty → open once. Run `vim` once so vim-plug installs its plugins.
11. **Xcode.**
    ```sh
    xcodes install --latest --select
    xcodebuild -downloadPlatform iOS       # add watchOS / visionOS as needed
    ```
    Then Xcode → Settings → Accounts → add the developer account.
12. **Mac mini only.** Let SSH sessions see the terminal type (for Claude Code and Vim colors over Tailscale):
    ```sh
    sudo sh -c 'echo "AcceptEnv COLORTERM TERM_PROGRAM TERM_PROGRAM_VERSION" >> /etc/ssh/sshd_config'
    ```
13. **Check.** `chezmoi doctor`, `brew doctor`, `mise doctor`.

Manual steps not captured above (add as they come up):

- …

## Everyday chezmoi

| Command | What it does |
| --- | --- |
| `chezmoi add ~/.file` | Start managing a file (copies it into the source dir) |
| `chezmoi edit ~/.file --apply` | Edit the source copy and write it to `~` on save |
| `chezmoi re-add ~/.file` | Pull an edit made directly in `~` back into the source |
| `chezmoi diff` | What `apply` would change |
| `chezmoi apply -v` | Write all targets (`--dry-run` to preview) |
| `chezmoi status` | Targets that differ from the source |
| `chezmoi cd` | Shell in the source dir (then `lazygit`) |
| `chezmoi git -- push` | Any git command in the source dir without `cd` |
| `chezmoi update` | `git pull` + `apply` — the one command on the other machine |
| `chezmoi merge ~/.file` | Three-way merge when both sides changed |
| `chezmoi cat ~/.gitconfig` | Rendered output of a template, without writing it |
| `chezmoi data` | Variables available to templates on this machine |
| `chezmoi doctor` | Check the installation |

Alias: `cm` = `chezmoi`.

### Sync loop between machines

1. Edit here: `chezmoi edit ~/.zshrc --apply` (or edit in `~`, then `chezmoi re-add ~/.zshrc`).
2. Commit and push: `chezmoi cd` → `lazygit`, or `chezmoi git -- commit -am "msg" && chezmoi git -- push`.
3. There: `chezmoi update`. From the laptop: `ssh mini chezmoi update`.

### Changing what Homebrew installs

```sh
chezmoi edit ~/.Brewfile --apply      # apply reruns brew bundle because the Brewfile hash changed
```

After installing something by hand, capture it instead:

```sh
brew bundle dump --force --describe --file="$HOME/.Brewfile"
chezmoi re-add ~/.Brewfile
```

`brew bundle cleanup --file="$HOME/.Brewfile"` lists installed packages the Brewfile doesn't mention.

## Rules

- Never `chezmoi add` a file that contains a token or key. Git history keeps it forever.
- Add files, not directories: `chezmoi add ~/.ssh/config`, never `chezmoi add ~/.ssh`.
- Edit through chezmoi or `re-add` afterwards; `apply` prompts before overwriting a local edit.
- Anything that should live only in this repo (README, docs) goes in `.chezmoiignore`.
