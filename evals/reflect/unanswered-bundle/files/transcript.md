# Session transcript (orders-service)

**User:** The nightly export job fails sometimes. Look at `export/run.py`.

**Assistant:** Found it. The upstream API times out about 1 in 20 calls and the job has no retry. I made one fix, and I have three decisions for you:
1. How many retries should the export use before it gives up?
2. The `cust_nm` column in the export is a typo for `customer_name`. Should I rename it? Downstream reports read it.
3. `/v1/export-legacy` has had no traffic for 90 days. Should I delete it in this change?

**User:** 3 retries. Looks good, thanks. Commit it.

**Assistant:** Done. Committed `a1f3c9e` on `main` with a 3-retry loop in `export/run.py`.
