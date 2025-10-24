bin/env bash
set -e

./1_install_xcode_tools.sh
./2_install_homebrew.sh
./3_install_ohmyzsh.sh
./4_install_stow.sh
./install_editor_extensions.sh
./install_javascript.sh
./install_ruby.sh