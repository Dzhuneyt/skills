---
name: gh-pr
description: Open a GitHub pull request (draft or ready for review) from the current branch using the gh CLI. Use this whenever the user wants to open, create, raise, submit, or "ship" a PR / pull request, or says things like "open a PR", "PR this branch", "put this up for review", or invokes /gh-pr — even when they don't specify the base branch, title, or description. Handles pushing the branch, writing the title and body from the actual diff, respecting the repo's PR template, linking issues, and dropping to --draft for unfinished work.
---

# gh-pr

Open a pull request from the current branch with a title and body that reflect what actually changed, not just the last commit message. The goal is a PR a reviewer can understand without reading the diff first.

Use `gh` for everything. It handles auth, the API, and returns a URL at the end. Do not script raw API calls.

## The shape of the work

Three phases, in order. The hard rule that drives the ordering: **nothing gets pushed until the work is confirmed to be on the right branch.** Phase 2 is entirely local and reversible; the first irreversible-ish action (push) is the top of Phase 3.

```
  Phase 1  Can I run?         local gates + gh auth
                              any gate fails -> stop
     |
     v
  Phase 2  Right place?       base -> assess -> branch-fit -> settle tree
                              all local, nothing pushed yet
     |
     v
  Phase 3  Open the PR        push -> compose -> gh pr create -> url
```

---

# PHASE 1 · Can I run?

## Step 0: cheap local gates

All local — no network, no push — so they fail in milliseconds before any expensive work. Order matters: cheapest and most fundamental first.

**Hard exits** — nothing downstream can recover, so bail immediately with a clear message:

1. **Not a git repo.** `git rev-parse --is-inside-work-tree`. Fastest check; run it first.
2. **`gh` not installed.** `command -v gh`. The cheap, local half of the auth check — keep it separate from `gh auth status` (network, see Preflight). "Not installed" and "not logged in" need different messages.
3. **Remote isn't GitHub.** `git remote get-url origin`, check the host. GitLab/Bitbucket/anything else → `gh` can't help, stop here.
4. **Detached HEAD or unborn branch.** `git symbolic-ref -q HEAD` (empty = detached; also catches a fresh repo with no commits). No branch means nothing to PR.

**Confirm and stop** — possible but almost always a mistake, so pause rather than refuse:

5. **On the default branch.** Resolve locally with `git symbolic-ref refs/remotes/origin/HEAD` to avoid a network call. A PR from `main` into `main` is almost always wrong. Caveat: that ref only exists if the clone set `origin/HEAD` (or someone ran `git remote set-head origin -a`); if it's missing, skip this here and let Preflight resolve the default branch over the network.
6. **Mid-operation.** Check for `MERGE_HEAD`, `.git/rebase-merge`, `.git/rebase-apply`, `.git/CHERRY_PICK_HEAD`, `.git/REVERT_HEAD`. A rebase/merge/cherry-pick/revert in flight means the tree is half-applied — a PR now is garbage.
7. **Zero commits ahead of base.** `git rev-list --count origin/<base>..HEAD`. Catches "already merged," "nothing to ship," and "wrong base" at once. `origin/<base>` may be locally stale — fine for a sanity check, don't treat it as authoritative.

Once Step 0 passes, `git branch --show-current` gives the head branch for everything below.

## Preflight (network)

Costs a round trip, so it runs only after Step 0 clears.

- `gh auth status` — confirm the CLI is authenticated. If not, point the user at `gh auth login`; do not log in for them.
- If `origin/HEAD` was missing in Step 0, resolve the default branch now (see Phase 2) and re-check the head branch isn't the default.

---

# PHASE 2 · Is the work in the right place?

Everything in this phase is local. Resolve all of it before pushing.

## Determine the base branch

```bash
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

Use the default unless the user named a different base. Stacked PRs (a feature branch targeting another feature branch) are real but rare — the user usually says so. When in doubt, ask rather than assume `main`.

## Assess local state

Gather the facts once; they feed both the branch-fit decision and the PR body.

```bash
git status --porcelain                                    # dirty tree?
git log --oneline origin/<branch>..HEAD                   # unpushed commits?
git log --reverse --format='%s%n%b' origin/<base>..HEAD   # commits since base
git diff --stat origin/<base>...HEAD                      # files + scope
gh pr list --head <branch> --state open --json number,url,title  # open PR?
```

The **local-only delta** = unpushed commits + uncommitted changes. That's the work that isn't yet captured anywhere — and it's the thing the branch-fit check reasons about.

## Branch-fit decision

The failure mode: the user finished feature A (maybe already PR'd), started feature B without switching branches, and is now about to push B's work onto A.

Do **not** anchor on "does the branch name match the diff." Generic/personal names (`dev`, `wip`, `dzh/misc`) match nothing and false-positive constantly, and branches legitimately grow scope. Anchor on whether the branch already has a PR and whether there's local-only work on top of it:

```
  open PR on branch?   local-only delta?   -> action
  -----------------------------------------------------------------
  no                   either                 open a fresh PR
  yes                  none                   nothing new -> stop
  yes                  some                   STOP and ask (below)
```

Only the last row stops a routine flow. In that case summarize the **delta only** (not the whole branch), e.g. "Branch `<branch>` already has open PR #123. You have 2 unpushed commits and 4 changed files since then — do these belong on this branch, or should they move to their own branch?"

Keep this gate high-precision. If it interrupts routine PRs with "are you sure you're on the right branch?", the user learns to mash through it and it stops being useful. Only the bottom-right cell stops the flow.

## If the work needs to move

The remedy forks on committed vs uncommitted, because the mechanics and risk differ sharply:

```
  move the work off this branch:

  uncommitted  ->  git switch -c <new> origin/<base>      safe, just do it
  committed    ->  git switch -c <new> origin/<base>      you do this
                   cherry-pick the stray commits onto <new>
                   ...then reset old branch + force-push   user's call — STOP
```

The committed path stops short of touching the old branch on purpose: cleaning the stray commits off it rewrites history, which needs a force-push — and this skill never force-pushes automatically, least of all on a branch that already has an open PR. Do steps 1–2, then hand the rewrite to the user.

The critical detail in both paths: fork from `origin/<base>`, **not** the current tip. `git switch -c <new>` from where you're standing bases the new branch on top of the old one, and its PR would then drag in all of the old branch's commits.

## Settle uncommitted changes

Now that the work is on the right branch:

```bash
git status --porcelain
```

If the tree is dirty, **surface the files and stop.** Do not commit on the user's behalf — they may be mid-thought, and a silent commit buries decisions they wanted to make. Ask: commit, stash, or leave out. If they ask you to commit, write the message as a Conventional Commit (see Phase 3) — pick the type from what changed, not a blanket `chore`.

---

# PHASE 3 · Open the PR

## Push the branch

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
```

- No upstream → `git push -u origin <branch>`.
- Upstream exists, local ahead → `git push`.
- Never `--force` or `--force-with-lease`. If the push is rejected, report it and let the user decide.

## Compose the title and body

Check for project conventions first:

- **PR template** — look for `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, or a `.github/PULL_REQUEST_TEMPLATE/` directory. If one exists, fill its sections rather than inventing your own structure. The maintainers chose that shape for a reason.
- **Linked issues** — scan the branch name and commits:
  - GitHub issues like `#123` / `fixes #123`.
  - Linear keys like `eng-412`, often in branch names (`dzh/eng-412-token-refresh`). Linear auto-links PRs whose title or body contains the key, so make sure it lands in one.
  - If the branch clearly maps to an issue but no closing keyword is present, add one (`Closes #123` / `Fixes ENG-412`) unless the change only partially addresses it.

**Title:** one line, imperative, describing the change as a whole — if the branch has five commits, summarize all of them, not commit #5. **Always Conventional Commit format**, regardless of the repo's existing style. Type and scope reflect the net change.

### Conventional Commit format

Used for the PR title and for any commit this skill creates:

```
type(optional-scope): short imperative description
```

- **Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. Pick the most specific that fits; don't default to `chore`.
- **Scope** is optional but useful — the package/module/area touched, e.g. `feat(auth):`.
- **Description** is lowercase, imperative, no trailing period, under ~72 chars.
- **Breaking changes:** append `!` after type/scope (`feat(api)!: ...`); for a commit, add a `BREAKING CHANGE:` footer.

If the change spans several types, pick the dominant one rather than inventing a compound type.

**Body** (when no template exists) — short and skimmable:

```markdown
## What
<one or two sentences on what this changes>

## Why
<the reason — the problem, the ticket, the regression>

## Notes for review
<anything non-obvious: tradeoffs, deferrals, areas to scrutinize>

<Closes #N / Fixes ENG-N if applicable>
```

Don't pad it. If "Notes for review" is empty, drop the section.

## Draft vs ready

Default to **ready for review**. Switch to `--draft` automatically if the branch looks unfinished — commit subjects containing `wip`, `tmp`, `fixup!`, or `squash!`. Always respect an explicit request for either (e.g. the user passes "draft" in $ARGUMENTS).

## Open

```bash
gh pr create \
  --base <base> \
  --head <branch> \
  --title "<title>" \
  --body "<body>" \
  [--draft]
```

Do **not** add reviewers, assignees, labels, or milestones unless asked — auto-assigning spams people and auto-labeling guesses at taxonomy you don't control.

If `gh pr create` says a PR already exists, don't open a second one — surface the existing URL and ask whether to update it (`gh pr edit`). (Phase 2 normally catches this first.)

## Finish

Print the PR URL on its own line. That's what the user wants. Don't summarize the diff back to them — they just wrote it.

---

## Hard limits

- Never force-push.
- Never auto-merge or enable auto-merge.
- Never commit uncommitted changes without explicit confirmation.
- Never open a PR from the default branch into itself.
- Never add reviewers/labels/assignees unprompted.
- Never push before the branch-fit decision is resolved.
