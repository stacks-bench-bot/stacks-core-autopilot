# Implementation report — `marf-deferred-seal-postorder-hash-cache`

_Coordinator-rendered companion view of `optimizer-report.json`. The JSON is authoritative; this file regenerates from it on every commit/demote pass._

- **Target**: `marf-deferred-seal-postorder-hash-cache`
- **Delivery mode**: `NormalPr`
- **PR title**: perf: hash deferred MARF seals without cloning trie nodes

```json
{
  "schema_version": 2,
  "session_id": "20260611-172955",
  "target_id": "marf-deferred-seal-postorder-hash-cache",
  "outcome": "implemented",
  "delivery_mode": "normal_pr",
  "implementation_summary": "Refactored TrieRAM::calculate_node_hashes in stackslib/src/chainstate/stacks/index/storage.rs into an explicit post-order seal pass with a per-slot hash memo, avoiding full TrieNodeType clones and recursive calls while preserving the same consensus serialization and backpointer hash lookups. Added a MARF parity test in stackslib/src/chainstate/stacks/index/test/marf.rs that compares root hash tables across Immediate and Deferred modes over a Node256 fanout with backpointer-heavy updates.",
  "test_summary": {
    "framework": "nextest",
    "passed": 10499,
    "failed": 0,
    "duration_secs": 830.871,
    "log_path": "nextest.log"
  },
  "clippy_clean": true,
  "pr_title": "perf: hash deferred MARF seals without cloning trie nodes",
  "parity": {
    "consensus_sensitive": true,
    "evidence": [
      "Deferred seal hashing still uses TrieNodeType::write_consensus_bytes and TrieStorageTransaction::get_block_hash_caching for the same node and backpointer byte stream.",
      "MARF root hash tables match across Immediate and Deferred hash modes for normal insert/commit flows with full Node256 fanout and backpointer-heavy updates."
    ],
    "tests": [
      "stackslib::chainstate::stacks::index::test::marf::marf_deferred_seal_postorder_hash_parity",
      "Full cargo nextest suite: 10499 tests passed"
    ],
    "unproven_risk": null
  }
}
```
