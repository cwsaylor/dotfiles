#!/usr/bin/env bash
set -e

# Array of extension IDs
shared_extensions=(
  bradlc.vscode-tailwindcss
  clemenspeters.format-json
  denoland.vscode-deno
  dsznajder.es7-react-js-snippets
  esbenp.prettier-vscode
  golang.go
  laurencebahiirwa.deno-std-lib-snippets
  mechatroner.rainbow-csv
  ms-python.debugpy
  ms-python.python
  ms-python.vscode-python-envs
  shopify.ruby-lsp
  tamasfe.even-better-toml
  vscodevim.vim
  waderyan.gitblame
)

cursor_only=(
  anysphere.cursorpyright
)

vscode_only=(
  anthropic.claude-code
  github.copilot
  github.copilot-chat
  monokai.theme-monokai-pro-vscode
  ms-python.vscode-pylance
)

# Install in Cursor
for ext in "${shared_extensions[@]}" "${cursor_only[@]}"; do
  cursor --install-extension "$ext"
done

# Install in VSCode
for ext in "${shared_extensions[@]}" "${vscode_only[@]}"; do
  code --install-extension "$ext"
done

