## Summary

Batch SQLite side-store writes during Clarity/MARF commit paths by replacing per-item `REPLACE INTO data_table` execution with a prepared-statement bulk helper. Risk: medium, because this touches consensus-sensitive storage plumbing; the implementation preserves the same key/value strings, MARF value hashing, and `MARF::insert_batch` behavior.

## What changed

- Added `SqliteConnection::put_many` so side-store `data_table` writes prepare the `REPLACE INTO data_table (key, value) VALUES (?, ?)` statement once per batch.
- Routed `PersistentWritableMarfStore::put_all_data` through the batch helper after building the same MARF keys and values.
- Updated the SQLite-backed memory store paths for parity with the persistent store path.
- Added regression coverage for batched `put_all_data` side-store rows, duplicate Clarity-key overwrite behavior, and reads by trie path after commit.

## Benchmark result

The write-heavy transaction replay moved in the expected direction: tx execution latency improved by 4.18%, within the analyzer's 5% +/- 4% expectation, and total block time improved by 3.54%. The profiler evidence matches the proposed mechanism: the old per-item `SqliteConnection::put` calls disappeared, the new `put_many` batch path handled the side-store writes, and `PersistentWritableMarfStore::put_all_data` total wall time fell by 6.92%. All four replayed tx hashes improved on average duration, with per-sample gains between 3.29% and 5.18%. Commit timing regressed by 3.62% per block, so the total-block improvement is smaller than the execution-latency gain, but it does not contradict the tx-latency mechanism.

| Invocation | Baseline run | Candidate run | Measured | Matches expected signal |
| --- | ---: | ---: | ---: | --- |
| write-heavy txs | 7 | 10 | 4.184% | yes |

**Caveats.**

- Commit_us_per_block regressed by 3.619%, partially offsetting the execution gain at the whole-block level; total_us_per_block still improved by 3.544%.
- SqliteConnection::put_many remains a top candidate span at 2940091 us self wall, so batching reduced dispatch/prepare overhead but did not eliminate SQLite write cost.

## Validation

- `cargo nextest run --no-fail-fast --retries 2 --no-output-indent --failure-output final --success-output never --status-level slow --final-status-level flaky --hide-progress-bar --no-input-handler`
- `nextest.log`: `Nextest run ID 95322aca-683e-431d-9133-cfce4d92f02c with nextest profile: default`
- `nextest.log`: `Starting 10499 tests across 22 binaries (417 tests skipped)`
- `nextest.log`: `Summary [ 847.340s] 10499 tests run: 10499 passed (23 slow), 417 skipped`
- Focused regression test: `stackslib::clarity_vm::database::marf::tests::persistent_put_all_data_writes_same_side_store_rows_and_marf_values`
- `implementation.md` reports `clippy_clean: true`.
