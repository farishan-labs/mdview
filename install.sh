#!/usr/bin/env bash
# Install mdview: native fullscreen Markdown viewer for Ubuntu.
# Works locally and via:  curl -fsSL https://farishan-labs.github.io/mdview/install.sh | bash
set -euo pipefail

REPO="farishan-labs/mdview"
DEST="${MDVIEW_DIR:-$HOME/dev/labs/mdview}"
BRANCH="${MDVIEW_BRANCH:-main}"

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""
fi

if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/mdview.py" ]]; then
  ROOT="$SCRIPT_DIR"
else
  if [[ ! -d "$DEST/.git" ]]; then
    echo "Cloning $REPO into $DEST ..."
    git clone "https://github.com/$REPO.git" "$DEST"
  else
    echo "Updating $DEST ..."
    git -C "$DEST" pull --ff-only || true
  fi
  ROOT="$DEST"
  exec bash "$ROOT/install.sh"
fi

BIN_DIR="${HOME}/.local/bin"
mkdir -p "$BIN_DIR"

# Dependency check / best-effort install.
missing=0
for pkg in "gtk+-3.0" "webkit2gtk-4.0"; do
  if ! pkg-config --exists "$pkg" 2>/dev/null; then
    echo "mdview: missing dev package: $pkg"
    missing=1
  fi
done
if ! python3 -c "import markdown_it" 2>/dev/null; then
  echo "mdview: missing python module: markdown-it-py"
  missing=1
fi
if [[ "$missing" -eq 1 ]]; then
  echo "mdview: attempting to install dependencies (may require sudo)..."
  if command -v sudo >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip libgtk-3-dev libwebkit2gtk-4.0-dev || true
    python3 -m pip install --user markdown-it-py || true
  else
    echo "mdview: sudo not available; install deps manually:" >&2
    echo "  sudo apt-get install python3 python3-pip libgtk-3-dev libwebkit2gtk-4.0-dev" >&2
    echo "  python3 -m pip install --user markdown-it-py" >&2
  fi
fi

# Launcher
cat > "$BIN_DIR/mdview" <<LAUNCHER
#!/usr/bin/env bash
exec python3 "$ROOT/mdview.py" "\$@"
LAUNCHER
chmod +x "$BIN_DIR/mdview"

echo "mdview: installed launcher to $BIN_DIR/mdview"
case ":${PATH}:" in
  *":${BIN_DIR}:"*) ;;
  *)
    echo "mdview: $BIN_DIR is not on PATH. Add:"
    echo "  export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac
