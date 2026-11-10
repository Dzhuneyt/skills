# Session transcript (inventory-api)

**User:** `pytest tests/test_stock.py` fails with `relation "warehouses" does not exist`. Fix it.

**Assistant:** I tried recreating the schema with `alembic upgrade head`. Same error. I tried a fresh test database. Same error. I checked the fixtures, then the migration order.

**Assistant:** Root cause after about 40 minutes: migration `0007` inserts rows into `warehouses`, and the table is created by `make seed`, not by Alembic. Tests only pass when `make seed` has run first. CI runs it as a hidden step, so CI is green and local runs fail. I also tried making `0007` create the table. That breaks production, because the table already exists there with extra columns.

**User:** OK, so locally I run `make seed` first. Good to know. Now add the `reorder_level` field to the stock model.

**Assistant:** Added `reorder_level` to `StockItem` with a test. Tests pass.
