#!/usr/bin/env bash
set -e

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

curl -fsSL https://bun.sh/install | bash
curl -fsSL https://deno.land/install.sh | bash
