Implemented the candidate change in [key_value_wrapper.rs](/private/tmp/sbagent-workspaces/optimizers/20260611-172955/rollback-wrapper-at-block-read-cache/clarity/src/vm/database/key_value_wrapper.rs): `RollbackWrapper` now caches raw materialized backing-store reads by active block hash when `query_pending_data == false`, with separate metadata caching and cache clearing on bottom commits.

Validation passed:
- `cargo fmt-stacks`
- `cargo clippy-stacks`
- `cargo clippy-stackslib`
- full `cargo nextest run`: 10,502 passed, 0 failed
- `cargo build --release -p stacks-bench`

Wrote implemented report to `optimizer-report.json`; release binary is ready at `target/release/stacks-bench`.