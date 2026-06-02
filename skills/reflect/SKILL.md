---
name: reflect
description: Use when the user invokes /reflect or asks to reflect on, wrap up, or take stock of the current session. Re-reads the in-context conversation and surfaces dropped action items, stale docs, and harness/CLAUDE.md improvement opportunities as small triageable steps, then acts in-session on the ones the user selects. Not a git-history retro and not a full doc audit.
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
- Primary heuristic: find assistant messages that bundled **two or more** decisions/questions into one block, then check whether the user's next reply addressed *all* of them. The unaddressed ones are the highest-value finds — the user reacted to part of a wall of text and the rest fell through.
- Also catch: explicit "let's do X later", TODOs raised but never returned to, errors acknowledged but not fixed.
- Bar: concrete evidence in the conversation that the item was raised and never closed.

**B. Doc gaps** — docs made stale by *this session's* changes.
- Targeted only: "README section X is now wrong because we changed Y." Name the file and the specific staleness.
- Bar: a change made this session directly contradicts existing documented behavior. Never propose a from-scratch documentation audit.

**C. Harness gaps** — repetitive work a new Skill or Agent could absorb.
- Bar: the pattern recurred **at least twice** this session, or is obviously recurring work. A single occurrence does not qualify.

**D. CLAUDE.md gaps** — global-instruction improvements. Tag each finding as one of:
- **prose** → a CLAUDE.md edit (a principle, preference, or convention the user clearly holds but hasn't written down).
- **hook** → a `settings.json` hook, NOT prose. Anything of the form "from now on, whenever X, do Y" is an automated behavior the harness must execute — it cannot live as CLAUDE.md text. Route these through the `update-config` skill when acting.

## Step 3 — Surface for triage

Present findings through `AskUserQuestion` so each is a discrete, digestible card — never a wall of text.

- One `multiSelect` question per **non-empty** category. Each finding is one option: a 1-line label plus a short description. The cards are the reading material; do not precede them with a separate text dump.
- `AskUserQuestion` requires **at least 2 options** per question. When a category has exactly one finding, add a second "Nothing here — skip" option so the user can decline cleanly.
- Triage **all** categories first (one `AskUserQuestion` call carrying up to 4 category questions), then act — keep reading up front and action second.
- **Paginate** any category with more than 4 findings: ask that category in successive rounds of 4 until exhausted.
- Skip empty categories silently. If all four are empty, say "Nothing worth flagging" and stop.

## Step 4 — Act on the selections

Walk the selected items **one at a time**. For each: state the concrete change, get confirmation, then do it in this session.

- **A (loose ends):** complete the dropped item, or if it's large, confirm the smallest next step.
- **B (doc gaps):** produce the exact diff and apply on approval.
- **D (CLAUDE.md):** prose → exact CLAUDE.md diff for approval; hook → invoke `update-config` to wire the hook.
- **C (harness):** draft a `SKILL.md` skeleton or propose `/gstack-skillify`. The user may accept the stub or defer — do not force a full new skill build inside `/reflect`.

Persist nothing to disk unless the user explicitly asks for a written record.
