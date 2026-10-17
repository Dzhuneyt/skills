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
evals/<name>/             # evals for a skill: evals.json, test skills, BENCHMARK.md (never shipped)
```

## Rules when contributing

- **Naming convention** (enforced, not cosmetic):
  - `gh-*` — GitHub *platform* (PRs, notifications, reviews)
  - `git-*` — generic *local* git workflows (commit, rebase, branch cleanup)
  - plain name — everything else (`reflect`, `clipboard`, `tdd`)
- **Adding a skill** — create `skills/<name>/SKILL.md` with frontmatter `name:` (must equal the dir name) + a trigger-oriented `description:`. No registration step; both installers auto-discover it. **Then add a one-line bullet to the `### Skills` list in `README.md`** — the installers ignore README, but a skill missing from it is invisible to humans browsing the repo. Same rule for agents → `### Agents` list. A PR that adds a skill without its README bullet is incomplete.
- **Adding an agent** — create `agents/<name>.md` with frontmatter `name:` (must equal filename), `description:`, `tools:`, `model:`. Reaches **plugin users only** — that's expected, not a bug.
- **Versioning** — `plugin.json` has no `version`, so **every commit is a new plugin version**. Don't add a version field unless you intend to pin/freeze releases.
- **Surgical edits** — match each skill's existing voice and structure; don't refactor a skill while editing an adjacent one.

## Evals

A skill is a set of instructions for a model, so it has no unit tests. An eval runs the skill on a realistic request, then checks the answer against written expectations. Each case runs twice, once with the skill and once without it, because the skill is worth keeping only when it beats the model on its own.

- **Location.** Put evals in `evals/<skill-name>/`: `evals.json` for the cases, `files/` for the inputs, and `BENCHMARK.md` for the latest results. `evals.json` uses the format of Anthropic's `skill-creator` skill.
- **Keep evals out of `skills/`.** Both installers ship everything inside a skill's directory. Test inputs often include deliberately malicious skills, and these must never reach a user's machine.
- **Give test inputs neutral names.** A test skill called `obvious-malware` tells the model what to look for, and the result is then worthless. Use a name that a real author would choose, such as `table-formatter`.
- **Run the evals before you merge a change to a skill that has them.** Ask Claude to run `evals/<skill-name>/evals.json` with the `skill-creator` skill, with a baseline run that does not use the skill. Then update `BENCHMARK.md` with the results and the date.
- **A model costs money and gives different answers each time.** Do not run evals in CI on every push. Read the results as pass rates, not as a pass or a fail.

## Verifying a change

- `description:` is what the host uses to decide *when* to invoke a skill — write it trigger-first ("Use when the user…"), not feature-first.
- After editing, the change is live for both channels on the next install/commit; there is no build step.
