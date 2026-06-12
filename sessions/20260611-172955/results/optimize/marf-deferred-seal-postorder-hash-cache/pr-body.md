## Summary

Refactors deferred MARF seal hashing to compute the same post-order hashes with an explicit pass instead of recursive `TrieNodeType` cloning. The goal is to reduce commit-time work in `TrieRAM::calculate_node_hashes` while preserving the consensus byte stream used for node and backpointer hashing.

Risk: medium. This touches consensus-sensitive MARF hashing internals, but the implementation keeps `TrieNodeType::write_consensus_bytes`, `TrieStorageTransaction::get_block_hash_caching`, Deferred-mode hash writes, and All-mode parity checks on the same hashing path.

## What changed

- Reworked `TrieRAM::calculate_node_hashes` into an explicit post-order seal pass with a per-slot hash memo.
- Avoided cloning full trie node values and recursive same-block child hashing during deferred seal calculation.
- Preserved cached block-hash lookup behavior for backpointers.
- Added a MARF parity test that compares Immediate and Deferred root hash tables over Node256 fanout with backpointer-heavy updates.

## Benchmark result

Benchmark replay shows the refactor moved the intended MARF seal hashing path, but the end-to-end commit-time win is smaller than predicted. Across the hot finalize block replay, average commit time improved by 1.004% versus the expected 8% +/- 5%, while total block time improved by 1.846%. The `calculate_node_hashes` span improved by 5.174% in exclusive wall time and its recursive call count collapsed from 83,094 to 100, which supports the implementation mechanism. Per-block commit movement was mixed, ranging from a 6.696% gain on `9407bf...` to a 2.806% regression on `a2ebb2...`, so this should ship only with the caveat that the macro commit-time gain is modest.

| Invocation | Baseline run | Candidate run | Measured | Matches expected signal |
| --- | ---: | ---: | ---: | --- |
| hot finalize blocks | 9 | 12 | 1.004% | false |

**Caveats.**

- The accepted mechanism signal is stronger than the macro commit-time signal: `calculate_node_hashes` exclusive wall improved 5.174%, but commit time improved only 1.004%.
- `calculate_node_hashes` inclusive wall and call-count deltas are structurally affected by the recursive-to-iterative refactor, so exclusive wall is the fair span metric.
- Commit-time movement is uneven across the five replayed block hashes, including a 2.806% regression on `a2ebb2...`.

## Validation

- Full `cargo nextest` suite passed: 10,499 tests run, 10,499 passed, 0 failed, 417 skipped, across 22 binaries in 830.871s.
- Added and covered `stackslib::chainstate::stacks::index::test::marf::marf_deferred_seal_postorder_hash_parity`.
- Implementation report marks clippy clean.
