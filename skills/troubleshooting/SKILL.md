---
name: troubleshooting
description: Use when the user invokes /troubleshooting or asks for help diagnosing a problem of any kind — a code bug, a broken build, an OS/terminal glitch, a misbehaving tool or config, "why isn't X working", "help me debug Y". Runs a disciplined process: gather the latest real facts from the web first (don't trust memory), scout how others fixed the same issue, attempt a local diagnosis, then hand back a prioritized list of fixes ranked by likelihood — reversible quick wins boosted. NOT for writing a new feature or for tasks with no "something is broken" to diagnose.
---

# Troubleshooting

The user has something broken and wants it diagnosed. "Broken" is loose on purpose — code, the OS, the terminal, a CLI tool, a config, a service, anything. Resist the urge to answer from memory and jump straight to a fix. Work the process below **in order**: facts, then community, then local diagnosis, then a ranked plan.

**Problem as reported:** $ARGUMENTS

If the problem statement is too thin to act on, ask for the missing essentials first — exact error text, what was being done when it happened, what changed recently, and the versions/OS in play. One short round of questions, then proceed.

## Stance

- **Memory is a hypothesis, not a fact.** Your training has a cutoff. Versions, flags, defaults, and known bugs all move. Treat everything you "know" as something to confirm against current reality before you put it in front of the user.
- **Diagnose before prescribing.** Don't lead with a fix. Lead with understanding the actual system in front of you and what's actually changed in the world.
- **Reversible beats clever.** A cheap, easily-undone check that *might* work is usually worth trying before a complex, hard-to-reverse change that's more likely to work. Bias the ranking accordingly (see Step 4).
- **Show your work.** When you present options, cite what you found — the version you confirmed, the issue thread, the line of code — so the user can judge the reasoning, not just the conclusion.

## Step 1 — Orient on the latest facts (web)

Before forming any theory, ground yourself in current reality. Use `WebSearch` (and `WebFetch` to read the primary source) to confirm the things your memory might have wrong:

- **The terminology.** Make sure you're using the same words the current docs/community use for this problem. Names and concepts drift.
- **The current version & what's in it.** What's the latest release of the thing involved? What changed recently? A default could have flipped, a flag could have been renamed or removed, a bug could have been fixed or introduced after your cutoff.
- **The official source of truth.** Find the current docs / changelog / release notes for the exact component, and prefer them over recollection.

Example: the user has a tmux config issue. Don't recite tmux options from memory — check the current tmux version and its current options, because the behavior may have changed in a release that postdates your cutoff.

If the component is a library/framework/SDK/CLI, prefer the **contex7** MCP server for its docs (`resolve-library-id` then `query-docs`) over a generic web search — it returns current, version-aware docs.

Keep this phase tight: confirm the facts that could change your answer, not an encyclopedia.

## Step 2 — Scout how others hit (and fixed) this (web)

Now go find people who already had this problem. You're looking for *fixes that worked* and *dead ends to skip*. Search across:

- **GitHub issues / discussions** on the relevant project (use the `github` MCP tools — `search_issues`, `list_issues` — when you know the repo; closed issues with a linked fix are gold).
- **Stack Overflow** and Q&A sites.
- **Forums, mailing lists, Discord/Reddit threads, and blog posts** for the tool in question.

For each promising hit, note: what their symptom was, whether it actually matches the user's, what fixed it, and how risky/reversible that fix is. Discard near-misses that only superficially resemble the user's problem — a confident wrong match wastes the user's time.

## Step 3 — Attempt a local diagnosis

Do one real pass at diagnosing it *here*, with the access you have:

- **If it's code and you're in the repo:** read the relevant files, trace the failing path, check the config, reproduce mentally (or actually run it / its tests if that's safe and cheap). Aim to point at a specific line or a concrete first fix, not a vague area.
- **If it's the OS / terminal / a tool:** inspect what you can observe — read the config file, check the installed version, look at the environment — using read-only commands. Do **not** run mutating or risky commands to "see what happens"; that's the user's call (see below).
- Pin down, as far as you can: what's actually failing, the narrowest reproduction, and the most likely cause given Steps 1–2.

**Safety:** in this phase, only take actions that are read-only or trivially reversible on your own initiative. Anything that changes the user's system, deletes data, or is hard to undo gets *proposed* in Step 4, not done here — unless the user has already told you to go ahead and fix it.

## Step 4 — Build and present a prioritized fix list

Synthesize everything from Steps 1–3 into a single ranked list of things for the user to try. This is the deliverable.

**Rank by expected value, not just raw likelihood.** For each candidate fix, weigh:

1. **Likelihood of success** — how well it matches the confirmed facts and the community evidence. This is the primary sort key.
2. **Reversibility / cost — a deliberate boost.** Push easily-reversible, low-effort checks **up** the list even when something pricier is marginally more likely. Flipping a config flag you can flip right back, toggling an option, clearing a cache — these are quick wins worth trying first because a failed attempt costs almost nothing. Conversely, flag **one-way doors** (reinstalls, data migrations, deleting state, anything destructive) loudly and rank them lower unless the cheap options are exhausted.

Present the list so each item carries:

- **What to try** — the concrete action, specific enough to execute.
- **Why it's ranked here** — the evidence (confirmed version/default, the issue thread, the line of code) and the reversibility call.
- **How to undo it**, for anything that isn't obviously trivial to reverse.

Lead with the single highest-value step. Offer to walk through them with the user — and to actually apply a fix once they pick one and authorize it. If the top candidate is both very likely and fully reversible, it's fine to recommend trying it immediately and reporting back what happened.
