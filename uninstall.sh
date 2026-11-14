#!/usr/bin/env bash
# Uninstall mdview launcher (leaves the cloned repo in place).
set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
if [[ -f "$BIN_DIR/mdview" ]]; then
  rm -f "$BIN_DIR/mdview"
  echo "mdview: removed $BIN_DIR/mdview"
else
  echo "mdview: launcher not found at $BIN_DIR/mdview"
fi

REPO_DIR="${MDVIEW_DIR:-$HOME/dev/labs/mdview}"
read -r -p "Remove cloned repository at $REPO_DIR? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  rm -rf "$REPO_DIR"
  echo "mdview: removed $REPO_DIR"
fi
echo "mdview: uninstalled"
