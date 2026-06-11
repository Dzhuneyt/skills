# AGENTS.md

Agent-facing context for the `dz` skills repo. User-facing docs (install, what's inside) live in `README.md` — read that first for the overview. This file is the contributor/agent guide: how the repo is wired and the rules to follow when changing it.

## What this repo is

One repo, **two distribution channels**, sharing the *same* `skills/<name>/SKILL.md` files:

| Channel | Installer | Ships | Names |
| --- | --- | --- | --- |
| Cross-agent | Vercel `skills` CLI (`pnpm dlx skills add Dzhuneyt/skills`) | skills only | flat (`/reflect`) |
| Claude Code plugin | `/plugin install dz@dzhuneyt` | skills **and** agents | namespaced (`/dz:reflect`) |

`SKILL.md` is the portable unit. The two installers sit on top of it. **One edit to a `SKILL.md` reaches both channels** — there is no per-channel copy to keep in sync.

## Layout

```text
.claude-plugin/
  plugin.json        # plugin "dz" — intentionally NO version field
  marketplace.json   # marketplace "dzhuneyt"; plugin source "./"
skills/<name>/SKILL.md   # one dir per skill; discovered by BOTH installers
agents/<name>.md         # Claude plugin channel ONLY (npx skills ignores these)
```

## Rules when contributing

- **Naming convention** (enforced, not cosmetic):
  - `gh-*` — GitHub *platform* (PRs, notifications, reviews)
  - `git-*` — generic *local* git workflows (commit, rebase, branch cleanup)
  - plain name — everything else (`reflect`, `clipboard`, `tdd`)
- **Adding a skill** — create `skills/<name>/SKILL.md` with frontmatter `name:` (must equal the dir name) + a trigger-oriented `description:`. No registration step; both installers auto-discover it.
- **Adding an agent** — create `agents/<name>.md` with frontmatter `name:` (must equal filename), `description:`, `tools:`, `model:`. Reaches **plugin users only** — that's expected, not a bug.
- **Versioning** — `plugin.json` has no `version`, so **every commit is a new plugin version**. Don't add a version field unless you intend to pin/freeze releases.
- **Surgical edits** — match each skill's existing voice and structure; don't refactor a skill while editing an adjacent one.

## Verifying a change

- `description:` is what the host uses to decide *when* to invoke a skill — write it trigger-first ("Use when the user…"), not feature-first.
- After editing, the change is live for both channels on the next install/commit; there is no build step.
