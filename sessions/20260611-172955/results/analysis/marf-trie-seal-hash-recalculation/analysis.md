# MARF Trie Seal Hash Recalculation

Status: accepted. The `commit_time` selection lens is addressed.

The triage signal is real commit-bucket work. In run 6, `calculate_node_hashes` has 381.328s exclusive wall, 1,272.836s inclusive wall, 2,132,356 calls, and appears in 100% of blocks with no transaction association. The per-block distribution is broad: p50 18.794ms, p95 58.877ms, p99 118.061ms, and top-three share 2.6%.

All five representatives confirm the same shape under `Segment: Finalize (merkle+seal)`: `calculate_node_hashes` accounts for nearly all finalize time. The suspected `inner_get_trie_ancestor_hashes_bytes` span is present but much smaller in these traces, so it is not the primary optimization handle.

## Target

`marf-deferred-seal-postorder-hash-cache`

Optimize `TrieRAM::calculate_node_hashes` in `stackslib/src/chainstate/stacks/index/storage.rs`. The current deferred seal path clones each node with `get_nodetype(...).to_owned()`, serializes consensus bytes, scans pointers, recursively hashes same-block children, and writes deferred hashes back. `get_block_hash_caching` already exists, so the main handle is the recursive deferred seal walk itself.

Proposed change: replace the recursive clone-heavy implementation with a post-order deferred seal hasher using an explicit work stack or per-node memo indexed by TrieRAM slot. Borrow each node long enough to serialize the consensus prefix and collect child descriptors, drop the borrow before child walking, memoize computed child hashes, and write the same hashes back to TrieRAM. Preserve ancestor backptr semantics and the `TrieHashCalculationMode::All` equality check.

Expected improvement: `{ tx_latency: 0, tenure_throughput: 0, commit_time: 8 }`.

Risk: medium, because the code is consensus-sensitive even though the proposed change is intended to preserve identical MARF roots and on-disk layout.

Verification should focus on existing MARF storage tests that compare deferred, immediate, and all hash modes, plus targeted replay of the five hot finalize blocks with profiler detail. No Clarity cost movement is expected.
