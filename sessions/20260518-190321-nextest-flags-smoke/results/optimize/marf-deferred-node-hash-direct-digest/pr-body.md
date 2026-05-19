## Summary

Optimizes deferred MARF seal-time node hashing by feeding consensus bytes directly into the `Sha512_256` digest instead of routing fixed byte slices through the generic `std::io::Write` serialization adapter.

The target hotspot was `calculate_node_hashes` in the block commit path. Risk is medium because the changed path is consensus-sensitive, but the generic consensus serialization implementation remains unchanged and the new helper is covered by parity tests.

## What changed

- Added a direct consensus-prefix hashing helper for MARF trie node types in `stackslib/src/chainstate/stacks/index/storage.rs`.
- Updated `TrieRAM::calculate_node_hashes` to use `Digest::update()` for the deferred seal hot path, including child hash bytes, empty child hashes, and ancestor block hashes.
- Preserved the existing byte order: node id, pointer id/chr/block-hash-or-zero bytes, path length, path bytes, then child hash bytes.
- Added focused coverage comparing the direct digest path against the existing generic consensus serializer for Node4, Node16, Node48, Node256, empty pointers, same-block pointers, and back-pointers.

## Benchmark result

Accepted benchmark result for this target:

- Run ids: `5`
- Measured improvement: `89.5067346436799%`

The analyzer expected this to affect commit time (`expected_improvement.commit_time = 2.5`) by reducing CPU-heavy hashing/serialization overhead in `calculate_node_hashes`.

## Validation

- `cargo nextest run --no-fail-fast --retries 2`
- Nextest run ID: `e5d1cc9d-9b94-4f35-aff9-b222d51c10de`
- Nextest profile: `default`
- Result: `10490 tests run: 10490 passed (24 slow), 417 skipped`
- Duration: `847.405s`
- Build completed in the optimized test profile: `Finished test profile [optimized + debuginfo] target(s) in 1m 57s`

Implementation report also records `failed: 0`, `clippy_clean: true`, and the focused parity test `stackslib::chainstate::stacks::index::test::storage::direct_deferred_node_hash_matches_consensus_serialization`.
