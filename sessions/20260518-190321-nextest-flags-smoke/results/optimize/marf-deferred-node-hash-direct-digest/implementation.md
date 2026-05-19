# Implementation report — `marf-deferred-node-hash-direct-digest`

_Coordinator-rendered companion view of `optimizer-report.json`. The JSON is authoritative; this file regenerates from it on every commit/demote pass._

- **Target**: `marf-deferred-node-hash-direct-digest`
- **Delivery mode**: `NormalPr`
- **PR title**: perf: bypass Write adapter in deferred MARF node hashing

```json
{
  "schema_version": 2,
  "session_id": "20260518-190321-nextest-flags-smoke",
  "target_id": "marf-deferred-node-hash-direct-digest",
  "outcome": "implemented",
  "delivery_mode": "normal_pr",
  "implementation_summary": "Added a direct `Digest::update` MARF node consensus-prefix hashing helper in `stackslib/src/chainstate/stacks/index/storage.rs` and used it from `TrieRAM::calculate_node_hashes`, avoiding the generic `std::io::Write` serialization adapter on the deferred seal hot path while preserving the existing recursive child-hash/write-back behavior.",
  "test_summary": {
    "framework": "nextest",
    "passed": 10490,
    "failed": 0,
    "duration_secs": 847.405,
    "log_path": "nextest.log"
  },
  "clippy_clean": true,
  "pr_title": "perf: bypass Write adapter in deferred MARF node hashing",
  "parity": {
    "consensus_sensitive": true,
    "evidence": [
      "The direct hashing helper feeds the same consensus byte order as `TrieNode::write_consensus_bytes`: node id, pointer id/chr/block-hash-or-zero bytes, path length, and path bytes.",
      "A focused parity test compares direct digest output against the existing consensus serializer for Node4, Node16, Node48, and Node256 with empty pointers, same-block pointers, and back-pointers.",
      "The full nextest suite passed, including existing MARF/index coverage that checks root hashes across hash calculation modes."
    ],
    "tests": [
      "stackslib::chainstate::stacks::index::test::storage::direct_deferred_node_hash_matches_consensus_serialization",
      "cargo nextest run --no-fail-fast --retries 2"
    ],
    "unproven_risk": null
  }
}
```
