#!/usr/bin/env bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

npm install -g @openai/codex
npm install -g @shopify/cli@latest
npm install -g @anthropic-ai/claude-code
npm install -g @mermaid-js/mermaid-cli
curl -fsSL https://bun.sh/install | bash
curl -fsSL https://deno.land/install.sh | bash
