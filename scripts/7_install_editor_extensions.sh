#!/usr/bin/env bash
set -e

# Array of extension IDs
shared_extensions=(
  anthropic.claude-code
  bradlc.vscode-tailwindcss
  clemenspeters.format-json
  denoland.vscode-deno
  dsznajder.es7-react-js-snippets
  eamodio.gitlens
  esbenp.prettier-vscode
  golang.go
  laurencebahiirwa.deno-std-lib-snippets
  mechatroner.rainbow-csv
  monokai.theme-monokai-pro-vscode
  ms-python.debugpy
  ms-python.python
  ms-python.vscode-python-envs
  ritwickdey.liveserver
  shopify.ruby-lsp
  tamasfe.even-better-toml
  vscodevim.vim
  waderyan.gitblame
)

cursor_only=(
  anysphere.cursorpyright
)

vscode_only=(
  ms-python.vscode-pylance
  github.copilot
  github.copilot-chat
)

# Install in Cursor
# for ext in "${shared_extensions[@]}" "${cursor_only[@]}"; do
#   cursor --install-extension "$ext"
# done

# Install in VSCode
for ext in "${shared_extensions[@]}" "${vscode_only[@]}"; do
  code --install-extension "$ext"
done

