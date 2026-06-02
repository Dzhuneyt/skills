---
name: gh-notifications
description: Use when user wants to review, triage, or surface important GitHub notifications — daily digest, notification fatigue, or "what should I look at?"
---

# GitHub Notifications Triage

## Overview

Fetch unread GitHub notifications via `gh api`, filter out noise, rank by importance, and present the top N (default 5) with clickable links. Requires `gh` CLI authenticated.

## Workflow

### 1. Fetch all unread notifications

```bash
gh api notifications --paginate --jq '.[] | {
  id: .id,
  type: .subject.type,
  title: .subject.title,
  repo: .repository.full_name,
  updated: .updated_at,
  reason: .reason,
  url: .subject.url,
  latest_comment_url: .subject.latest_comment_url
}'
```

### 2. Filter out noise

Remove low-signal notification types before ranking:
- **Always filter:** `CheckSuite` (CI pass/fail) — these are almost never actionable from the notification itself
- **Deprioritize:** `Release` notifications from third-party repos unless the user actively uses the library

### 3. Rank remaining notifications

Apply this priority order:

| Priority | Criteria |
|----------|----------|
| **P0 — Direct action needed** | `reason` is `review_requested`, `assign`, or `mention` |
| **P1 — Bug fixes and security** | Title contains `fix:`, `security`, `vulnerability`, `[BUG]`, or `breaking` |
| **P2 — Active work repos** | PRs and issues in repos the user owns or actively contributes to |
| **P3 — Feature work** | PRs with `feat:` in repos the user contributes to |
| **P4 — Everything else** | Discussions, external repo issues, chore/refactor PRs, `team_mention` |

Within each priority level, sort by most recently updated first.

**CRITICAL: `reason` is the *subscription* reason, not the *trigger*.** GitHub's `reason` field explains why the user is subscribed to the thread — it is **sticky** and reflects the *original* cause. It does NOT describe what generated *this* unread notification. Once a user is @mentioned in a thread, `reason` stays `mention` **forever**; a later unrelated comment, a label change, or a bot closing the issue will re-surface the thread as unread while still carrying `reason: mention`. So `reason: mention` can mean "you were mentioned 3 years ago and someone just commented" — not "you were just mentioned."

Consequence: a sticky `mention`/`review_requested` on a thread whose latest activity is unrelated to the user is often **stale noise**, not a fresh ask. Always check whether the *most recent* event actually involves the user (see step 4) before ranking it P0.

**`reason` field semantics (from the GitHub REST API docs).** These are distinct values — do not conflate them:
- `mention` — the user was **personally @mentioned** at some point, anywhere in the thread **including a comment** (not just the body). Sticky — see the warning above.
- `team_mention` — a **team the user belongs to** was @mentioned, not the user directly. Lower signal → P4 by default.
- `review_requested` — the user **or one of their teams** was asked to review. P0 — but also sticky; verify it's still open and assigned to them.
- `assign` — assigned to the issue/PR. `author` — they opened the thread. `comment` — activity on a thread they commented on. `subscribed` — watching the repo. `manual` — explicitly subscribed. `state_change` — they closed/merged it. `ci_activity` — a workflow they triggered finished.

### 4. Identify the *trigger*, not just the subscription reason (P0 candidates)

The `reason` is sticky (see warning in step 3), so a P0-looking `mention`/`review_requested` may be stale. Before ranking it P0, determine **what the most recent event actually was** and **whether it involves the user**. Compare the date of the user's involvement against the notification's `updated_at`. Run this step **only on P0 candidates** (a handful), not every notification — it costs 1-2 extra API calls each.

The list response already carries `subject.latest_comment_url` — a pointer to the latest **comment**. Fetch it directly instead of re-listing all comments. Caveat: it only points at comments. If the trigger was a non-comment event (issue closed, labeled, reopened), `latest_comment_url` is stale or null — fall back to the issue state or the Timeline API.

```bash
ME=$(gh api user --jq '.login')

# Cheapest: fetch the exact comment that bumped the thread (from subject.latest_comment_url)
gh api {latest_comment_url} --jq '{user: .user.login, created: .created_at, url: .html_url, body: .body}'

# Catch non-comment triggers (close/reopen/label) that latest_comment_url misses
gh api repos/{owner}/{repo}/issues/{n} --jq '{state, closed_at, updated_at}'

# Where/when was the user actually @mentioned? (may be old). NOTE: pipe to standalone jq — gh api has no --arg
gh api repos/{owner}/{repo}/issues/{n}/comments \
  | jq --arg me "$ME" '.[] | select(.body | test("@" + $me + "(?![A-Za-z0-9-])"; "i")) | {user: .user.login, created: .created_at, url: .html_url, body: .body}'

# Full event fidelity (who did what, when) — every close/label/mention/review as discrete events
gh api repos/{owner}/{repo}/issues/{n}/timeline --jq '.[] | {event: .event, actor: .actor.login, created: .created_at}'
```

Decision:
- **Latest event involves the user** (fresh @mention, review just requested, reply to their comment) → keep P0, deep-link to that event (`.html_url`) and quote it.
- **Latest event is unrelated** (someone else's comment, a bot closing/labeling the issue, `state_change` by another user) → **downgrade**. Label it honestly, e.g. "mentioned 2023; resurfaced by a new comment from @other" or "issue closed by bot — likely just-archive." Don't present it as a fresh ask.

### 5. Build clickable links

Convert API URLs to browser URLs:
- `https://api.github.com/repos/{owner}/{repo}/pulls/{n}` → `https://github.com/{owner}/{repo}/pull/{n}`
- `https://api.github.com/repos/{owner}/{repo}/issues/{n}` → `https://github.com/{owner}/{repo}/issues/{n}`
- For Discussion type, construct: `https://github.com/{owner}/{repo}/discussions`

### 6. Present results

Output a numbered list with:
- Priority tag (P0-P4)
- Notification type (Issue, PR, Discussion)
- Title
- Clickable GitHub link (deep-link to the mentioning comment for `mention` items)
- Brief reason why it ranked high (1 short phrase). For mentions, quote the @mention and name who wrote it — not "you were mentioned" alone.

Example output:
```
1. [P0] PR: feat: Add stress testing helper endpoints
   https://github.com/protokol/dpp-api/pull/343
   Review requested from you

2. [P1] Issue: [BUG] Statusline context_window JSON...
   https://github.com/anthropics/claude-code/issues/13783
   Bug report, updated today

3. [P4] Issue: AWS::CertificateManager::Certificate deletion fails...
   https://github.com/aws-cloudformation/cloudformation-coverage-roadmap/issues/837
   reason=mention but stale: you were @mentioned in 2023; resurfaced by @marat-affinidi's new comment — not a fresh ask
```

### 7. Offer follow-up actions

After presenting the top N, ask:
- "Want me to mark the rest as read?"
- "Want me to open any of these?"

## Customization

The user may invoke this skill with arguments:
- `/gh-notifications` — default top 5
- `/gh-notifications 10` — top 10
- `/gh-notifications --mark-read` — also mark non-top notifications as read after presenting

## Common Mistakes

- Don't fetch notification details one-by-one (N+1 API calls) — use `--jq` to extract what you need in one paginated call
- Don't show raw API URLs — always convert to clickable `github.com` links
- Don't include CheckSuite notifications in the ranked output — they are pure noise
- Don't read `reason` as the *trigger*. It's the sticky *subscription* reason — `reason: mention` can mean "mentioned years ago, someone just commented." Always check the latest event (step 4) before ranking P0
- Don't assert "you were mentioned" (present tense) from the `reason` field — the mention is usually old and buried in a comment. Verify when/where it happened and who triggered the current notification
- Don't treat `team_mention` as a personal `mention` — it means a team you're on was tagged, not you. They are separate `reason` values
