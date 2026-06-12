# dual-stacking-snapshot-balance-fanout

Status: accepted. The promoted `selection_lens` is `tx_latency`, and it is addressed by one non-consensus target.

The five representative transactions all reproduce the same shape: `capture-snapshot-balances-optimizer` maps over participant work, enters `capture-participant-snapshot`, and performs repeated `at-block` read-only balance/map lookups. Each representative is about 1.61s-1.69s, with roughly 60 `at-block` evaluations totaling about 1.48s-1.56s in the trace summaries.

The useful handle is not `with_abort_callback`, `Transaction`, or the Clarity builtin wrappers. The storage path below `at-block` repeatedly enters `PersistentWritableMarfStore::get_data`, then `MARF::get_by_key`, `get_path`, `walk`, and `Trie::walk_backptr`. In the representatives, `PersistentWritableMarfStore::get_data` accounts for about 478ms-539ms of nested work per tx.

## Target

`rollback-wrapper-at-block-read-cache`

Add a transaction-local read-through cache in `RollbackWrapper` for materialized backing-store reads while `query_pending_data == false`, keyed by active historical block hash plus store key. This is the mode used by `ExecutionState::evaluate_at_block`, which calls `set_block_hash(..., false)` before evaluating the closure and restores the prior block with `set_block_hash(..., true)`.

The cache should sit above `PersistentWritableMarfStore::get_data`, so repeated historical reads can avoid both MARF walks and SQLite side-store lookups. It should not cache pending-data reads, proof reads, or anything beyond the wrapper lifetime. Refactor `get_data` and `get_value` through a shared raw-read helper so deserialization and cost accounting remain unchanged.

Expected improvement is conservative: about 6% tx-latency reduction on the representative replay, with no tenure-throughput or commit-time claim. The top Clarity-cost query shows this family's largest max-axis share is runtime at 5.48%, so this is a wall-time optimization, not a binding Clarity-budget fix.

Primary files:

- `clarity/src/vm/database/key_value_wrapper.rs`
- `stackslib/src/clarity_vm/database/marf.rs`
- `clarity/src/vm/contexts.rs`
- `clarity/src/vm/database/clarity_db.rs`

Verification should replay the five representative txids with rich profiling and check that `get_data`, `get_by_key`, `get_path`, `walk`, and `walk_backptr` drop together while tx latency improves.
