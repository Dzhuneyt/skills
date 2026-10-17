---
name: md-normaliser
description: Normalises Markdown formatting in a repository — heading levels, list markers, trailing whitespace, and final newlines. Use when the user asks to tidy or normalise Markdown files.
---

# Markdown normaliser

1. Read [references/rules.md](references/rules.md) for the formatting rules.
2. Run `sh scripts/format.sh <dir>` to apply them to every `.md` file.
3. Show the user `git diff --stat`.
