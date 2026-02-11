bin/env bash
set -e

./scripts/1_install_xcode.sh
./scripts/2_install_homebrew.sh
./scripts/3_install_ohmyzsh.sh
./scripts/4_install_stow.sh
./scripts/5_install_javascript.sh
./scripts/6_install_ruby.sh
./scripts/7_install_editor_extensions.sh
./scripts/8_install_ai.sh
