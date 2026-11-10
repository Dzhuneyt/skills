# reflect benchmark

This file records how `reflect` performed against the cases in this directory. Each case ran twice: once with the skill and once without it (the baseline). The question is whether the skill finds things that the model alone does not.

Run on 2026-11-10 with `claude plugin eval`. The child model was Opus 5.5. A Sonnet judge scored each check, using 3 votes per check. Each case ran once per configuration.

## Results

| Case | With skill | Without skill |
| --- | --- | --- |
| `unanswered-bundle` | 3/4 | 3/4 |
| `hard-won-gotcha` | 5/6 | 5/6 |
| `steering-rule` | 5/6 | 4/6 |
| `clean-session` | 3/3 | 2/3 |
| `many-findings` | 7/9 | 6/9 |
| **Total** | **23/28** | **20/28** |

The run cost $12.45 in all, including judging. The skill was not scored on its `tool_used: Skill` check. That check only shows whether the skill fired, and it fired in every with-skill run.

## What the results show

**The skill helps a little, not a lot.** It scored 3 checks higher in total. It won in `steering-rule`, `clean-session` and `many-findings`. It tied in the other two cases.

**The skill's value is in rules and structure.** In `steering-rule`, the skill wrote a rule with a **Why** line. The baseline did not. In `many-findings`, the skill stated the number of findings first. The baseline did not.

**The skill also made mistakes the baseline did not.**
- In `hard-won-gotcha`, the skill raised the finished `reorder_level` change as "Ship it", because it could not see the change in the repo copy. The baseline did not raise it as a finding.
- In `steering-rule`, the skill surfaced the one-file tabs preference as a finding. The baseline dropped it.
- In `many-findings`, the skill said it would show the PR title and body first, but it did not show a draft.

## Limits of these results

- **Each case ran once per configuration.** A single run does not show how much the results vary.
- **Two checks measure nothing here.** The runs cannot use `AskUserQuestion`, so every finding came back in one text list. Both arms failed "each finding is its own separate question" in `unanswered-bundle` and `many-findings`. Both arms also failed "does not flag `reorder_level`" in `hard-won-gotcha`, which is partly a wording problem in the check.
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
