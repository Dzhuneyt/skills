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

## Real session: `traffic-spike`

This case is a real 38-minute coding session. All names, IDs, domains and paths were replaced by fictional stand-ins. A request-count spike on a site was traced to a cloud health check, and the fix went through a spec change and a merged PR. A second, adversarial review then looked for what the text still reveals, and the transcript was trimmed to match (product description, code fingerprints, pasted third-party skill text, device-login details, time-zone hints, infrastructure details). Each arm ran 3 times, on 2026-11-20, on the trimmed transcript.

| Check | With skill | Without skill |
| --- | --- | --- |
| Nothing monitors the site yet | 3/3 | 3/3 |
| Cost steering: check quotas before saying "near zero" | 3/3 | 1/3 |
| The Vercel connector saw one project; the CLI recipe ran twice | 3/3 | 0/3 |
| The same stopgap question was asked several times | 0/3 | 0/3 |
| Finished work is not listed as open | 3/3 | 2/3 |
| No item says "no action needed" | 3/3 | 0/3 |
| No PR or issue for the shipped change | 3/3 | 3/3 |
| The rule line of each proposed rule is general | 3/3 | 0/3 |
| The number of findings is stated first | 3/3 | 0/3 |
| **Score per run** | **0.89, 0.89, 0.89** | **0.33, 0.33, 0.33** |

The mean score was 0.89 with the skill and 0.33 without it, a gap of +0.56. The run cost $3.71. Two earlier 3-run passes on the untrimmed transcript gave 0.81 against 0.37, and then 0.85 against 0.41, after two unclear checks were reworded. The gap was +0.44 each time. Trimming the transcript did not remove the gap.

**This case separates the arms much more than the short cases do.** Without the skill, the model gave a recap and a few notes. It found the open monitor item, but it did not state a count, did not record the repeated recipe, and gave no rules. With the skill, it gave a ranked list of findings with drafted rules and destinations.

**One weakness in the skill.** The skill did not reliably notice that the assistant asked the same stopgap question several times. It passed this check in 2 of 3 runs, then 1 of 3, then 0 of 3, over the three passes. The baseline never passed. The skill's steering detector (G) has no bar that names "the same question asked again and again", and this may be why.

## Limits of these results

- **Each case ran once per configuration.** A single run does not show how much the results vary.
- **Run 2 mixes skill revisions.** `unanswered-bundle`, `steering-rule` and `clean-session` ran on the revision with the first three fixes. `hard-won-gotcha` and `many-findings` ran on the final revision. The second round of edits changed only the wording of the PR bar and the PR draft rule. They are not expected to affect the other three cases, but they were not re-run.
- **The runs cannot use `AskUserQuestion`.** Every finding comes back in one text list. For that reason the `unanswered-bundle` check now asks for each finding to have its own action and options, and the `hard-won-gotcha` check now asks for no action on `reorder_level`. Both were reworded between run 1 and run 2, so those two rows are not like for like.
- **The judge gives no reasons.** The report shows only the votes. A failed check needs a look at the run's trace to find the cause.
- **The input is a transcript file, not a live session.** The skill normally reads the conversation in context. These cases do not test a compacted session.
- **An earlier run was contaminated and is not used.** That run used native subagents, which loaded the operator's global rules. It scored the skill 25/29 and the baseline 20/29. One case (`steering-rule`) was invalid because a global rule already covered the case. `claude plugin eval` gives each run a temporary home, so no personal rules load.

- **The real-session checks were written after an earlier report.** I wrote the expected findings after reading a with-skill report from an exploratory run, then checked each one against the transcript. This favours the skill. The check about the repeated stopgap question accepts either rule (do not re-ask, or ask it first and alone).
- **The real session is condensed and trimmed.** Tool calls and results are clipped to short lines, and the pasted third-party skill text was replaced by one-line stubs. Some evidence is lost.
- **One real session is one example.** The size of the gap may not hold for other sessions.

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
