#!/usr/bin/env bash
# Installs agent CLIs. Optional; run after scripts/install.sh.
set -euo pipefail

command -v claude >/dev/null 2>&1 || \
  curl -fsSL https://claude.ai/install.sh | bash

command -v roborev >/dev/null 2>&1 || \
  curl -fsSL https://roborev.io/install.sh | bash
