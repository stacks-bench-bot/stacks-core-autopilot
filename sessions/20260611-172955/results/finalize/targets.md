# Optimization targets — session 20260611-172955

> Catalog of merged optimization targets produced by Phase 1.7 (merge). For pass/fail verdicts and benchmark deltas, see [summary.md](summary.md).

- Baseline run id: `6`
- Baseline rerun id: `6`
- Noise floor: `1%`
- Merge method: `LLM`
- Merge model: `gpt-5.5`

## Contents

- [clarity-side-store-bulk-put](#clarity-side-store-bulk-put) — Normal PR, bucket=`Block processing`, risk=`Medium`
- [rollback-wrapper-at-block-read-cache](#rollback-wrapper-at-block-read-cache) — Normal PR, bucket=`Block processing`, risk=`Medium`
- [marf-deferred-seal-postorder-hash-cache](#marf-deferred-seal-postorder-hash-cache) — Normal PR, bucket=`Block commit`, risk=`Medium`

## clarity-side-store-bulk-put

**Meta**

- Delivery mode: Normal PR
- Bucket: Block processing
- Risk: Medium
- Convergence: `1` contributor(s)
- Bench eligible: yes

**Hotspot**

- Target span: `put`
- Profiler span: `put`
- Location: `clarity/src/vm/database/sqlite.rs:133`
- self_wall: `297586640` µs · total_wall: `297586640` µs · calls: `1038880`

**Expected improvement**

- tx_latency: `5.00%`
- tenure_throughput: `0.00%`
- commit_time: `0.00%`

**Files**

- `clarity/src/vm/database/sqlite.rs`
- `stackslib/src/clarity_vm/database/marf.rs`
- `clarity/src/vm/database/key_value_wrapper.rs`
- `clarity/src/vm/database/clarity_store.rs`

**Evidence**

> Representative traces 37ad67a3, 408f81be, 92639041, and 9f0416be all run under Transaction -> try_mine_tx_with_len -> PersistentWritableMarfStore::put_all_data after VM execution. That span loops over 1401-1502 staged edits and spends 515-770 ms almost entirely in SqliteConnection::put. The code path is RollbackWrapper::commit collecting bottom-level edits, calling ClarityBackingStore::put_all_data, then PersistentWritableMarfStore::put_all_data converting each value to a MARFValue and invoking SqliteConnection::put once per item before MARF::insert_batch. SqliteConnection::put is a single REPLACE INTO data_table statement via conn.execute, so this target is storage mechanics, not Clarity cost accounting. The fifth representative, 74a98eed, was inspected and is instead dominated by MARF Trie::walk_backptr inside VM reads; it does not invalidate the put target but should not be used as the primary replay sample for it.

**Proposed change**

> Add a bulk side-store write helper beside SqliteConnection::put, for example SqliteConnection::put_many(conn, items), that prepares the REPLACE INTO data_table (key, value) VALUES (?, ?) statement once against the existing rusqlite Transaction and executes it for all converted side-store values. Use that helper in PersistentWritableMarfStore::put_all_data after building the MARF keys/values, and in MemoryBackingStore::put_all_data for parity. Keep MARF::insert_batch unchanged and preserve the exact key/value strings and error mapping.

**Verification plan**

> Check Clarity backing-store unit coverage for put/get round trips, rollback commit behavior, and MARF side-store reads by hash. Add focused regression coverage if no test asserts that batched put_all_data writes exactly the same data_table rows as individual puts. Then run the targeted replay below and compare put and put_all_data spans, plus transaction duration.

**Merge notes**

> Singleton target retained; no true duplicate structural change was found.

**Contributors**

- [dlmm-add-liquidity-multi-throughput](../analysis/dlmm-add-liquidity-multi-throughput/analysis.json) (target_index `0`)

**Outputs**

- Experiment dir: [`../optimize/clarity-side-store-bulk-put/`](../optimize/clarity-side-store-bulk-put/)
- [implementation.md](../optimize/clarity-side-store-bulk-put/implementation.md) · [side-observations.md](../optimize/clarity-side-store-bulk-put/side-observations.md) · [abort.md](../optimize/clarity-side-store-bulk-put/abort.md)

## rollback-wrapper-at-block-read-cache

**Meta**

- Delivery mode: Normal PR
- Bucket: Block processing
- Risk: Medium
- Convergence: `1` contributor(s)
- Bench eligible: yes

**Hotspot**

- Target span: `get_data`
- Profiler span: `get_data`
- Location: `stackslib/src/clarity_vm/database/marf.rs:852`
- self_wall: `5517700` µs · total_wall: `531004890` µs · calls: `11318323`

**Expected improvement**

- tx_latency: `6.00%`
- tenure_throughput: `0.00%`
- commit_time: `0.00%`

**Files**

- `clarity/src/vm/database/key_value_wrapper.rs`
- `stackslib/src/clarity_vm/database/marf.rs`
- `clarity/src/vm/contexts.rs`
- `clarity/src/vm/database/clarity_db.rs`

**Evidence**

> All five representatives follow the same tree: Transaction -> try_mine_tx_with_len -> with_abort_callback -> execute-contract dual-stacking-v2_1_0.capture-snapshot-balances-optimizer -> map -> capture-participant-balances-optimizer -> capture-participant-snapshot. The hot child is 60 at-block evaluations per tx, totaling about 1.48s-1.56s of nested work in the trace summaries. Under those at-block closures, repeated get_data/get_value calls enter PersistentWritableMarfStore::get_data and then MARF get_by_key/get_path/walk/walk_backptr. Representative totals for PersistentWritableMarfStore::get_data are about 478ms-539ms per tx with roughly 2,960-3,165 calls, while MARF get_by_key/get_path/walk totals are about 548ms-596ms per tx with roughly 4,900-5,200 calls. Code confirms the handle: ExecutionState::evaluate_at_block sets a historical block hash with query_pending_data=false, RollbackWrapper then bypasses pending writes and calls the backing store for every materialized read, and PersistentWritableMarfStore::get_data performs marf.get(chain_tip, key) plus side-store lookup. The existing RollbackWrapper maps only cache pending writes, not materialized historical store reads. The top Clarity-cost query shows this family's max axis share is 5.48%, so this target moves wall-time latency, not tenure budget.

**Proposed change**

> Add a transaction-local read-through cache to RollbackWrapper for materialized backing-store reads while query_pending_data is false. Track the active block hash after successful set_block_hash, and cache raw store results by (active_block_hash, key) for get_data/get_value and by (active_block_hash, contract, metadata_key) for metadata reads. Do not cache reads that consult pending data, do not cache proof reads, and clear or scope the cache with the RollbackWrapper lifetime so it cannot cross transactions. Refactor get_data and get_value through a shared raw-read helper so cached hex/string values still deserialize through the existing Clarity type paths and preserve cost accounting.

**Verification plan**

> Add focused RollbackWrapper/ClarityDatabase tests that repeated at-block reads return the same values before and after pending writes in the surrounding tx, that restored block hash resumes pending-data visibility, and that metadata and value reads remain isolated by block hash. Then run targeted replay on the representative txids and compare get_data, get_by_key, walk, walk_backptr, and tx latency.

**Merge notes**

> Singleton target retained; no true duplicate structural change was found.

**Contributors**

- [dual-stacking-snapshot-balance-fanout](../analysis/dual-stacking-snapshot-balance-fanout/analysis.json) (target_index `0`)

**Outputs**

- Experiment dir: [`../optimize/rollback-wrapper-at-block-read-cache/`](../optimize/rollback-wrapper-at-block-read-cache/)
- [implementation.md](../optimize/rollback-wrapper-at-block-read-cache/implementation.md) · [side-observations.md](../optimize/rollback-wrapper-at-block-read-cache/side-observations.md) · [abort.md](../optimize/rollback-wrapper-at-block-read-cache/abort.md)

## marf-deferred-seal-postorder-hash-cache

**Meta**

- Delivery mode: Normal PR
- Bucket: Block commit
- Risk: Medium
- Convergence: `1` contributor(s)
- Bench eligible: yes

**Hotspot**

- Target span: `calculate_node_hashes`
- Profiler span: `calculate_node_hashes`
- Location: `stackslib/src/chainstate/stacks/index/storage.rs:818`
- self_wall: `381328360` µs · total_wall: `1272836450` µs · calls: `2132356`

**Expected improvement**

- tx_latency: `0.00%`
- tenure_throughput: `0.00%`
- commit_time: `8.00%`

**Files**

- `stackslib/src/chainstate/stacks/index/storage.rs`
- `stackslib/src/chainstate/stacks/index/node.rs`
- `stackslib/src/chainstate/stacks/index/cache.rs`
- `stackslib/src/chainstate/stacks/index/test/storage.rs`
- `stackslib/src/chainstate/stacks/index/test/marf.rs`

**Evidence**

> Run 6 ranks TrieRAM::calculate_node_hashes as the #2 exclusive span: 381.328s self wall, 1,272.836s inclusive wall, 2,132,356 calls, 100% block recurrence, and no transaction association. The per-block distribution is broad rather than a single spike: 15,000/15,000 blocks, p50 18.794ms, p95 58.877ms, p99 118.061ms, top3 share 2.6%. All five representatives are the top five blocks for this span. In each trace, calculate_node_hashes sits under Segment: Finalize (merkle+seal) and dominates the finalize subtree: 5,032.9ms of 5,053.2ms for 0x06f198..., 3,476.5ms of 3,518.2ms for 0x35c1c0..., 2,664.3ms of 2,688.4ms for 0x9407bf..., 1,524.2ms of 1,549.2ms for 0x615df0..., and 1,324.1ms of 1,344.3ms for 0xa2ebb2.... The suspected inner_get_trie_ancestor_hashes_bytes path is present but much smaller in these traces, topping out at 38.736ms, so it is not the primary handle. Code in TrieRAM::inner_seal_marf calls calculate_node_hashes only in Deferred/All mode; calculate_node_hashes clones each node with get_nodetype(...).to_owned(), serializes node consensus bytes, scans ptrs, recursively hashes same-block children, looks up ancestor block hashes via the existing get_block_hash_caching cache, and writes deferred hashes back. Existing code already caches block-id to block-hash lookups, so the actionable work is reducing the deferred seal walk's clone/recursion/pointer traversal overhead while preserving the identical hash byte stream.

**Proposed change**

> Refactor TrieRAM::calculate_node_hashes into a deferred seal hasher that computes the same post-order hashes with an explicit work stack or per-node memo indexed by TrieRAM slot. While a node is borrowed, serialize the node consensus prefix and collect the minimal child descriptors needed for hashing, then drop the borrow before walking children; store computed hashes in a parallel Vec<Option<TrieHash>> or equivalent and write them back to TrieRAM once computed. This avoids cloning full TrieNodeType values and repeatedly scanning large pointer arrays during recursive seal, while preserving get_block_hash_caching for backptrs, write_node_hash semantics for Deferred mode, and the All-mode equality assertion against eager hashing.

**Verification plan**

> Use existing MARF storage tests that compare deferred/immediate/all hash modes and merkle verification, especially stackslib/src/chainstate/stacks/index/test/storage.rs and stackslib/src/chainstate/stacks/index/test/marf.rs. Add focused tests for root hash equality across Immediate, Deferred, and All modes over Node4/16/48/256 backptr-heavy tries. Then run the targeted replay below and compare calculate_node_hashes plus block commit/finalize timing; no Clarity cost movement is expected.

**Merge notes**

> Singleton target retained; no true duplicate structural change was found.

**Contributors**

- [marf-trie-seal-hash-recalculation](../analysis/marf-trie-seal-hash-recalculation/analysis.json) (target_index `0`)

**Outputs**

- Experiment dir: [`../optimize/marf-deferred-seal-postorder-hash-cache/`](../optimize/marf-deferred-seal-postorder-hash-cache/)
- [implementation.md](../optimize/marf-deferred-seal-postorder-hash-cache/implementation.md) · [side-observations.md](../optimize/marf-deferred-seal-postorder-hash-cache/side-observations.md) · [abort.md](../optimize/marf-deferred-seal-postorder-hash-cache/abort.md)

## Lens dispositions

| Family | Lens | Status | Reason |
| ------ | ---- | ------ | ------ |
| [dlmm-add-liquidity-multi-throughput](../analysis/dlmm-add-liquidity-multi-throughput/analysis.json) | Tenure throughput | Not actionable | The throughput signal is real: add-liquidity-multi accounts for 29.86% of run runtime, 35.68% read_count, 37.92% read_length, 45.44% write_count, and 44.09% write_length, with write_count the promoted near-binding axis. Code and traces show this comes from the contract's 150-iteration fold over nested dlmm-core add-liquidity calls and their consensus-visible map/var writes. The actionable node-side storage handle below reduces wall time in SQLite side-store writes, but it does not reduce deterministic Clarity write_count/read_length/write_length without a contract change or HIP-class cost/VM behavior change. |
| [dual-stacking-snapshot-balance-fanout](../analysis/dual-stacking-snapshot-balance-fanout/analysis.json) | Tx latency | Addressed | Representative tx traces show the promoted latency is real and dominated by repeated at-block historical reads; a transaction-local materialized-read cache can reduce repeated PersistentWritableMarfStore::get_data calls and their MARF walk descendants without changing consensus-visible Clarity behavior. |
| [marf-trie-seal-hash-recalculation](../analysis/marf-trie-seal-hash-recalculation/analysis.json) | Commit time | Addressed | The promoted signal is real commit-bucket work: representative traces put deferred MARF seal hashing under Segment: Finalize (merkle+seal), and the handle is a concrete Rust function rather than a bucket wrapper. |
