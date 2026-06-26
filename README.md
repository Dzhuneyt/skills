# dz — Dzhuneyt's skills & agents

One repo, two distribution channels, sharing the **same** `skills/<name>/SKILL.md` files:

| Channel | Tool | Ships | Names |
| --- | --- | --- | --- |
| Cross-agent skills | Vercel `skills` CLI | skills only | flat (`/reflect`) |
| Claude Code plugin | `/plugin` | skills **and** agents | namespaced (`/dz:reflect`) |

`SKILL.md` is the portable unit. The two installers sit on top of it.

## Install

### Cross-agent (Claude / Cursor / Codex / …) — skills only

```bash
pnpm dlx skills add Dzhuneyt/skills   # or: npx skills add Dzhuneyt/skills
```

### Claude Code plugin — skills + agents

```text
/plugin marketplace add Dzhuneyt/skills
/plugin install dz@dzhuneyt
```

After install, skills appear as `/dz:<skill>` and agents show up in `/agents`.

> Agents reach **plugin** users only — `npx skills` installs skills, not agents. That's expected.

## What's inside

```text
.
├── .claude-plugin/
│   ├── plugin.json        # plugin manifest (name "dz", no version → every commit is a new version)
│   └── marketplace.json   # marketplace "dzhuneyt"; plugin source "."
├── skills/
│   └── reflect/SKILL.md   # discovered by BOTH npx skills AND the plugin
├── agents/
│   └── example-agent.md   # Claude plugin channel only
└── README.md
```

### Skills

Naming convention: `gh-*` = GitHub platform (PRs, notifications), `git-*` = generic local git workflows, plain names for everything else.

- **reflect** — end-of-session reflection: surfaces dropped action items, stale docs, and harness/CLAUDE.md gaps, then acts on the ones you pick.
- **gh-pr** — open a PR (draft or ready) from the current branch; writes title/body from the diff, respects the repo template, links issues.
- **gh-pr-review** — thorough structured review of a PR by number/URL/branch.
- **gh-notifications** — triage unread GitHub notifications, filter noise, rank by importance.
- **git-commit** — analyze changes and commit with a conventional message (+ optional push).
- **git-update** — safely fetch/stash/rebase/restore the current branch.
- **git-branch-cleanup** — delete merged branches, protect unpushed work.
- **git-diff-explain** — one-sentence summary of uncommitted changes.
- **new-project** — disciplined intake for a project from scratch: interview one topic at a time, write an AI-readable vision doc, walk the key technical decisions, then propose a staged build plan.
- **tdd** — strict Test-Driven Development workflow.
- **refactor-safe** — suggest low-risk refactors grouped by safety level (suggest-only).
- **code-comments-improve** — improve code comments, WHY over WHAT.
- **apple-reminders** — manage Apple Reminders via AppleScript. _macOS-only._
- **clipboard** — copy the last output to the clipboard via `pbcopy`. _macOS-only._

### Agents (plugin channel only)

- **example-agent** — neutral starter subagent stub. Replace with a real agent.

## Naming

- **Marketplace:** `dzhuneyt` · **Plugin:** `dz`
- The plugin name *is* the slash-command prefix, so skills are `/dz:<skill>`. There is no separate alias — to change the prefix, rename the plugin.

## Versioning

`plugin.json` omits `version` on purpose: **every git commit is a new version**, so installed users always track `main`. To switch to explicit releases, add `"version": "1.0.0"` and bump it on each release.

## Adding a skill

1. `mkdir -p skills/<name>`
2. Create `skills/<name>/SKILL.md` with frontmatter (`name` must equal the folder; `description` states WHEN to use it — it's the trigger for both tools):

   ```markdown
   ---
   name: <name>
   description: One line stating WHEN to use this skill.
   # optional (Claude only): disable-model-invocation: true   # manual /command only
   # optional (Claude only): allowed-tools: [Read, Edit, Bash]  # omit = full access
   ---

   Instructions here. Use $ARGUMENTS to capture text typed after the command.
   ```

3. Commit + push. Both channels pick it up.

## Adding an agent (plugin channel only)

Create `agents/<name>.md` as a standard Claude subagent definition (frontmatter `name`/`description`, optional `tools`/`model`, then the system prompt). See `agents/example-agent.md`.

## Develop / validate / test

```bash
# Validate the plugin manifest
claude plugin validate

# Test the plugin locally (skills → /dz:<skill>, agents → /agents)
claude --plugin-dir .
#   then inside the session:  /reload-plugins

# Test the cross-agent (Vercel skills) channel sees the skills
pnpm dlx skills add ./ --list   # or: npx skills add ./ --list
```

## License

MIT — see [LICENSE](LICENSE).
