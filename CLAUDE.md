# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [chezmoi](https://chezmoi.io) source directory for macOS (Apple Silicon) dotfiles, shared between a laptop and a headless Mac mini. Files here are the source of truth; `chezmoi apply` generates the real files in `~`. `README.md` has the source → target table, the new-machine runbook, and the everyday command list — read it before changing behavior, and keep it in sync when you add or remove a managed file or automate a manual step.

## How source names map to targets

- `dot_foo` → `~/.foo`; `private_` → mode 0600; `.tmpl` → rendered as a Go template first.
- Template data is `.name` and `.email` only, prompted once per machine by `.chezmoi.toml.tmpl` and stored in `~/.config/chezmoi/chezmoi.toml` (never in this repo).
- Any file at the repo root that is not chezmoi-prefixed is still applied to `~` unless it is listed in `.chezmoiignore`. `README.md` and `CLAUDE.md` are listed there; add any new repo-only file to it in the same change.

## Scripts

`run_onchange_after_<name>.sh.tmpl` scripts run at the end of `chezmoi apply`, and only when their rendered content changes. Each embeds a hash of the file it reacts to, so editing that file is what triggers the rerun:

```sh
# Brewfile hash: {{ include "dot_Brewfile" | sha256sum }}
```

- `brew-bundle` reruns `brew bundle` when `dot_Brewfile` changes.
- `mise-install` reruns `mise install -y` when `dot_config/mise/config.toml` changes.

`after` scripts run in alphabetical order of their target name. `mise-install` relies on sorting after `brew-bundle`, because Homebrew is what installs mise on a fresh machine. Name new scripts with that ordering in mind.

Scripts run as non-interactive `/bin/zsh`, so `.zshrc`/`.zprofile` are not sourced; tools must already be on the `PATH` of whoever ran `chezmoi`.

## Commands

```sh
chezmoi status                             # targets that differ; R = a script that will run
chezmoi diff                               # what apply would change
chezmoi execute-template < file.tmpl       # render one template to stdout
chezmoi apply --dry-run -v                 # preview everything
chezmoi apply --include=scripts -v         # run pending scripts without touching dotfiles
chezmoi apply -v ~/.zshrc                  # apply a single target
chezmoi doctor
```

There is no build, lint, or test suite. Verifying a change means rendering it (`execute-template`, `diff`, `--dry-run`) and then applying it.

## Working here

- Check `chezmoi status` before any `apply`. A target showing `MM` was edited in `~` after the last apply; a full `chezmoi apply` prompts before overwriting it, which fails without a TTY and would discard the local edit. Apply specific targets or `--include=scripts` instead, and tell the user about the drift rather than resolving it for them.
- `autoCommit` and `autoPush` are on, but they only fire for chezmoi commands that modify the source (`chezmoi add`, `edit`, `re-add`). Files edited directly in this directory stay uncommitted until someone commits and pushes them. `origin` is a GitHub repo, so anything committed through chezmoi is published immediately.
- Nothing secret goes in this repo. Add individual files, never directories (`chezmoi add ~/.ssh/config`, not `~/.ssh`).
- Homebrew packages belong in `dot_Brewfile` and tool versions in `dot_config/mise/config.toml`, not in ad hoc install commands. Both the mise and uv configs enforce a release-age cooldown (3 days and 7 days); keep that when editing them.
