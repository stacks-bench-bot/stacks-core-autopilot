## Summary

Adds a transaction-local read-through cache to `RollbackWrapper` for materialized backing-store reads while `query_pending_data` is false. The cache targets repeated historical reads under at-block evaluation, is scoped by active Stacks block hash and wrapper lifetime, and keeps existing Clarity deserialization and cost paths in place.

Risk: medium. This touches consensus-sensitive Clarity database paths, but pending rollback data remains authoritative when visible, proof reads are not cached, and cached values are raw backing-store results that still pass through the existing decode paths.

## What changed

- Cache raw `get_data`/`get_value` backing-store results by active block hash and key.
- Cache ordinary metadata reads by active block hash, contract, and metadata key.
- Leave `get_metadata_manual` uncached because it is keyed by an explicit height rather than the active block hash.
- Clear the materialized read caches on bottom commits and keep pending-data reads outside the cache path.
- Add focused `RollbackWrapper` tests for block-hash isolation, pending-write visibility, value reads, and metadata reads.

## Benchmark result

The representative-heavy replay accepted the hypothesis: exact target transaction latency improved 27.22% across the five requested txids and 20 repetitions each. The profile moved in the expected place: at-block/evaluate_at_block total wall fell about 28.8%, PersistentWritableMarfStore::get_data fell 36.7%, and the MARF walk path fell about 37%. Clarity-level cost counters were unchanged, so this is a wall-time latency improvement rather than a consensus budget change. The measured gain is materially larger than the analyzer's 6% estimate, likely because the implementation also reduced ordinary metadata backing reads in this workload.

| invocation | baseline run | candidate run | measured | matches expected signal |
| --- | ---: | ---: | ---: | --- |
| representative heavy txs | 8 | 11 | 27.22% | yes |

**Caveats.**

- The measured 27.22% tx-latency gain is well above the expected 6% +/- 4% estimate; the direction and mechanism match, but confidence is medium because the magnitude estimate was not close.
- This replay is intentionally concentrated on five heavy dual-stacking snapshot txids, so the headline should be read as representative-heavy replay latency, not broad network-average throughput.
- The optimizer also cached ordinary metadata reads, and metadata backing-store spans dropped materially; get_metadata_manual remained uncached as reported by the optimizer.

## Validation

- `cargo nextest run --no-fail-fast --retries 2`
- Nextest run ID `d9cdec03-7d21-4cca-bd53-4f0b50160793`: started 10,502 tests across 22 binaries, with 417 skipped.
- Nextest summary: `10502 tests run: 10502 passed (24 slow), 417 skipped`; reported wall time was `835.114s` and `real 963.60`.
- Focused tests included in the passing suite:
  - `clarity::vm::database::key_value_wrapper::tests::materialized_reads_are_cached_by_block_hash`
  - `clarity::vm::database::key_value_wrapper::tests::materialized_read_cache_ignores_surrounding_pending_writes`
  - `clarity::vm::database::key_value_wrapper::tests::materialized_cache_is_used_by_value_reads`
  - `clarity::vm::database::key_value_wrapper::tests::materialized_metadata_reads_are_cached_by_block_hash`
