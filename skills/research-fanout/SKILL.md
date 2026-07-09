---
name: research-fanout
description: Interactive research orchestrator. Scopes a high-level research goal through a short interview, presents an approvable nested plan tree of sub-questions ("unknown unknowns"), then fans out parallel subagents (with per-branch model tiering for cost) and rolls up their findings live into a written report plus executive summary. Use when the user wants to research a broad or fuzzy topic, explore unknown unknowns, run a deep multi-angle investigation, or mentions fan-out research, a research plan, or a research report.
---

# Research Fan-out

Turn one fuzzy research goal into parallel, cost-tiered investigation. Interview to scope → get an approved plan tree → fan out subagents → roll up findings as each completes → deliver a report.

**Task:** $ARGUMENTS

Distinct from `deep-research` (non-interactive web-search harness): this skill front-loads an **interactive scoping interview** and an **approvable plan tree**, tiers models per branch for cost, and streams a **per-fork rollup** the user can steer mid-flight.

## Stage 1 — Orient

- Read `$ARGUMENTS`. If clear, go to Stage 2.
- If terms are ambiguous, run 1–3 quick web searches to ground yourself before interviewing. Goal: understand the domain well enough to count research forks correctly — not to answer the question yet.

## Stage 2 — Interview (max 3 questions)

Narrow the scope. Hard cap: **3 questions, one at a time**.

- Multiple-choice preferred; open-ended when needed.
- **After every user answer**, reply with a 1–2 sentence glanceable restatement of the understood goal (no more).
- Stop early once scope is clear — do not burn questions for their own sake.

## Stage 3 — Plan tree (approval gate)

Present a nested bullet tree — the "big picture" of the research path:

- **~3 top-level branches** (adaptive 2–5), each phrased as a **question** the user should be asking (the unknown unknowns), not a statement.
- Sub-bullets decompose each branch into **leaf questions**. Leaves are the parallel work units.
- Cap total leaves at **~8** for cost. If trimming, say so and name what was cut.

Then: user approves, or refines free-form. **Loop** — re-present after each refinement. Do not launch until a clear go-ahead ("go", "run it", "approved").

## Stage 4 — Tier and launch

Tag each leaf by intuitive complexity, then launch **all leaves as background subagents at max parallelism** (single message, multiple dispatches). Use `general-purpose` agents — web-primary, may also read local files if the topic calls for it.

| Tier | Leaf looks like | Claude Code model |
| --- | --- | --- |
| Cheap | lookup, fact-gathering, mechanical | `claude-haiku-4-5` |
| Standard | typical synthesis / comparison | `claude-sonnet-5` |
| Deep | ambiguous, high-judgment, cross-cutting | `claude-opus-4-8` |

On non-Claude hosts, map tiers to that host's cheap / mid / flagship models.

Give each subagent a tight brief and a **fixed return shape**:

```
## <leaf question>
- Findings: <concise, evidence-backed>
- Sources: <urls / refs>
- Confidence: high | medium | low
- Gaps: <what it couldn't resolve>
```

## Stage 5 — Live rollup

Monitor the running forks. **As each fork completes**, post its condensed findings to chat immediately (don't wait for all).

- User may interject with course-corrections → adjust, spawn, or kill remaining forks accordingly.
- User may also stay silent and keep watching — keep rolling up.
- If a fork fails or returns null: note it in one line, continue with the rest.

## Stage 6 — Synthesize

When all forks are done:

1. Dedup overlapping findings; flag contradictions between forks explicitly.
2. Write the full report to `research/<topic-slug>-YYYY-MM-DD.md` — branches as sections, findings, sources, open gaps.
3. Show the **executive summary** in chat (answer to the original goal + key findings + confidence + what remains unknown).

## Anti-patterns

- Don't skip the interview and jump to launching subagents.
- Don't launch before the plan tree is explicitly approved.
- Don't give every leaf the same model — tiering is the cost mechanism.
- Don't batch the rollup into one dump at the end; roll up per-fork completion.
- Don't phrase top-level branches as answers — they are the questions to investigate.
- Don't let leaves sprawl past the cap without telling the user what was cut.
