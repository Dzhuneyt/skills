# reflect benchmark

This file records how `reflect` performed against the cases in this directory. Each case ran twice: once with the skill and once without it (the baseline). The question is whether the skill finds things that the model alone does not.

Run on 2026-11-10 with `claude plugin eval`. The child model was Opus 5.5. A Sonnet judge scored each check, using 3 votes per check. Each case ran once per configuration.

## Results

The skill changed between runs, so the table keeps both. Run 1 used the skill as it stood in this PR before the fixes. Run 2 used the skill after the fixes. Run 2 re-ran only the two cases that the fixes affect, plus the three others on a middle revision (see the limits).

| Case | Run 1 with skill | Run 1 without | Run 2 with skill | Run 2 without |
| --- | --- | --- | --- | --- |
| `unanswered-bundle` | 3/4 | 3/4 | 4/4 | 4/4 |
| `hard-won-gotcha` | 5/6 | 5/6 | 6/6 | 6/6 |
| `steering-rule` | 5/6 | 4/6 | 6/6 | 5/6 |
| `clean-session` | 3/3 | 2/3 | 3/3 | 3/3 |
| `many-findings` | 7/9 | 6/9 | 8/9 | 7/9 |
| **Total** | **23/28** | **20/28** | **27/28** | **25/28** |

Run 1 cost $12.45 and run 2 cost about $14 in total, with judging. The skill was not scored on its `tool_used: Skill` check. That check only shows whether the skill fired, and it fired in every with-skill run.

## What the results show

**The skill helps a little, not a lot.** In run 2 it scored 2 checks higher in total. It won in `steering-rule` and `many-findings`. It tied in the other three cases.

**The gap between the arms is within the noise.** The baseline scored 5/9 on `many-findings` in run 1 and 7/9 in run 2, with no change to the baseline. One run per case cannot separate a 2-check gap from chance.

**The skill's value is in rules and structure.** In `steering-rule`, the skill wrote a rule with a **Why** line in both runs. The baseline missed it in run 1 and again in run 2 for the one-line incident. In `many-findings`, the skill stated the number of findings first in both runs. The baseline did so in run 2 only.

**Run 1 found three flaws in the skill, and the fixes worked.**
- The skill raised the finished `reorder_level` change as "Ship it", because it could not see the change. After the fix it drops that finding, and `hard-won-gotcha` scored 6/6.
- The skill surfaced the one-file tabs preference as a finding. After the fix it drops it, and `steering-rule` scored 6/6.
- The skill said it would show the PR draft later. A first fix still let it defer the body. After a second fix it writes the title and body at once, and the PR check passed.

**One check still fails by chance.** In run 2 the with-skill run failed "each question states its evidence and its proposal in itself" in `many-findings`. It passed in run 1. This looks like variance, not a regression, but one run cannot show it.

## Limits of these results

- **Each case ran once per configuration.** A single run does not show how much the results vary.
- **Run 2 mixes skill revisions.** `unanswered-bundle`, `steering-rule` and `clean-session` ran on the revision with the first three fixes. `hard-won-gotcha` and `many-findings` ran on the final revision. The second round of edits changed only the wording of the PR bar and the PR draft rule. They are not expected to affect the other three cases, but they were not re-run.
- **The runs cannot use `AskUserQuestion`.** Every finding comes back in one text list. For that reason the `unanswered-bundle` check now asks for each finding to have its own action and options, and the `hard-won-gotcha` check now asks for no action on `reorder_level`. Both were reworded between run 1 and run 2, so those two rows are not like for like.
- **The judge gives no reasons.** The report shows only the votes. A failed check needs a look at the run's trace to find the cause.
- **The input is a transcript file, not a live session.** The skill normally reads the conversation in context. These cases do not test a compacted session.
- **An earlier run was contaminated and is not used.** That run used native subagents, which loaded the operator's global rules. It scored the skill 25/29 and the baseline 20/29. One case (`steering-rule`) was invalid because a global rule already covered the case. `claude plugin eval` gives each run a temporary home, so no personal rules load.

## How to run it again

`claude plugin eval` fails on the whole `evals/` directory because `skill-auditor`'s fixtures contain a deliberately dangling `creds` symlink. Run it on a copy of the plugin that holds only these cases:

```bash
mkdir -p /tmp/reflect-plugin/evals
cp -R .claude-plugin skills agents /tmp/reflect-plugin/
cp -R evals/reflect /tmp/reflect-plugin/evals/
cd /tmp/reflect-plugin
claude plugin eval . --runs 1 -j 4 --scaffold --trust-plugin --judge-model sonnet --no-publish --output-dir /tmp/reflect-results
```

See also *Evals* in [`AGENTS.md`](../../AGENTS.md).
