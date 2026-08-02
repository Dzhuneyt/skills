---
name: reflect
description: Use when the user invokes /reflect or asks to reflect on, wrap up, or take stock of the current session. Re-reads the in-context conversation and surfaces dropped action items, stale docs, skillify opportunities, and CLAUDE.md/AGENTS.md improvements as a ranked shortlist, then acts in-session on the ones the user selects. Not a git-history retro and not a full doc audit.
---

# Reflect

End-of-session reflection. Re-read the current conversation, surface what slipped through, and act on what the user chooses — all before the session wraps.

## Scope and stance

- **Conversation-scoped.** Reflect over the conversation that is in context. Do NOT parse transcript files or git history. This is not `gstack-retro` (commit-history retro) and not `gstack-learn` (learnings store) — stay in the forward-action lane.
- **Compaction honesty.** If the session was compacted, reflect on what survived and say so plainly. Do not fabricate recall of summarized turns.
- **No artifact by default.** Findings live in the conversation. The surfaced list is throwaway — the user reacts or ignores it. Write a file ONLY if the user explicitly asks.
- **Under-report, never spam.** A wrong "loose end" or a skill suggestion for one-off work is worse than silence. Apply the confidence bars below. When in doubt, drop it.

## Step 1 — Reflect

Re-read the conversation end to end. Hold the whole arc in mind before flagging anything.

## Step 2 — Run the four detectors

Each detector has a hard confidence bar. An item that does not clear its bar is silently dropped.

**A. Loose ends** — action items or decisions the user skipped.
- Primary heuristic: find assistant messages that bundled **two or more** decisions/questions into one block, then check whether the user's next reply addressed *all* of them. Example: you asked three things, the user answered one. The unaddressed ones are the highest-value finds — the user reacted to the top of a wall of text and the rest fell through unread.
- Also catch: explicit "let's do X later", TODOs raised but never returned to, errors acknowledged but not fixed.
- Bar: concrete evidence in the conversation that the item was raised and never closed.

**B. Doc gaps** — docs made stale by *this session's* changes.
- Targeted only: "README section X is now wrong because we changed Y." Name the file and the specific staleness.
- Bar: a change made this session directly contradicts existing documented behavior. Never propose a from-scratch documentation audit.

**C. Skillify / harness gaps** — repetitive work a new Skill or Agent could absorb, or a multi-step recipe worth capturing as a reusable skill.
- Bar: the pattern recurred **at least twice** this session, or is obviously recurring work. A single occurrence does not qualify.

**D. CLAUDE.md / AGENTS.md gaps** — memory-file improvements. Tag each finding on two axes:
- **Scope:** `project` (repo-local `CLAUDE.md`/`AGENTS.md`) vs `global` (user's `~/.claude/CLAUDE.md`). Pick by whether the preference is repo-specific or holds everywhere.
- **Kind:**
  - **append** → a new principle, preference, or convention the user clearly holds but hasn't written down.
  - **rewrite** → an *existing* sentence this session proved wrong, stale, or misleading. Quote the current line and propose the replacement wording — don't just add on top of it.
  - **hook** → a `settings.json` hook, NOT prose. Anything of the form "from now on, whenever X, do Y" is an automated behavior the harness must execute — it cannot live as memory-file text. Route these through the `update-config` skill when acting.
- Bar: clear evidence the user holds the preference — they stated it, corrected you on it, or it recurred. A one-off stylistic choice does not qualify.

## Step 3 — Collect into one flat, ranked list

Gather every finding that cleared its bar — across **all four** detectors — into a single flat list held in memory. Keep each finding's category tag (A/B/C/D), but do NOT group the list by category.

- **Rank** by value = confidence × impact. A genuine dropped decision the user cares about outranks a nice-to-have doc tweak. Your #1 is what you'd most want the user to act on.
- **Take the top 5.** Discard the rest. If more than 5 cleared their bars, say so in one line (e.g. "3 lower-confidence items dropped") so the user knows there's a tail, but do not surface them.
- If nothing cleared any bar, say "Nothing worth flagging" and stop.

## Step 4 — Ask one finding at a time

Surface the shortlist as **separate, single-select `AskUserQuestion` questions — one question per finding**, in ranked order so your strongest recommendation comes first. Do NOT bundle findings into a single `multiSelect` question; that grouping gets in the way. Each finding is its own decision.

For each finding's question:
- `header`: the category label — "Loose end", "Doc gap", "Skillify", or "CLAUDE.md".
- `question`: state the finding concretely (what was dropped / what's stale / what to capture), then ask what to do.
- `options` (single-select, `multiSelect: false`): put **your recommended action first**, labeled `(Recommended)`. Follow with the realistic alternatives, ending with a clean decline. Typical recommended actions by category:
  - **A (loose end):** "Finish it now" — or, if large, "Do the smallest next step".
  - **B (doc gap):** "Show the diff and apply".
  - **C (skillify):** "Draft the SKILL.md skeleton".
  - **D (CLAUDE.md/AGENTS.md):** append/rewrite → "Show the edit and apply"; hook → "Wire the hook via update-config".
  - Always include a "Skip" / "Leave it" option last.

Ask them one at a time (or a few per call, but never more than one **finding** per question). This lets you act on each answer before moving on.

## Step 5 — Act on each selection

For each finding the user chose to act on, do it in this session immediately:

- **A (loose ends):** complete the dropped item, or confirm the smallest next step if it's large.
- **B (doc gaps):** produce the exact diff and apply on approval.
- **C (skillify):** draft a `SKILL.md` skeleton or propose `/gstack-skillify`. Don't force a full skill build inside `/reflect` — the stub or a deferral is fine.
- **D (CLAUDE.md/AGENTS.md):** append/rewrite → show the exact memory-file diff (quoting the old line for a rewrite) and apply on approval; hook → invoke `update-config` to wire it.

Persist nothing to disk unless the user explicitly asks for a written record.
