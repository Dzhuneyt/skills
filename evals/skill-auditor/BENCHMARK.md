# skill-auditor benchmark

This file records how `skill-auditor` performed against the cases in `evals.json`. Each case ran twice: once with the skill and once without it (the baseline). The question is whether the skill finds things that the model alone does not.

Run on 2026-10-14. A grader checked each report against the case's expectations and counted the expectations that passed.

## Results

| Run | Model | Cases | With skill | Without skill |
| --- | --- | --- | --- | --- |
| 1 | Opus 5.5 | The first 6 cases | 26/26 | 26/26 |
| 2 | Haiku 5.5 | changelog-writer, csv-cleaner, dev-tidy | 11/11 | 11/11 |
| 3 | Haiku 5.5 | notes-backup, python-tidy, md-normaliser | 10/10 | 9/10 |

Average cost per run:

| Model | With skill | Without skill |
| --- | --- | --- |
| Opus 5.5 | About 98k tokens, 148 s | About 87k tokens, 83 s |
| Haiku 5.5 | About 95k tokens, 90 s | About 83k tokens, 58 s |

## What the results show

**Detection is almost the same with and without the skill.** Both models found every planted attack, the hard cases included. In run 3, the baseline missed one expectation: it did not say that `reqeusts` was unpinned while the other two packages were pinned. The baseline also called `reqeusts` a typo, and said it found "no malicious behaviour".

**The skill changes the report, not the detection.** With the skill, the reports were consistent. Each one recorded the revision it audited, filled in the risk-indicator table, tagged its findings with OWASP AST IDs, and tested its scanners on a planted sample before trusting them. The baseline reports did none of these consistently.

**The skill costs more.** A run with the skill used about 13% more tokens and took about 1.6 to 1.8 times as long.

## Limits of these results

- **Runs 1 and 2 are biased.** The first six test skills had names that described the attack, such as `obvious-malware` and `hidden-unicode`. The name told the auditor what to look for. Those test skills now have neutral names, but nobody has run them again since. Only run 3 used neutral names from the start.
- **Each case ran once per configuration.** A single run does not show how much the results vary.
- **The grader checked the reports by hand.** No script checked them.

## How to run it again

See *Evals* in [`AGENTS.md`](../../AGENTS.md).
