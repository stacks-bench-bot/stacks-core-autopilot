# Optimization targets — session 20260518-190321-nextest-flags-smoke

> Catalog of merged optimization targets produced by Phase 1.7 (merge). For pass/fail verdicts and benchmark deltas, see [summary.md](summary.md).

- Baseline run id: `1`
- Baseline rerun id: `1`
- Noise floor: `1%`
- Merge method: `LLM`
- Merge model: `gpt-5.5`

## Contents

- [marf-deferred-node-hash-direct-digest](#marf-deferred-node-hash-direct-digest) — Normal PR, bucket=`Block commit`, risk=`Medium`

## marf-deferred-node-hash-direct-digest

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
- self_wall: `20653910` µs · total_wall: `58811400` µs · calls: `677524`

**Expected improvement**

- tx_latency: `0.00%`
- tenure_throughput: `0.00%`
- commit_time: `2.50%`

**Files**

- `stackslib/src/chainstate/stacks/index/storage.rs`
- `stackslib/src/chainstate/stacks/index/node.rs`
- `stackslib/src/chainstate/stacks/index/trie.rs`
- `stackslib/src/chainstate/stacks/index/test/storage.rs`
- `stackslib/src/chainstate/stacks/index/test/marf.rs`

**Evidence**

> Commit-time lens is real and directly actionable. In the full run, `calculate_node_hashes` appears in 100.0% of blocks, with 677,524 calls, 58,811.4 ms inclusive wall, and 20,653.91 ms self wall; top3 share is only 1.2%, so this is not an outlier artifact. The commit anchors total about 298.5 s across the run (`Segment: Finalize (merkle+seal)` 122,997.08 ms, `Segment: Clarity State Commit` 55,639.78 ms, `Segment: Advance Chain Tip` 96,773.62 ms, `Segment: Index Commit` 23,126.26 ms), so this target's exclusive CPU is about 6.9% of commit-bucket time. All five representatives exercise the same seal path under `Segment: Finalize (merkle+seal)`: block 0xc613f8cb... has 84.104 ms finalize self in `calculate_node_hashes`, 0xa636ba8a... has 79.529 ms, 0x1d89e048... has 77.400 ms, 0x41a2093c... has 76.575 ms, and 0xe93cf098... has 59.098 ms. The e93 trace shows the hierarchy `Segment: Finalize (merkle+seal)` -> `mine_nakamoto_block` -> `seal` -> `seal_trie` -> `MARF::seal` -> recursive `calculate_node_hashes`, confirming the target is below the commit anchor and not a wrapper. Code evidence: `TrieRAM::inner_seal_marf()` calls `calculate_node_hashes(storage_tx, 0)` in deferred hash mode; `calculate_node_hashes()` clones each node, calls `node.write_consensus_bytes(storage_tx, &mut hasher)`, then walks `node.ptrs()` again to append child hashes, recursing for same-block children and calling `get_block_hash_caching()` for back-pointers. The self time is CPU-heavy (20,284.77 ms self CPU vs 20,653.91 ms self wall), so the handle is reducing hashing/serialization overhead rather than I/O. The related suspected span `inner_get_trie_ancestor_hashes_bytes` is real but has only 2,632.54 ms self wall; its 158,275.5 ms inclusive wall is mostly generic MARF back-pointer lookup work and is a separate optimization surface, not the node-hashing target selected here.

**Proposed change**

> Add a specialized deferred-seal hashing path inside `TrieRAM::calculate_node_hashes` that feeds the `Sha512_256` digest directly with `Digest::update()` instead of routing fixed byte slices through the generic `std::io::Write` consensus-serialization path. Keep the exact consensus byte order: node id, each pointer's consensus bytes (`id`, `chr`, block hash or 32 zero bytes), path bytes, then the 32-byte child hash stream. The helper should inline the pointer serialization used by `TriePtr::write_consensus_bytes`, hoist the empty trie hash and zero block-hash bytes as reusable constants, and retain the existing recursive child-hash/write-back behavior for deferred mode. Leave the generic `ConsensusSerializable` implementation untouched for proof/test callers; only the seal-time deferred MARF path should use the new helper.

**Verification plan**

> Do not change hash bytes or on-disk format. Add focused unit coverage that compares the new deferred direct-digest path against the existing generic consensus serialization for Node4, Node16, Node48, Node256, empty pointers, same-block pointers, and back-pointers. Then run the existing MARF/index tests that compare root hashes across `TrieHashCalculationMode::Deferred`, `Immediate`, and `All`, plus targeted block replay for the five representative blocks to measure the commit-bucket delta.

**Contributors**

- [finalize-trie-node-hashing](../analysis/finalize-trie-node-hashing/analysis.json) (target_index `0`)

**Outputs**

- Experiment dir: [`../optimize/marf-deferred-node-hash-direct-digest/`](../optimize/marf-deferred-node-hash-direct-digest/)
- [implementation.md](../optimize/marf-deferred-node-hash-direct-digest/implementation.md) · [side-observations.md](../optimize/marf-deferred-node-hash-direct-digest/side-observations.md) · [abort.md](../optimize/marf-deferred-node-hash-direct-digest/abort.md)

## Lens dispositions

| Family | Lens | Status | Reason |
| ------ | ---- | ------ | ------ |
| [clarity-commit-trie-blob-append](../analysis/clarity-commit-trie-blob-append/analysis.json) | Commit time | Not actionable | The commit-time signal is real, but the dominant code in `TrieFile::append_trie_blob` is the required external-blob durability barrier: after determining the append offset it writes the serialized trie blob, flushes the file handle, and calls `fd.sync_data()` before `trie_sql::write_external_trie_blob` records the offset/length in SQLite and before the enclosing MARF transaction commits. Removing or deferring that sync would allow a crash to leave durable SQLite metadata pointing at an un-durable or missing `.blobs` range. A meaningful fix would require a MARF external-blob storage/durability redesign or wider transaction protocol, not a localized code optimization to the current append path. |
| [finalize-trie-node-hashing](../analysis/finalize-trie-node-hashing/analysis.json) | Commit time | Addressed | — |
| [finalize-trie-node-hashing-alt](../analysis/finalize-trie-node-hashing-alt/analysis.json) | Commit time | Addressed | The promoted lens is real: all five representatives spend dominant Finalize (merkle+seal) wall time in deferred MARF trie node hashing, and the emitted target reduces commit-bucket seal work directly. |
| [gl-api-oracle-price-runtime](../analysis/gl-api-oracle-price-runtime/analysis.json) | Tenure throughput | Not actionable | The promoted runtime-axis signal is real, and runtime is the nearest Clarity budget axis for these blocks, though the sampled blocks are not cap-saturating: the largest gl-api block uses about 1.54B runtime of a 5B Epoch33 budget while read/write axes are much farther from their caps. The code-level cause is Epoch33 Clarity value lookup/clone charging: tuple_get evaluates the tuple expression then calls ValueRef::clone_with_cost before extracting a field, and clone_with_cost charges LookupVariableSize for large fold accumulator values. All 48 gl-api open/close calls in the run are at burn heights 925436-925508 in Epoch33, while the repo already gates pre-sanitized borrowed variable lookup to Epoch34 through StacksEpochId::uses_pre_sanitized_variables and Clarity VM ValueRef handling. Changing Epoch33 costs or clone semantics for these representatives would alter historical consensus; a non-consensus Rust optimization would not move the tenure-throughput lens. |
