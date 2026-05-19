You are preparing a GitHub pull request for an autonomous optimization run on `stacks-core`. There are two PR shapes you may be asked to write — see "Delivery mode" below — and the expected framing differs significantly between them.

# Goal

Write concise, factual PR artifacts for this target:

- `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/sessions/20260518-190321-nextest-flags-smoke/results/optimize/marf-deferred-node-hash-direct-digest/pr-title.txt` — a single-line PR title
- `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/sessions/20260518-190321-nextest-flags-smoke/results/optimize/marf-deferred-node-hash-direct-digest/pr-body.md` — a markdown PR body

Do NOT create the PR yourself. Do NOT use GitHub tools. Only write the two files above.

# Delivery mode

Your delivery mode for this target is `normal_pr`. Two PR shapes:

- **`normal_pr`** — a standard performance optimization. The optimizer ran the full nextest suite and the coordinator measured a real improvement above the noise floor. The PR is a regular draft (or non-draft per operator preference) seeking review and merge in the usual way.

- **`consensus_poc_pr`** — a deliberate consensus-breaking change shipped as a PoC. The optimizer ran nextest filtered to `poc_test_scope` ONLY; the full suite is not the acceptance gate and may encode old consensus expectations that the change deliberately invalidates. **No benchmark ran** — the bench harness encodes pre-change consensus rules and would either crash or produce meaningless numbers. The PR is ALWAYS a draft and the publisher applies safety labels (`consensus-change`, `needs-HIP`, `do-not-merge`) to prevent accidental merging. The PR is the entry point for HIP-style discussion of the consensus change.

If `normal_pr` is `consensus_poc_pr`, the framing in your PR body MUST make the consensus nature obvious:

- Title: prefer `consensus(PoC): <specific change summary>` or `perf(consensus PoC): <…>` so the consensus nature shows up at a glance.
- `## Summary`: state explicitly that this is a consensus-breaking PoC and that the change requires HIP-style coordination before merge.
- `## What changed`: same content, no special framing needed.
- `## Benchmark result`: the bench was SKIPPED BY DESIGN. State this explicitly. Do not invent improvement numbers. Cite the analyzer's `expected_improvement` vector from the target JSON if useful, but make clear it's an analyzer estimate, not a measured result.
- `## Validation`: the scoped nextest run is the acceptance gate. Cite the scoped tests that passed (from `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/sessions/20260518-190321-nextest-flags-smoke/results/optimize/marf-deferred-node-hash-direct-digest/nextest.log`) and the breakage_class. Note explicitly that the full suite was NOT the gate and that some non-scoped tests may encode pre-change consensus expectations the fix invalidates. Do NOT claim full-suite passage.
- Add a final `## Consensus / HIP coordination` section pulling from the target's `consensus_writeup` field — what the rule change is, who pays for it, what HIP discussion would be required.

# Inputs

- Session id: `20260518-190321-nextest-flags-smoke`
- Target id: `marf-deferred-node-hash-direct-digest`
- Output directory: `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/sessions/20260518-190321-nextest-flags-smoke/results/optimize/marf-deferred-node-hash-direct-digest`
- Worktree directory: `/private/tmp/sbagent-workspaces/optimizers/20260518-190321-nextest-flags-smoke/marf-deferred-node-hash-direct-digest`
- Accepted target JSON:

```json
{
  "id": "marf-deferred-node-hash-direct-digest",
  "merged_from": [
    {
      "family_id": "finalize-trie-node-hashing",
      "target_index": 0
    }
  ],
  "convergence_count": 1,
  "target_span": "calculate_node_hashes",
  "bucket": "block_commit",
  "hotspot": {
    "span": "calculate_node_hashes",
    "self_wall_us": 20653910,
    "total_wall_us": 58811400,
    "calls": 677524,
    "location": "stackslib/src/chainstate/stacks/index/storage.rs:818"
  },
  "files": [
    "stackslib/src/chainstate/stacks/index/storage.rs",
    "stackslib/src/chainstate/stacks/index/node.rs",
    "stackslib/src/chainstate/stacks/index/trie.rs",
    "stackslib/src/chainstate/stacks/index/test/storage.rs",
    "stackslib/src/chainstate/stacks/index/test/marf.rs"
  ],
  "evidence": "Commit-time lens is real and directly actionable. In the full run, `calculate_node_hashes` appears in 100.0% of blocks, with 677,524 calls, 58,811.4 ms inclusive wall, and 20,653.91 ms self wall; top3 share is only 1.2%, so this is not an outlier artifact. The commit anchors total about 298.5 s across the run (`Segment: Finalize (merkle+seal)` 122,997.08 ms, `Segment: Clarity State Commit` 55,639.78 ms, `Segment: Advance Chain Tip` 96,773.62 ms, `Segment: Index Commit` 23,126.26 ms), so this target's exclusive CPU is about 6.9% of commit-bucket time. All five representatives exercise the same seal path under `Segment: Finalize (merkle+seal)`: block 0xc613f8cb... has 84.104 ms finalize self in `calculate_node_hashes`, 0xa636ba8a... has 79.529 ms, 0x1d89e048... has 77.400 ms, 0x41a2093c... has 76.575 ms, and 0xe93cf098... has 59.098 ms. The e93 trace shows the hierarchy `Segment: Finalize (merkle+seal)` -> `mine_nakamoto_block` -> `seal` -> `seal_trie` -> `MARF::seal` -> recursive `calculate_node_hashes`, confirming the target is below the commit anchor and not a wrapper. Code evidence: `TrieRAM::inner_seal_marf()` calls `calculate_node_hashes(storage_tx, 0)` in deferred hash mode; `calculate_node_hashes()` clones each node, calls `node.write_consensus_bytes(storage_tx, &mut hasher)`, then walks `node.ptrs()` again to append child hashes, recursing for same-block children and calling `get_block_hash_caching()` for back-pointers. The self time is CPU-heavy (20,284.77 ms self CPU vs 20,653.91 ms self wall), so the handle is reducing hashing/serialization overhead rather than I/O. The related suspected span `inner_get_trie_ancestor_hashes_bytes` is real but has only 2,632.54 ms self wall; its 158,275.5 ms inclusive wall is mostly generic MARF back-pointer lookup work and is a separate optimization surface, not the node-hashing target selected here.",
  "proposed_change": "Add a specialized deferred-seal hashing path inside `TrieRAM::calculate_node_hashes` that feeds the `Sha512_256` digest directly with `Digest::update()` instead of routing fixed byte slices through the generic `std::io::Write` consensus-serialization path. Keep the exact consensus byte order: node id, each pointer's consensus bytes (`id`, `chr`, block hash or 32 zero bytes), path bytes, then the 32-byte child hash stream. The helper should inline the pointer serialization used by `TriePtr::write_consensus_bytes`, hoist the empty trie hash and zero block-hash bytes as reusable constants, and retain the existing recursive child-hash/write-back behavior for deferred mode. Leave the generic `ConsensusSerializable` implementation untouched for proof/test callers; only the seal-time deferred MARF path should use the new helper.",
  "expected_improvement": {
    "tx_latency": 0.0,
    "tenure_throughput": 0.0,
    "commit_time": 2.5
  },
  "risk": "medium",
  "verification_plan": "Do not change hash bytes or on-disk format. Add focused unit coverage that compares the new deferred direct-digest path against the existing generic consensus serialization for Node4, Node16, Node48, Node256, empty pointers, same-block pointers, and back-pointers. Then run the existing MARF/index tests that compare root hashes across `TrieHashCalculationMode::Deferred`, `Immediate`, and `All`, plus targeted block replay for the five representative blocks to measure the commit-bucket delta.",
  "verification_replay": {
    "blocks": [
      "0xc613f8cb0006d1963f1bd891c7992da0d5db44091ab48e225e92ebbae09df024",
      "0xa636ba8ad97f366ff6bdb4a50f25fd3c116e5aafd758336c4f21b4edcb257ef6",
      "0x1d89e0480357303e5f6ac2e90ca9973e2bef038438e7594fabf90873b51df4af",
      "0x41a2093cc795e49934ff25268f62e8c7a7cc13e904a4d45030e3a8ac72bfb729",
      "0xe93cf098a806c42ec1631d138c54e5f234513e9926a48270f04cfb307c507f8f"
    ],
    "repetitions": 10,
    "rationale": "Block-context seal-path change; these five blocks are the promoted representatives and the top five `calculate_node_hashes` blocks by self wall."
  },
  "consensus_breaking": false,
  "delivery_mode": "normal_pr",
  "bench_eligible": true
}
```

- Final benchmark summary for this target:

```json
{
  "target_id": "marf-deferred-node-hash-direct-digest",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    5
  ],
  "improvement_pct": 89.5067346436799
}
```

- Implementation notes are in `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/sessions/20260518-190321-nextest-flags-smoke/results/optimize/marf-deferred-node-hash-direct-digest/implementation.md`
- Test output (truncate as needed) lives in `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/sessions/20260518-190321-nextest-flags-smoke/results/optimize/marf-deferred-node-hash-direct-digest/nextest.log` and `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/sessions/20260518-190321-nextest-flags-smoke/results/optimize/marf-deferred-node-hash-direct-digest/nextest.stderr.log`. Cite specific numbers from these files in the `Validation` section rather than paraphrasing.
- Build log (for any flag/version-related notes) is at `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/sessions/20260518-190321-nextest-flags-smoke/results/optimize/marf-deferred-node-hash-direct-digest/cargo-build.log`.

# Requirements

- Be accurate and conservative. Do not claim results that are not present in the inputs.
- Keep the title under 80 characters when possible.
- Title style depends on delivery mode: `perf: <…>` for `normal_pr`, `consensus(PoC): <…>` (or `perf(consensus PoC): <…>`) for `consensus_poc_pr`.
- The PR body MUST include these sections (in this order):
  - `## Summary`
  - `## What changed`
  - `## Benchmark result`
  - `## Validation`
- Plus, when `normal_pr` is `consensus_poc_pr`: a final `## Consensus / HIP coordination` section.
- For `normal_pr`: in `Benchmark result`, include the measured `improvement_pct` from `{
  "target_id": "marf-deferred-node-hash-direct-digest",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    5
  ],
  "improvement_pct": 89.5067346436799
}` and the run ids from `run_ids`. In `Validation`, summarize tests/verification from `implementation.md` without inventing anything.
- For `consensus_poc_pr`: `{
  "target_id": "marf-deferred-node-hash-direct-digest",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    5
  ],
  "improvement_pct": 89.5067346436799
}` is `{}` (no benchmark ran). Do NOT invent improvement numbers. State explicitly that the benchmark was skipped by design (the harness encodes pre-change consensus). Cite the analyzer's `expected_improvement` vector from `{
  "id": "marf-deferred-node-hash-direct-digest",
  "merged_from": [
    {
      "family_id": "finalize-trie-node-hashing",
      "target_index": 0
    }
  ],
  "convergence_count": 1,
  "target_span": "calculate_node_hashes",
  "bucket": "block_commit",
  "hotspot": {
    "span": "calculate_node_hashes",
    "self_wall_us": 20653910,
    "total_wall_us": 58811400,
    "calls": 677524,
    "location": "stackslib/src/chainstate/stacks/index/storage.rs:818"
  },
  "files": [
    "stackslib/src/chainstate/stacks/index/storage.rs",
    "stackslib/src/chainstate/stacks/index/node.rs",
    "stackslib/src/chainstate/stacks/index/trie.rs",
    "stackslib/src/chainstate/stacks/index/test/storage.rs",
    "stackslib/src/chainstate/stacks/index/test/marf.rs"
  ],
  "evidence": "Commit-time lens is real and directly actionable. In the full run, `calculate_node_hashes` appears in 100.0% of blocks, with 677,524 calls, 58,811.4 ms inclusive wall, and 20,653.91 ms self wall; top3 share is only 1.2%, so this is not an outlier artifact. The commit anchors total about 298.5 s across the run (`Segment: Finalize (merkle+seal)` 122,997.08 ms, `Segment: Clarity State Commit` 55,639.78 ms, `Segment: Advance Chain Tip` 96,773.62 ms, `Segment: Index Commit` 23,126.26 ms), so this target's exclusive CPU is about 6.9% of commit-bucket time. All five representatives exercise the same seal path under `Segment: Finalize (merkle+seal)`: block 0xc613f8cb... has 84.104 ms finalize self in `calculate_node_hashes`, 0xa636ba8a... has 79.529 ms, 0x1d89e048... has 77.400 ms, 0x41a2093c... has 76.575 ms, and 0xe93cf098... has 59.098 ms. The e93 trace shows the hierarchy `Segment: Finalize (merkle+seal)` -> `mine_nakamoto_block` -> `seal` -> `seal_trie` -> `MARF::seal` -> recursive `calculate_node_hashes`, confirming the target is below the commit anchor and not a wrapper. Code evidence: `TrieRAM::inner_seal_marf()` calls `calculate_node_hashes(storage_tx, 0)` in deferred hash mode; `calculate_node_hashes()` clones each node, calls `node.write_consensus_bytes(storage_tx, &mut hasher)`, then walks `node.ptrs()` again to append child hashes, recursing for same-block children and calling `get_block_hash_caching()` for back-pointers. The self time is CPU-heavy (20,284.77 ms self CPU vs 20,653.91 ms self wall), so the handle is reducing hashing/serialization overhead rather than I/O. The related suspected span `inner_get_trie_ancestor_hashes_bytes` is real but has only 2,632.54 ms self wall; its 158,275.5 ms inclusive wall is mostly generic MARF back-pointer lookup work and is a separate optimization surface, not the node-hashing target selected here.",
  "proposed_change": "Add a specialized deferred-seal hashing path inside `TrieRAM::calculate_node_hashes` that feeds the `Sha512_256` digest directly with `Digest::update()` instead of routing fixed byte slices through the generic `std::io::Write` consensus-serialization path. Keep the exact consensus byte order: node id, each pointer's consensus bytes (`id`, `chr`, block hash or 32 zero bytes), path bytes, then the 32-byte child hash stream. The helper should inline the pointer serialization used by `TriePtr::write_consensus_bytes`, hoist the empty trie hash and zero block-hash bytes as reusable constants, and retain the existing recursive child-hash/write-back behavior for deferred mode. Leave the generic `ConsensusSerializable` implementation untouched for proof/test callers; only the seal-time deferred MARF path should use the new helper.",
  "expected_improvement": {
    "tx_latency": 0.0,
    "tenure_throughput": 0.0,
    "commit_time": 2.5
  },
  "risk": "medium",
  "verification_plan": "Do not change hash bytes or on-disk format. Add focused unit coverage that compares the new deferred direct-digest path against the existing generic consensus serialization for Node4, Node16, Node48, Node256, empty pointers, same-block pointers, and back-pointers. Then run the existing MARF/index tests that compare root hashes across `TrieHashCalculationMode::Deferred`, `Immediate`, and `All`, plus targeted block replay for the five representative blocks to measure the commit-bucket delta.",
  "verification_replay": {
    "blocks": [
      "0xc613f8cb0006d1963f1bd891c7992da0d5db44091ab48e225e92ebbae09df024",
      "0xa636ba8ad97f366ff6bdb4a50f25fd3c116e5aafd758336c4f21b4edcb257ef6",
      "0x1d89e0480357303e5f6ac2e90ca9973e2bef038438e7594fabf90873b51df4af",
      "0x41a2093cc795e49934ff25268f62e8c7a7cc13e904a4d45030e3a8ac72bfb729",
      "0xe93cf098a806c42ec1631d138c54e5f234513e9926a48270f04cfb307c507f8f"
    ],
    "repetitions": 10,
    "rationale": "Block-context seal-path change; these five blocks are the promoted representatives and the top five `calculate_node_hashes` blocks by self wall."
  },
  "consensus_breaking": false,
  "delivery_mode": "normal_pr",
  "bench_eligible": true
}` only as an analyzer estimate.
- Mention risk briefly if it is present in the target JSON.

# Output format

- `pr-title.txt` should contain exactly one plain-text line.
- `pr-body.md` should be valid markdown with the sections above.

Do not edit source code. Do not stage, commit, push, or publish anything.
