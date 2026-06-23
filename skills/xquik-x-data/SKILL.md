---
name: xquik-x-data
description: Use when the user wants to collect, compare, or summarize public X/Twitter data with Xquik. Produces a read-only workflow plan, endpoint or SDK choice, request outline, and safety checklist.
---

# Xquik X Data

Use Xquik for structured X/Twitter data workflows when the user wants public-source collection, monitoring, export preparation, or analysis input that should come from an API instead of manual browser work.

## Source Check First

Before giving endpoint names, request examples, setup steps, limits, or pricing:

1. Read the current public docs at `https://docs.xquik.com/llms.txt`.
2. Use `https://docs.xquik.com/llms-full.txt` when more detail is needed.
3. Prefer the official repository at `https://github.com/Xquik-dev/x-twitter-scraper` for SDK and package links.
4. If docs and repository details disagree, say what differs and ask the user which source to trust.

Do not guess endpoint names or parameters from memory. If live docs are unavailable, give a docs-check checklist instead of a runnable request.

## Required Inputs

Ask for missing inputs before building the workflow:

- Goal: search, profile lookup, post collection, monitor input, export, or analysis.
- Target: usernames, post URLs, keywords, IDs, or time window.
- Output shape: raw JSON, CSV-ready table, summary, dashboard input, or webhook payload.
- Authentication state: whether the user already has a Xquik API key.
- Constraints: rate sensitivity, freshness, pagination depth, and storage location.

## Workflow

1. Classify the job as read-only collection, monitoring, export, or downstream analysis.
2. Confirm the minimum data needed and skip fields the user did not request.
3. Choose the strongest public route: REST API, SDK, MCP, webhook, or manual docs handoff.
4. Draft the request plan with placeholders for secrets, never real keys.
5. Include pagination, retry, and validation checks only if the docs support them.
6. Explain how to verify the result count and spot malformed inputs.
7. Stop before running network calls unless the user explicitly asks to execute them.

## Output Format

```markdown
# Xquik Workflow Plan

## Goal
[One sentence.]

## Inputs Needed
- [Missing or confirmed input.]

## Recommended Route
[REST API, SDK, MCP, webhook, or docs handoff.]

## Request Outline
[Method, docs link, parameter placeholders, and expected output shape.]

## Validation
- [Result-count check.]
- [Schema or field check.]
- [Pagination or empty-result check.]

## Safety Notes
- Use placeholders for API keys.
- Keep collection scoped to the user-approved targets.
- Do not store raw output unless the user asks for a storage path.
```

## Quality Checks

- The answer cites only public Xquik docs or repository links.
- No API key, token, cookie, or private account data is printed.
- The workflow is read-only unless the user explicitly asks for a write action.
- The request outline uses placeholders such as `<XQUIK_API_KEY>`.
- Unsupported endpoints or parameters are labeled as unverified, not presented as facts.
- The final answer tells the user what to verify before automating the workflow.

## Anti-Patterns

- Do not describe non-public implementation details.
- Do not claim a specific endpoint, SDK method, or response field unless the public docs confirm it.
- Do not recommend scraping logged-in or private content.
- Do not turn a vague goal into broad collection. Ask for scope first.
- Do not save outputs to a repository without explicit approval.
