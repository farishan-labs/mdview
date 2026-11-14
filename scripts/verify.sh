#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 -m py_compile mdview.py
pkg-config --modversion gtk+-3.0
pkg-config --modversion webkit2gtk-4.0
python3 -c "import markdown_it; print('markdown-it ok')"
timeout 5 python3 mdview.py README.md >/tmp/mdview-smoke.log 2>&1 || true
echo "verify done"
