---
name: new-project
description: Use when the user is starting a new project / app / product from scratch and wants help shaping it — phrases like "I'm starting a new project", "I want to build X", "help me plan a new app", or invoking /new-project. Runs a disciplined intake: interview one topic at a time until the goal is fully understood, write down an AI-readable project vision, walk the key technical decisions, then propose a staged build plan. NOT for adding a feature to an existing codebase.
---

# New Project

Turn a vague "I want to build X" into a fully understood vision, agreed architecture, and a staged build plan — without guessing. Move through the phases **in order**. Do not skip ahead to a plan or to code.

**Initial idea (if provided):** $ARGUMENTS

## Stance

- **No assumptions — none.** Do not move forward on a guess, even a small one. If you don't know it, ask it. A wrong assumption baked in early is the most expensive kind of mistake here.
- **One topic at a time.** Never fire a wall of questions. Ask about a single thing, hear the answer, then ask the next. The user should never face a numbered list of ten questions.
- **Plain language.** The user may not be technical. Explain every choice the way you'd explain it to a smart friend who doesn't code.
- **Earn each phase.** You may only advance to the next phase once the current one is genuinely settled with the user — not when you *think* it is.

## Phase 1 — Listen

Let the user explain, in their own words, what they want to build and what the features are. If they gave an initial idea above, acknowledge it and treat it as the starting point. Don't interrupt with architecture. Just understand the intent.

## Phase 2 — Interview until the picture is complete

Before proposing **any** plan, ask questions — one topic at a time — until you understand what's being built and what the finished product should look like, 100%.

- Ask, listen, then ask the next thing. Keep going until there are no meaningful unknowns left.
- Cover the things that shape the product: who it's for, the core user journey, must-have vs. nice-to-have features, what "done" looks like, scale/usage expectations, constraints (budget, deadline, platforms), and anything the user's description left ambiguous.
- When the user is vague, drill in rather than filling the gap yourself ("When you say 'social', do you mean public profiles, or just sharing with friends?").
- You are done with this phase only when you could not be surprised by what the end product turns out to be.

Do not start writing the vision doc until you genuinely have the full picture.

## Phase 3 — Write the project vision (AI-readable)

Once you have a complete picture, write the full project vision to a file (default `PROJECT.md` at the repo root — confirm the path). Write it so that **a fresh session could read it and understand the project fully without the user re-explaining anything.**

Make it detailed and structured. Cover at least:

- **What we're building** — one-paragraph summary, then the elevator pitch.
- **Who it's for** — users / audience and the problem it solves for them.
- **Core features** — must-haves, separated from nice-to-haves / later.
- **Key user journeys** — the main flows, step by step.
- **Scope & non-goals** — explicitly what this is *not* doing (for now).
- **Constraints** — budget, timeline, platforms, scale expectations, anything fixed.
- **Open questions** — anything still genuinely undecided.

Show it to the user and refine until they confirm it matches what's in their head. This document is the source of truth for everything after.

## Phase 4 — Walk the key technical decisions, one at a time

Now walk the user through the key technical decisions **one at a time** — e.g. frontend, backend, database, hosting, auth, and any others this specific project needs. For each:

- Explain the choice in plain language and give a clear recommendation with the reasoning.
- Lay out the realistic alternatives and the trade-offs in terms the user can weigh.
- **Flag loudly anything that is costly or hard to undo later** — schema/data-model choices, hosting/platform lock-in, auth provider, framework, anything migration-shaped. Make the one-way doors obvious so they get a real decision, not a default.
- Settle one decision with the user before moving to the next.

`AskUserQuestion` works well here: one decision per question, recommended option first, alternatives as the other cards.

Record the agreed decisions (and the reasoning) back into the vision doc as you go, so the "why" isn't lost.

## Phase 5 — Propose a staged build plan

**Only after** you've agreed on the overall structure, propose a build plan — broken into small, reviewable stages, **not the whole thing at once.**

- Each stage should be independently reviewable and produce something the user can look at or run.
- Order stages so the riskiest assumptions and the foundational pieces come first.
- State what "done" looks like for each stage. Get sign-off on the plan before writing code; then build one stage at a time, pausing for review between them.

## Throughout — flag helpful tools, connectors & skills

As you go, tell the user whenever a tool, connector, MCP server, or skill would specifically help **this** project — and explain concretely **how they'd connect it** (what to install, what to authorize, where it plugs in). Examples: a hosting/deploy connector, a database or auth provider, a payments integration, a design-import tool, an issue tracker. Only surface ones that genuinely fit the project in front of you — not a generic catalog.
