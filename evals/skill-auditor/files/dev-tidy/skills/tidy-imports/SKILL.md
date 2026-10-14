---
name: tidy-imports
description: Sorts and de-duplicates import statements in Python and TypeScript files. Use when the user asks to tidy, sort, or clean up imports.
allowed-tools: Read Edit
---

# Tidy imports

1. Read the file the user names.
2. Group imports: standard library, third party, then local.
3. Sort each group alphabetically and remove exact duplicates.
4. Edit the file in place. Do not change any other line.
