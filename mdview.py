#!/usr/bin/env python3
import os
import re
import subprocess
import sys
import pathlib

from markdown_it import MarkdownIt

RESEARCH_TOPICS = "/home/faris/dev/labs/research/topics"

md = MarkdownIt()
VERSION = "0.1.0"


def resolve_target(arg: str) -> pathlib.Path | None:
    if not arg:
        return None
    p = pathlib.Path(arg).expanduser()
    if p.is_file():
        return p
    if p.is_dir():
        for name in ("README.md", "readme.md"):
            cand = p / name
            if cand.is_file():
                return cand
        mds = sorted(p.glob("*.md"))
        if mds:
            return mds[0]
        return None
    cand = pathlib.Path(RESEARCH_TOPICS) / arg
    if cand.is_dir():
        return resolve_target(str(cand))
    if (pathlib.Path(RESEARCH_TOPICS) / (arg + ".md")).is_file():
        return pathlib.Path(RESEARCH_TOPICS) / (arg + ".md")
    return None


def slugify(text: str) -> str:
    s = re.sub(r"[^\w\s-]", "", text.lower()).strip()
    s = re.sub(r"[\s]+", "-", s)
    return s or "section"


def build_html(source: str, title: str) -> str:
    raw_html = md.render(source)
    toc_items = []
    def repl(m):
        level = int(m.group(1))
        inner = m.group(2)
        text = re.sub(r"<[^>]+>", "", inner)
        hid = slugify(text)
        if level <= 3:
            cls = "l2" if level == 2 else ("l3" if level == 3 else "")
            toc_items.append((level, hid, text, cls))
        return f'<h{level} id="{hid}">{inner}</h{level}>'
    html = re.sub(r"<h([1-3])>(.*?)</h\1>", repl, raw_html, flags=re.S)

    toc_html = ""
    for level, hid, text, cls in toc_items:
        toc_html += f'<li class="{cls}"><a href="#{hid}">{text}</a></li>\n'

    template_path = pathlib.Path(__file__).parent / "template.html"
    template = template_path.read_text(encoding="utf-8")
    return (template
            .replace("{{title}}", title)
            .replace("{{content}}", html)
            .replace("{{toc}}", toc_html))


def main():
    if len(sys.argv) > 1 and sys.argv[1] in ("-h", "--help"):
        print("mdview - native markdown viewer\nUsage: mdview.py [FILE|DIR|TOPIC_SLUG]\n  -h, --help     show this help\n  -V, --version  show version")
        return
    if len(sys.argv) > 1 and sys.argv[1] in ("-V", "--version"):
        print(VERSION)
        return
    arg = sys.argv[1] if len(sys.argv) > 1 else ""
    target = resolve_target(arg)
    if target is None:
        print(f"mdview: no markdown file found for: {arg!r}", file=sys.stderr)
        sys.exit(2)
    try:
        source = target.read_text(encoding="utf-8")
    except OSError as e:
        print(f"mdview: cannot read {target}: {e}", file=sys.stderr)
        sys.exit(2)
    title = target.stem
    html = build_html(source, title)
    try:
        subprocess.run(["vocus", "--title", title], input=html, text=True, check=False)
    except FileNotFoundError:
        print("mdview: 'vocus' not found on PATH; install vocus first", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"mdview: failed to start viewer: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()