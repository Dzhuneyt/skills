---
name: gh-pr-review
description: Use when user asks to review a pull request by number, URL, or branch ("review this PR", "review PR 123"). Fetches PR details, reads diff and failing checks, produces structured feedback across code quality, security, performance, testing, docs, architecture, dependencies, CI/CD coverage, and completeness. Accepts optional $ARGUMENTS for the PR reference.
allowed-tools: [Bash, WebFetch, Read, Grep, Glob]
---

You are helping review a pull request. Please provide a thorough, structured review.

**PR to review:** $ARGUMENTS

**Review process:**
1. Fetch the PR details using GitHub CLI
2. Check existing review comments and status checks
3. If checks are failing, examine failure details and suggest fixes
4. Analyze what CI/CD checks are configured and warn if important checks appear to be missing
5. Analyze the code changes in the diff
6. Read modified files to understand context beyond the diff
7. Verify each claim before you write it down:
   - Check out the branch and run the tests the PR touches. Report the real output, not an expectation.
   - Check the merge state and whether CI ran at all. A green check from before the last push is stale.
   - If a claim cannot be settled by reading, write a throwaway test that would settle it, run it, then delete it.
8. Identify missing changes that should have been made:
   - **Missing Logic**: Related code that should be updated but wasn't
   - **Missing Documentation**: Code comments explaining "why" (especially for non-obvious decisions), README updates, API docs that need updating
   - **Missing Tests**: Test cases that should exist for the new functionality
9. Provide structured feedback covering:
   - **Code Quality**: Logic, readability, maintainability
   - **Security**: Potential vulnerabilities or security concerns  
   - **Performance**: Efficiency and optimization opportunities
   - **Testing**: Test coverage and quality
   - **Documentation**: Code comments (focus on "why" explanations for critical logic), documentation updates
   - **Architecture**: Design decisions and patterns
   - **Dependencies**: New dependencies and their appropriateness
   - **CI/CD Coverage**: Missing checks that should be configured for this type of change
   - **Completeness**: What's missing that should have been included

**For each area, provide:**
- ✅ What looks good
- ⚠️ Areas for improvement  
- 🔴 Critical issues (if any)

**Ground every finding.**

A finding that only describes code is not finished. Each one carries three parts:

1. **Mechanism** — `file:line` for every claim, so the author can jump straight to it.
2. **Evidence** — the command output, the test result, the probe you ran. Never inference presented as fact. When something stays unverified, label it and say what would settle it.
3. **Failure walkthrough** — the same defect retold in the reader's terms. Name who is at the keyboard, the screen they are on, what they type, what they see, and what actually happens. Stop where the damage is done.

Order matters as much as content. Open with the artifact that proves the finding, usually a few lines of code, a test, or real command output. Argument after evidence, never before it. A reader who meets the proof in the first breath spends the rest of the section judging it. A reader who meets the argument first spends that time deciding whether to believe you.

When a finding rests on a domain concept, explain that concept first, in three lines or a small table. A reviewer who does not already hold the model cannot judge the finding.

Drop any finding you cannot ground. A guess that reads as a defect costs the author more time than silence.

**End with an overall recommendation:** APPROVE, REQUEST CHANGES, or COMMENT.

**If no PR number/URL is provided:** Find the PR for the current branch. If on main branch, list open PRs and ask which one to review.

Use these GitHub CLI commands:
- `gh pr view` - Get PR details, reviews, and status checks
- `gh pr diff` - Get code changes
- `gh pr checks` - Get detailed check status and failure logs
- `gh run view` - Get workflow run details if checks are failing
- Check `.github/workflows/` to understand what CI/CD checks are configured
