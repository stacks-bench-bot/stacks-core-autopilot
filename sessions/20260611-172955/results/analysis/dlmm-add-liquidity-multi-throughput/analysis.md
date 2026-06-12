# dlmm-add-liquidity-multi-throughput

Status: accepted

Selection lens: `tenure_throughput`

Lens disposition: `not_actionable`

The triage signal is real. `dlmm-liquidity-router-v-1-2.add-liquidity-multi` has 592 calls and is the second-largest Clarity budget consumer in the run: 29.86% runtime, 35.68% read_count, 37.92% read_length, 45.44% write_count, and 44.09% write_length. The largest promoted axis for this family is `write_count`; write/read length are also near it. In many representative single-call blocks, this transaction accounts for 100% of the block's Clarity cost axes.

The throughput lens is not node-actionable. The representative traces show `add-liquidity-multi` executing a 150-iteration `fold-add-liquidity-multi` that repeatedly calls `SP1PFR4V08H1RAZXREBGFFQ59WB739XM8VVGTFSEA.dlmm-core-v-1-1.add-liquidity`. Those nested contract calls perform the consensus-visible reads and `map-set`/value writes that produce the high deterministic Clarity `write_count`, `read_length`, and `write_length`. A node-side storage optimization can reduce wall time, but it cannot reduce those Clarity budget units without changing the contract or making a HIP-class VM/cost-model change.

## Target: clarity-side-store-bulk-put

Target span: `put`

Bucket: `block_processing`

The actionable latency handle is the side-store write loop after VM execution. Four representative traces have:

- `37ad67a3`: `put_all_data` 565.408 ms, child `SqliteConnection::put` 539.374 ms across 1502 calls.
- `408f81be`: `put_all_data` 540.743 ms, child `put` 515.217 ms across 1502 calls.
- `92639041`: `put_all_data` 791.306 ms, child `put` 769.613 ms across 1502 calls.
- `9f0416be`: `put_all_data` 541.240 ms, child `put` 517.346 ms across 1401 calls.

The fifth representative, `74a98eed`, was inspected and is different: it is dominated by `Trie::walk_backptr` inside VM reads rather than the post-VM SQLite write loop.

Code path:

- `clarity/src/vm/database/key_value_wrapper.rs:281` commits bottom-level rollback edits to the backing store.
- `stackslib/src/clarity_vm/database/marf.rs:1034` implements `PersistentWritableMarfStore::put_all_data`.
- `stackslib/src/clarity_vm/database/marf.rs:1037` loops over each staged edit, converts the value to `MARFValue`, and calls `SqliteConnection::put`.
- `clarity/src/vm/database/sqlite.rs:134` calls `sqlite_put`, which executes one `REPLACE INTO data_table (key, value) VALUES (?, ?)` per item.

Proposed change: add a bulk side-store write helper that prepares the `REPLACE INTO data_table` statement once against the existing SQLite transaction and executes it for all converted side-store values. Use it from `PersistentWritableMarfStore::put_all_data` and the memory backing store. Keep the same key/value strings, error mapping, and `MARF::insert_batch` behavior.

Expected improvement:

- `tx_latency`: 5%
- `tenure_throughput`: 0%
- `commit_time`: 0%

Risk: medium. The write contents are unchanged, but this touches the Clarity backing store and MARF side-store write path.

Verification replay: `write-heavy-txs` replays the four put-heavy representative txids with rich profiling, warmup 0, repetitions 20. Expected signal is improved `tx_latency`, with `put` and `put_all_data` spans moving down.

Global note: this target may help other write-heavy Clarity workloads, but it should be routed as a block-processing latency optimization, not as a tenure-throughput fix.
