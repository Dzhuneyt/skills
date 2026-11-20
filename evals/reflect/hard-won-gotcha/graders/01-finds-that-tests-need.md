---
type: llm
focus: trace
weight: 1
---

Finds that tests need `make seed` to run before `pytest` because migration 0007 depends on a table that Alembic does not create
