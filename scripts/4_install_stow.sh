#!/usr/bin/env bash
set -e

brew install stow

mv .zshrc .zshrc.backup
mv .zprofile .zprofile.backup

stow --dotfiles --no-folding .
