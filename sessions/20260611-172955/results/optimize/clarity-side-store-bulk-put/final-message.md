Implemented the candidate change and wrote `optimizer-report.json` with `outcome: "implemented"`.

Changed:
- `clarity/src/vm/database/sqlite.rs`: added `SqliteConnection::put_many` using one prepared `REPLACE INTO data_table` statement per batch.
- `stackslib/src/clarity_vm/database/marf.rs`: `PersistentWritableMarfStore::put_all_data` now batches side-store writes while preserving the same `MARFValue` hashes and `MARF::insert_batch`.
- `stackslib/src/clarity_vm/database/mod.rs`: switched the second SQLite-backed memory store to the same helper.
- Added a focused persistent MARF regression test for side-store rows and readback parity.

Validation passed:
- `cargo fmt-stacks`
- `cargo clippy-stacks`
- `cargo clippy-stackslib`
- Full nextest: `10499 passed`, `0 failed`, `847.34s`
- `cargo build --release -p stacks-bench`

Release artifact exists at `target/release/stacks-bench`.