# Triage candidates — session 20260517-111040-proposal-canonical

- baseline run id: `1`  ·  rerun id: `1`  ·  noise floor: `1.0000%`
- lens coverage: `tx_latency`=1, `tenure_throughput`=2, `commit_time`=2  ·  weights applied: `0.4,0.4,0.2`
- redistribution notes: Commit-time contributed two candidates because finalize hashing and clarity-state blob append are distinct commit anchors with broad recurrence.

## Promoted candidates (5)

### `dual-stacking-snapshot-balance-folds`

- **kind**: `TxFamily`
- **selection lens**: `TxLatency`
- **bucket**: `BlockProcessing`
- **rationale**: Snapshot-balance contract calls repeat large fold/at-block/read-only balance subtrees across 79 txs, with top duration 3.71x median and multiple 1s-4s representatives.
- **suspected spans**: `fold`, `begin-read-only-tx`, `at-block`, `contract-call?`, `lookup_variable`, `compute-and-update-balances-one-user`, `get-user-total-sBTC-balance`
- **global materiality**: pct_blocks=Some(26.3), self_wall_ms=Some(8772.68)

### `gl-api-oracle-price-runtime`

- **kind**: `TxFamily`
- **selection lens**: `TenureThroughput`
- **bucket**: `BlockProcessing`
- **rationale**: gl-api open/close calls consume 75.6% of run Clarity runtime, with 609 repeated oracle parse/verification calls per representative and no single-rep dominance.
- **suspected spans**: `decode-pnau-price-update`, `parse-price-info-and-proof`, `parse-proof`, `check-merkle-proof`, `hash-path`, `hash-nodes`
- **global materiality**: pct_blocks=Some(0.9), self_wall_ms=Some(121.65)

### `blocksurvey-proof-write-fanout`

- **kind**: `ContractFamily`
- **selection lens**: `TenureThroughput`
- **bucket**: `BlockProcessing`
- **rationale**: proof-of-submission repeats 1453 nearly identical calls, contributing 15.83% of run write_count and 14.9% of write_length with max duration only 2.35x median.
- **suspected spans**: `is-response-already-submitted`, `get-response-by-id`, `is-survey-blocked`, `map-set`, `var-set`
- **global materiality**: pct_blocks=Some(22.2), self_wall_ms=Some(115.23)

### `clarity-commit-trie-blob-append`

- **kind**: `BlockFamily`
- **selection lens**: `CommitTime`
- **bucket**: `BlockCommit`
- **rationale**: Clarity State Commit reaches append_trie_blob twice in every block, accounting for 66.98s self wall with uniform per-block distribution and top3 share 0.1%.
- **suspected spans**: `append_trie_blob`, `inner_write_external_trie_blob`, `store_trie_blob`, `flush_to`, `commit_to`
- **global materiality**: pct_blocks=Some(100.0), self_wall_ms=Some(76642.38)

### `finalize-trie-node-hashing`

- **kind**: `BlockFamily`
- **selection lens**: `CommitTime`
- **bucket**: `BlockCommit`
- **rationale**: Finalize merkle+seal repeatedly descends calculate_node_hashes, with 677k calls, 20.65s self wall across all blocks, and top3 share 1.2%.
- **suspected spans**: `calculate_node_hashes`, `inner_get_trie_ancestor_hashes_bytes`, `get_node_hash_bytes`
- **global materiality**: pct_blocks=Some(100.0), self_wall_ms=Some(24268.96)

## Rejected alternative families (4)

- `contract-metadata-fetch-wrapper` (lens `TxLatency`): suspected spans exact-match non-targets: fetch_metadata
- `clarity-value-serialization` (lens `TxLatency`): investigated; no repeated workload pattern across representatives — diffuse across dual-stacking, uvas, and zest calls
- `sparse-crypto-builtin-checks` (lens `TenureThroughput`): investigated; no repeated workload pattern across representatives — sparse secp/hash builtins across unrelated contracts
- `allocation-clone-hotspots` (lens `TxLatency`): investigated; no repeated workload pattern across representatives — no indexed allocation or clone span family in profiler data
