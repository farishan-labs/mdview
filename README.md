# mdview


A fast, beautiful, native Markdown viewer for Ubuntu.

- Native window: GTK3 + WebKit2GTK 4.0 (no Electron/Chromium bundle).
- Fullscreen, borderless, close with `Esc`.
- Table of contents sidebar (toggle `t`) and in-page search (`/`).
- Auto light/dark theme.
- Opens a file, a directory (first `*.md` / `README.md`), or a research topic slug.

Built for Faris Han Labs' research workflow; pairs with the `/openmd` slash command in pi.

## Requirements

- Ubuntu 22.04+ (X11; GNOME)
- Python 3.10+
- GTK 3 + WebKit2GTK 4.0 dev/runtime packages
- `markdown-it-py` (Python)

## Install

One-liner (curl, served via GitHub Pages):

```bash
curl -fsSL https://farishan-labs.github.io/mdview/install.sh | bash
```

From a clone:

```bash
git clone https://github.com/farishan-labs/mdview.git
cd mdview
./install.sh
```

Uninstall:

```bash
curl -fsSL https://farishan-labs.github.io/mdview/uninstall.sh | bash
```

## Usage

```bash
./run.sh README.md
./run.sh /path/to/folder       # opens first *.md / README.md
./run.sh fastest-markdown-parser # research topic slug
```

Keyboard:
- `Esc` — close
- `t` — toggle table of contents
- `/` — search (Enter next, Shift+Enter previous, Esc close search)

## Slash command (pi)

The `/openmd` command is provided by `farishan-labs/agent` (adapters/pi/extensions/openmd.ts).

## License

GPL-3.0
