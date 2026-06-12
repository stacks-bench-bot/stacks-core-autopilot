# Triage candidates — session 20260611-172955

- baseline run id: `6`  ·  rerun id: `6`  ·  noise floor: `1.0000%`
- lens coverage: `tx_latency`=1, `tenure_throughput`=1, `commit_time`=1  ·  weights applied: `0.4,0.4,0.2`
- redistribution notes: Balanced one promoted family per lens; DLMM withdraw/swap variants were audited but not promoted because representative distributions were outlier-dominated.

## Promoted candidates (3)

### `dual-stacking-snapshot-balance-fanout`

- **kind**: `ContractFamily`
- **selection lens**: `TxLatency`
- **bucket**: `BlockProcessing`
- **rationale**: Fifty-nine stable snapshot optimizer calls average 1.414s with max/median 1.15, repeatedly fanning out through at-block read-only balance lookups and MARF reads.
- **suspected spans**: `walk_backptr`, `lookup_variable`, `map-get?`, `contract-call?`
- **global materiality**: pct_blocks=Some(100.0), self_wall_ms=Some(988717.054)

### `dlmm-add-liquidity-multi-throughput`

- **kind**: `ContractFamily`
- **selection lens**: `TenureThroughput`
- **bucket**: `BlockProcessing`
- **rationale**: DLMM add-liquidity-multi has 592 calls, stable max/median 3.4, and consumes 29.86% runtime plus 35.68-45.44% of read/write axes in the run.
- **suspected spans**: `walk_backptr`, `put`, `serialize_write`, `lookup_variable`, `map-set`
- **global materiality**: pct_blocks=Some(100.0), self_wall_ms=Some(1282647.692)

### `marf-trie-seal-hash-recalculation`

- **kind**: `BlockFamily`
- **selection lens**: `CommitTime`
- **bucket**: `BlockCommit`
- **rationale**: calculate_node_hashes recurs in all 15,000 blocks with 381.328s self wall and top3 share 2.6%, dominated by finalize/advance seal trie hashing.
- **suspected spans**: `calculate_node_hashes`, `get_block_hash`, `inner_get_trie_ancestor_hashes_bytes`
- **global materiality**: pct_blocks=Some(100.0), self_wall_ms=Some(436414.308)

## Rejected alternative families (6)

- `dlmm-withdraw-liquidity-multi` (lens `TxLatency`): dominated by 1-2 outlier representatives
- `dlmm-swap-router-multi` (lens `TxLatency`): dominated by 1-2 outlier representatives
- `clarity-vm-abort-wrapper` (lens `TxLatency`): suspected spans exact-match non-targets: with_abort_callback
- `contract-metadata-fetch-cache` (lens `TxLatency`): suspected spans exact-match non-targets: fetch_metadata
- `contract-cache-get-contract` (lens `TxLatency`): suspected spans exact-match non-targets: get_contract
- `defined-function-canonicalize-types` (lens `TxLatency`): suspected spans exact-match non-targets: canonicalize_types
