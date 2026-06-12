You are preparing a GitHub pull request for an autonomous optimization run on `stacks-core`. There are two PR shapes you may be asked to write — see "Delivery mode" below — and the expected framing differs significantly between them.

# Goal

Write concise, factual PR artifacts for this target:

- `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/pr-title.txt` — a single-line PR title
- `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/pr-body.md` — a markdown PR body

Do NOT create the PR yourself. Do NOT use GitHub tools. Only write the two files above.

# Delivery mode

Your delivery mode for this target is `normal_pr`. Two PR shapes:

- **`normal_pr`** — a standard performance optimization. The optimizer ran the full nextest suite; the Phase 3.5 results-analyzer judged measured vs the analyzer's `expected_signal` per invocation and committed an `accepted` or `mixed` verdict with `confidence >= results_analysis.confidence_floor`. The verdict's `pr_body_summary` is the canonical Result-section prose (read it verbatim from `{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "marf-deferred-seal-postorder-hash-cache",
  "axis": "commit_time",
  "verdict": "mixed",
  "confidence": "medium",
  "headline_rationale": "The deferred MARF seal hashing mechanism moved in the right direction, but measured commit time improved only 1.004%, below the 8% +/- 5% hypothesis window.",
  "headline_improvement_pct": 1.004,
  "per_invocation": [
    {
      "invocation_id": "hot-finalize-blocks",
      "label": "hot finalize blocks",
      "baseline_run_id": 9,
      "candidate_run_id": 12,
      "measured_pct": 1.004,
      "matches_expected_signal": false,
      "observations": [
        "Run envelopes were clean: baseline run 9 and candidate run 12 both succeeded, were not interrupted, processed 50 measured blocks and 210 transactions, and matched the run-id maps.",
        "Catalog block timing comparison showed commit_us_per_block moving from 108833.94us to 107741.78us, a 1.004% improvement; this is positive but below the expected 8% +/- 5% commit-time window.",
        "The run-level block_total_us comparison improved by 1.846%, from 63077316us to 61913162us.",
        "`calculate_node_hashes` moved in the expected direction on exclusive wall time: 1927177us baseline to 1827456us candidate, a 5.174% improvement. Calls dropped from 83094 to 100 after replacing recursive hashing with the explicit post-order pass.",
        "`calculate_node_hashes` inclusive wall time dropped by 66.967%, but that figure is not directly comparable because the implementation intentionally removes recursive nested span accounting; exclusive wall time is the better mechanism metric.",
        "`get_block_hash` also improved slightly, from 138910us to 134065us self wall, a 3.488% improvement, with calls increasing from 36980 to 37401.",
        "Grouped by replayed block hash, commit time improved 6.696% for 9407bf..., 1.430% for 06f198..., 0.458% for 615df0..., and 0.164% for 35c1c0..., but regressed 2.806% for a2ebb2....",
        "Top span-delta inspection did not show a new MARF-side regression absorbing the expected gain; the largest non-target movements were small broad Clarity/SQLite timing shifts consistent with replay variance."
      ]
    }
  ],
  "caveats": [
    "The accepted mechanism signal is stronger than the macro commit-time signal: `calculate_node_hashes` exclusive wall improved 5.174%, but commit time improved only 1.004%.",
    "`calculate_node_hashes` inclusive wall and call-count deltas are structurally affected by the recursive-to-iterative refactor, so exclusive wall is the fair span metric.",
    "Commit-time movement is uneven across the five replayed block hashes, including a 2.806% regression on `a2ebb2...`."
  ],
  "pr_body_summary": "Benchmark replay shows the refactor moved the intended MARF seal hashing path, but the end-to-end commit-time win is smaller than predicted. Across the hot finalize block replay, average commit time improved by 1.004% versus the expected 8% +/- 5%, while total block time improved by 1.846%. The `calculate_node_hashes` span improved by 5.174% in exclusive wall time and its recursive call count collapsed from 83,094 to 100, which supports the implementation mechanism. Per-block commit movement was mixed, ranging from a 6.696% gain on `9407bf...` to a 2.806% regression on `a2ebb2...`, so this should ship only with the caveat that the macro commit-time gain is modest.",
  "db_queries": [
    {
      "purpose": "Envelope sanity comparison for baseline run 9 and candidate run 12.",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513.csv"
    },
    {
      "purpose": "Paired span comparison for calculate_node_hashes, the analyzer's primary suspected mechanism span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-calculate_node_hashes.csv"
    },
    {
      "purpose": "Paired span comparison for get_block_hash, the analyzer's secondary suspected span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-get_block_hash.csv"
    },
    {
      "purpose": "Paired block timing comparison for the commit_time expected signal.",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c.csv"
    },
    {
      "purpose": "Per-block paired timing dump to inspect variance and outliers behind the small aggregate commit gain.",
      "query_digest": "f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e",
      "rows_returned": 50,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e.csv"
    },
    {
      "purpose": "Top span movement comparison to check whether sibling spans absorbed the expected commit-time gain.",
      "query_digest": "7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc",
      "rows_returned": 40,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc.csv"
    },
    {
      "purpose": "Grouped timing summary by replayed block hash to compare representative block shape.",
      "query_digest": "3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6.csv"
    }
  ]
}`). The PR is a regular draft (or non-draft per operator preference) seeking review and merge in the usual way.

- **`consensus_poc_pr`** — a deliberate consensus-breaking change shipped as a PoC. The optimizer ran nextest filtered to `poc_test_scope` ONLY; the full suite is not the acceptance gate and may encode old consensus expectations that the change deliberately invalidates. **No benchmark ran** — the bench harness encodes pre-change consensus rules and would either crash or produce meaningless numbers. The PR is ALWAYS a draft and the publisher applies safety labels (`consensus-change`, `needs-HIP`, `do-not-merge`) to prevent accidental merging. The PR is the entry point for HIP-style discussion of the consensus change.

If `normal_pr` is `consensus_poc_pr`, the framing in your PR body MUST make the consensus nature obvious:

- Title: prefer `consensus(PoC): <specific change summary>` or `perf(consensus PoC): <…>` so the consensus nature shows up at a glance.
- `## Summary`: state explicitly that this is a consensus-breaking PoC and that the change requires HIP-style coordination before merge.
- `## What changed`: same content, no special framing needed.
- `## Benchmark result`: the bench was SKIPPED BY DESIGN. State this explicitly. Do not invent improvement numbers. Cite the analyzer's `expected_improvement` vector from the target JSON if useful, but make clear it's an analyzer estimate, not a measured result.
- `## Validation`: the scoped nextest run is the acceptance gate. Cite the scoped tests that passed (from `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/nextest.log`) and the breakage_class. Note explicitly that the full suite was NOT the gate and that some non-scoped tests may encode pre-change consensus expectations the fix invalidates. Do NOT claim full-suite passage.
- Add a final `## Consensus / HIP coordination` section pulling from the target's `consensus_writeup` field — what the rule change is, who pays for it, what HIP discussion would be required.

# Inputs

- Session id: `20260611-172955`
- Target id: `marf-deferred-seal-postorder-hash-cache`
- Output directory: `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache`
- Worktree directory: `/private/tmp/sbagent-workspaces/optimizers/20260611-172955/marf-deferred-seal-postorder-hash-cache`
- Accepted target JSON:

```json
{
  "id": "marf-deferred-seal-postorder-hash-cache",
  "merged_from": [
    {
      "family_id": "marf-trie-seal-hash-recalculation",
      "target_index": 0
    }
  ],
  "convergence_count": 1,
  "target_span": "calculate_node_hashes",
  "bucket": "block_commit",
  "hotspot": {
    "span": "calculate_node_hashes",
    "self_wall_us": 381328360,
    "total_wall_us": 1272836450,
    "calls": 2132356,
    "location": "stackslib/src/chainstate/stacks/index/storage.rs:818"
  },
  "files": [
    "stackslib/src/chainstate/stacks/index/storage.rs",
    "stackslib/src/chainstate/stacks/index/node.rs",
    "stackslib/src/chainstate/stacks/index/cache.rs",
    "stackslib/src/chainstate/stacks/index/test/storage.rs",
    "stackslib/src/chainstate/stacks/index/test/marf.rs"
  ],
  "evidence": "Run 6 ranks TrieRAM::calculate_node_hashes as the #2 exclusive span: 381.328s self wall, 1,272.836s inclusive wall, 2,132,356 calls, 100% block recurrence, and no transaction association. The per-block distribution is broad rather than a single spike: 15,000/15,000 blocks, p50 18.794ms, p95 58.877ms, p99 118.061ms, top3 share 2.6%. All five representatives are the top five blocks for this span. In each trace, calculate_node_hashes sits under Segment: Finalize (merkle+seal) and dominates the finalize subtree: 5,032.9ms of 5,053.2ms for 0x06f198..., 3,476.5ms of 3,518.2ms for 0x35c1c0..., 2,664.3ms of 2,688.4ms for 0x9407bf..., 1,524.2ms of 1,549.2ms for 0x615df0..., and 1,324.1ms of 1,344.3ms for 0xa2ebb2.... The suspected inner_get_trie_ancestor_hashes_bytes path is present but much smaller in these traces, topping out at 38.736ms, so it is not the primary handle. Code in TrieRAM::inner_seal_marf calls calculate_node_hashes only in Deferred/All mode; calculate_node_hashes clones each node with get_nodetype(...).to_owned(), serializes node consensus bytes, scans ptrs, recursively hashes same-block children, looks up ancestor block hashes via the existing get_block_hash_caching cache, and writes deferred hashes back. Existing code already caches block-id to block-hash lookups, so the actionable work is reducing the deferred seal walk's clone/recursion/pointer traversal overhead while preserving the identical hash byte stream.",
  "evidence_queries": [
    {
      "purpose": "Rank run-level hotspot and capture self/inclusive wall time for the target span.",
      "sql_path": "queries/top_spans_by_self_wall.sql",
      "params": {
        "limit": "80",
        "run_id": "6"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/top-spans-self-wall.csv",
      "key_observation": "calculate_node_hashes: 381328.36ms self wall, 1272836.45ms inclusive wall, 2132356 calls, avg self 178.83us/call.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Confirm the span is block-level commit work recurring across the whole sampled workload.",
      "sql_path": "queries/span_recurrence.sql",
      "params": {
        "run_id": "6"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/span-recurrence.csv",
      "key_observation": "calculate_node_hashes appears in 15000/15000 blocks (100.0%) and 0 transactions.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Show the signal is broad and not top-block dominated.",
      "sql_path": "queries/span_per_block_distribution.sql",
      "params": {
        "run_id": "6",
        "span_id": "84"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/calculate-node-hashes-block-distribution.csv",
      "key_observation": "15000 blocks, p50 18.794ms, p95 58.877ms, p99 118.061ms, top3 share 2.6%.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Identify stable replay block hashes for the hottest representatives.",
      "sql_path": "queries/top_blocks_for_span.sql",
      "params": {
        "limit": "20",
        "run_id": "6",
        "span_id": "84"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/calculate-node-hashes-top-blocks.csv",
      "key_observation": "The five candidate representatives are the top five blocks for calculate_node_hashes, with self wall 4457.745ms, 3104.324ms, 2386.753ms, 1358.211ms, and 1169.588ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the hottest representative and verify calculate_node_hashes dominates finalize rather than an anchor.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0x06f1987a4a34a5f1ab301b9291700ffd6edfd9b555b357c30446c62621a8b547"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-06f198.csv",
      "key_observation": "Segment: Finalize wall 5053.211ms; descendant calculate_node_hashes wall 5032.916ms; inner_get_trie_ancestor_hashes_bytes wall 17.820ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the second representative and confirm the same finalize/seal shape.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0x35c1c0ee7fe2def3b6f3f8cebd733439ae71950d267185888467b629e4fd0bdb"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-35c1c0.csv",
      "key_observation": "Segment: Finalize wall 3518.175ms; descendant calculate_node_hashes wall 3476.476ms; inner_get_trie_ancestor_hashes_bytes wall 38.736ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the third representative and confirm the same finalize/seal shape.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0x9407bf9e1bbe701776f97ffcdf9f2d36f5f786d03b78c61d0af832a9d556e722"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-9407bf.csv",
      "key_observation": "Segment: Finalize wall 2688.394ms; descendant calculate_node_hashes wall 2664.332ms; inner_get_trie_ancestor_hashes_bytes wall 20.975ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the fourth representative and confirm the same finalize/seal shape.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0x615df05829a3d8184b3001020c2b9a969277d9a40c8556c167d150a2554e942c"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-615df0.csv",
      "key_observation": "Segment: Finalize wall 1549.222ms; descendant calculate_node_hashes wall 1524.160ms; inner_get_trie_ancestor_hashes_bytes wall 23.543ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the fifth representative and confirm the same finalize/seal shape.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0xa2ebb236804dcf78a43de7db54afea63c0ee145adde25b50c02e1c658fd08b7a"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-a2ebb2.csv",
      "key_observation": "Segment: Finalize wall 1344.289ms; descendant calculate_node_hashes wall 1324.119ms; inner_get_trie_ancestor_hashes_bytes wall 17.302ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    }
  ],
  "proposed_change": "Refactor TrieRAM::calculate_node_hashes into a deferred seal hasher that computes the same post-order hashes with an explicit work stack or per-node memo indexed by TrieRAM slot. While a node is borrowed, serialize the node consensus prefix and collect the minimal child descriptors needed for hashing, then drop the borrow before walking children; store computed hashes in a parallel Vec<Option<TrieHash>> or equivalent and write them back to TrieRAM once computed. This avoids cloning full TrieNodeType values and repeatedly scanning large pointer arrays during recursive seal, while preserving get_block_hash_caching for backptrs, write_node_hash semantics for Deferred mode, and the All-mode equality assertion against eager hashing.",
  "expected_improvement": {
    "tx_latency": 0.0,
    "tenure_throughput": 0.0,
    "commit_time": 8.0
  },
  "risk": "medium",
  "verification_plan": "Use existing MARF storage tests that compare deferred/immediate/all hash modes and merkle verification, especially stackslib/src/chainstate/stacks/index/test/storage.rs and stackslib/src/chainstate/stacks/index/test/marf.rs. Add focused tests for root hash equality across Immediate, Deferred, and All modes over Node4/16/48/256 backptr-heavy tries. Then run the targeted replay below and compare calculate_node_hashes plus block commit/finalize timing; no Clarity cost movement is expected.",
  "verification_replay": {
    "rationale": "Replay the five hottest finalize blocks to isolate deferred MARF seal hashing while keeping profiler detail for span-level verification.",
    "invocations": [
      {
        "id": "hot-finalize-blocks",
        "label": "hot finalize blocks",
        "purpose": "Measure whether the deferred seal hasher reduces commit/finalize time on blocks where calculate_node_hashes dominates.",
        "samples": {
          "kind": "blocks",
          "blocks": [
            "0x06f1987a4a34a5f1ab301b9291700ffd6edfd9b555b357c30446c62621a8b547",
            "0x35c1c0ee7fe2def3b6f3f8cebd733439ae71950d267185888467b629e4fd0bdb",
            "0x9407bf9e1bbe701776f97ffcdf9f2d36f5f786d03b78c61d0af832a9d556e722",
            "0x615df05829a3d8184b3001020c2b9a969277d9a40c8556c167d150a2554e942c",
            "0xa2ebb236804dcf78a43de7db54afea63c0ee145adde25b50c02e1c658fd08b7a"
          ]
        },
        "warmup": 0,
        "repetitions": 10,
        "profiler": "rich",
        "expected_signal": {
          "axis": "commit_time",
          "direction": "improves",
          "estimate_pct": 8.0,
          "tolerance_pct": 5.0
        }
      }
    ],
    "suspected_spans": [
      "calculate_node_hashes",
      "get_block_hash"
    ]
  },
  "merge_notes": "Singleton target retained; no true duplicate structural change was found.",
  "consensus_breaking": false,
  "delivery_mode": "normal_pr",
  "bench_eligible": true
}
```

- Final benchmark summary for this target:

```json
{
  "target_id": "marf-deferred-seal-postorder-hash-cache",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    12
  ],
  "baseline_run_ids": [
    9
  ],
  "improvement_pct": 1.004,
  "base_sha": "f4cab0a011e273e1f1f9b5249afee2fba6123da5",
  "head_sha": "58df008290aaf1c90b13ad768eb5f067cb944b0a",
  "reason": "mixed: The accepted mechanism signal is stronger than the macro commit-time signal: `calculate_node_hashes` exclusive wall improved 5.174%, but commit time improved only 1.004%.; `calculate_node_hashes` inclusive wall and call-count deltas are structurally affected by the recursive-to-iterative refactor, so exclusive wall is the fair span metric.; Commit-time movement is uneven across the five replayed block hashes, including a 2.806% regression on `a2ebb2...`."
}
```

- Phase 3.5 results-analyzer verdict for this target (the authoritative
  source for the `Benchmark result` section on `normal_pr`):

```json
{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "marf-deferred-seal-postorder-hash-cache",
  "axis": "commit_time",
  "verdict": "mixed",
  "confidence": "medium",
  "headline_rationale": "The deferred MARF seal hashing mechanism moved in the right direction, but measured commit time improved only 1.004%, below the 8% +/- 5% hypothesis window.",
  "headline_improvement_pct": 1.004,
  "per_invocation": [
    {
      "invocation_id": "hot-finalize-blocks",
      "label": "hot finalize blocks",
      "baseline_run_id": 9,
      "candidate_run_id": 12,
      "measured_pct": 1.004,
      "matches_expected_signal": false,
      "observations": [
        "Run envelopes were clean: baseline run 9 and candidate run 12 both succeeded, were not interrupted, processed 50 measured blocks and 210 transactions, and matched the run-id maps.",
        "Catalog block timing comparison showed commit_us_per_block moving from 108833.94us to 107741.78us, a 1.004% improvement; this is positive but below the expected 8% +/- 5% commit-time window.",
        "The run-level block_total_us comparison improved by 1.846%, from 63077316us to 61913162us.",
        "`calculate_node_hashes` moved in the expected direction on exclusive wall time: 1927177us baseline to 1827456us candidate, a 5.174% improvement. Calls dropped from 83094 to 100 after replacing recursive hashing with the explicit post-order pass.",
        "`calculate_node_hashes` inclusive wall time dropped by 66.967%, but that figure is not directly comparable because the implementation intentionally removes recursive nested span accounting; exclusive wall time is the better mechanism metric.",
        "`get_block_hash` also improved slightly, from 138910us to 134065us self wall, a 3.488% improvement, with calls increasing from 36980 to 37401.",
        "Grouped by replayed block hash, commit time improved 6.696% for 9407bf..., 1.430% for 06f198..., 0.458% for 615df0..., and 0.164% for 35c1c0..., but regressed 2.806% for a2ebb2....",
        "Top span-delta inspection did not show a new MARF-side regression absorbing the expected gain; the largest non-target movements were small broad Clarity/SQLite timing shifts consistent with replay variance."
      ]
    }
  ],
  "caveats": [
    "The accepted mechanism signal is stronger than the macro commit-time signal: `calculate_node_hashes` exclusive wall improved 5.174%, but commit time improved only 1.004%.",
    "`calculate_node_hashes` inclusive wall and call-count deltas are structurally affected by the recursive-to-iterative refactor, so exclusive wall is the fair span metric.",
    "Commit-time movement is uneven across the five replayed block hashes, including a 2.806% regression on `a2ebb2...`."
  ],
  "pr_body_summary": "Benchmark replay shows the refactor moved the intended MARF seal hashing path, but the end-to-end commit-time win is smaller than predicted. Across the hot finalize block replay, average commit time improved by 1.004% versus the expected 8% +/- 5%, while total block time improved by 1.846%. The `calculate_node_hashes` span improved by 5.174% in exclusive wall time and its recursive call count collapsed from 83,094 to 100, which supports the implementation mechanism. Per-block commit movement was mixed, ranging from a 6.696% gain on `9407bf...` to a 2.806% regression on `a2ebb2...`, so this should ship only with the caveat that the macro commit-time gain is modest.",
  "db_queries": [
    {
      "purpose": "Envelope sanity comparison for baseline run 9 and candidate run 12.",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513.csv"
    },
    {
      "purpose": "Paired span comparison for calculate_node_hashes, the analyzer's primary suspected mechanism span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-calculate_node_hashes.csv"
    },
    {
      "purpose": "Paired span comparison for get_block_hash, the analyzer's secondary suspected span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-get_block_hash.csv"
    },
    {
      "purpose": "Paired block timing comparison for the commit_time expected signal.",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c.csv"
    },
    {
      "purpose": "Per-block paired timing dump to inspect variance and outliers behind the small aggregate commit gain.",
      "query_digest": "f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e",
      "rows_returned": 50,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e.csv"
    },
    {
      "purpose": "Top span movement comparison to check whether sibling spans absorbed the expected commit-time gain.",
      "query_digest": "7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc",
      "rows_returned": 40,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc.csv"
    },
    {
      "purpose": "Grouped timing summary by replayed block hash to compare representative block shape.",
      "query_digest": "3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6.csv"
    }
  ]
}
```

  Important: when `normal_pr` is `normal_pr` and
  `{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "marf-deferred-seal-postorder-hash-cache",
  "axis": "commit_time",
  "verdict": "mixed",
  "confidence": "medium",
  "headline_rationale": "The deferred MARF seal hashing mechanism moved in the right direction, but measured commit time improved only 1.004%, below the 8% +/- 5% hypothesis window.",
  "headline_improvement_pct": 1.004,
  "per_invocation": [
    {
      "invocation_id": "hot-finalize-blocks",
      "label": "hot finalize blocks",
      "baseline_run_id": 9,
      "candidate_run_id": 12,
      "measured_pct": 1.004,
      "matches_expected_signal": false,
      "observations": [
        "Run envelopes were clean: baseline run 9 and candidate run 12 both succeeded, were not interrupted, processed 50 measured blocks and 210 transactions, and matched the run-id maps.",
        "Catalog block timing comparison showed commit_us_per_block moving from 108833.94us to 107741.78us, a 1.004% improvement; this is positive but below the expected 8% +/- 5% commit-time window.",
        "The run-level block_total_us comparison improved by 1.846%, from 63077316us to 61913162us.",
        "`calculate_node_hashes` moved in the expected direction on exclusive wall time: 1927177us baseline to 1827456us candidate, a 5.174% improvement. Calls dropped from 83094 to 100 after replacing recursive hashing with the explicit post-order pass.",
        "`calculate_node_hashes` inclusive wall time dropped by 66.967%, but that figure is not directly comparable because the implementation intentionally removes recursive nested span accounting; exclusive wall time is the better mechanism metric.",
        "`get_block_hash` also improved slightly, from 138910us to 134065us self wall, a 3.488% improvement, with calls increasing from 36980 to 37401.",
        "Grouped by replayed block hash, commit time improved 6.696% for 9407bf..., 1.430% for 06f198..., 0.458% for 615df0..., and 0.164% for 35c1c0..., but regressed 2.806% for a2ebb2....",
        "Top span-delta inspection did not show a new MARF-side regression absorbing the expected gain; the largest non-target movements were small broad Clarity/SQLite timing shifts consistent with replay variance."
      ]
    }
  ],
  "caveats": [
    "The accepted mechanism signal is stronger than the macro commit-time signal: `calculate_node_hashes` exclusive wall improved 5.174%, but commit time improved only 1.004%.",
    "`calculate_node_hashes` inclusive wall and call-count deltas are structurally affected by the recursive-to-iterative refactor, so exclusive wall is the fair span metric.",
    "Commit-time movement is uneven across the five replayed block hashes, including a 2.806% regression on `a2ebb2...`."
  ],
  "pr_body_summary": "Benchmark replay shows the refactor moved the intended MARF seal hashing path, but the end-to-end commit-time win is smaller than predicted. Across the hot finalize block replay, average commit time improved by 1.004% versus the expected 8% +/- 5%, while total block time improved by 1.846%. The `calculate_node_hashes` span improved by 5.174% in exclusive wall time and its recursive call count collapsed from 83,094 to 100, which supports the implementation mechanism. Per-block commit movement was mixed, ranging from a 6.696% gain on `9407bf...` to a 2.806% regression on `a2ebb2...`, so this should ship only with the caveat that the macro commit-time gain is modest.",
  "db_queries": [
    {
      "purpose": "Envelope sanity comparison for baseline run 9 and candidate run 12.",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513.csv"
    },
    {
      "purpose": "Paired span comparison for calculate_node_hashes, the analyzer's primary suspected mechanism span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-calculate_node_hashes.csv"
    },
    {
      "purpose": "Paired span comparison for get_block_hash, the analyzer's secondary suspected span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-get_block_hash.csv"
    },
    {
      "purpose": "Paired block timing comparison for the commit_time expected signal.",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c.csv"
    },
    {
      "purpose": "Per-block paired timing dump to inspect variance and outliers behind the small aggregate commit gain.",
      "query_digest": "f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e",
      "rows_returned": 50,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e.csv"
    },
    {
      "purpose": "Top span movement comparison to check whether sibling spans absorbed the expected commit-time gain.",
      "query_digest": "7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc",
      "rows_returned": 40,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc.csv"
    },
    {
      "purpose": "Grouped timing summary by replayed block hash to compare representative block shape.",
      "query_digest": "3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6.csv"
    }
  ]
}` is non-empty, use its `pr_body_summary`
  verbatim as the body of `## Benchmark result`. The `verdict` +
  `confidence` lattice, the per-invocation breakdown, and the
  `caveats[]` array are operator-facing context. Do NOT re-synthesize
  numbers from `improvement_pct` alone — the verdict already explains
  why the number means what it means.

- Implementation notes are in `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/implementation.md`
- Test output (truncate as needed) lives in `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/nextest.log` and `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/nextest.stderr.log`. Cite specific numbers from these files in the `Validation` section rather than paraphrasing.
- Build log (for any flag/version-related notes) is at `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/cargo-build.log`.

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
- For `normal_pr`: in `Benchmark result`, paste `pr_body_summary` from
  `{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "marf-deferred-seal-postorder-hash-cache",
  "axis": "commit_time",
  "verdict": "mixed",
  "confidence": "medium",
  "headline_rationale": "The deferred MARF seal hashing mechanism moved in the right direction, but measured commit time improved only 1.004%, below the 8% +/- 5% hypothesis window.",
  "headline_improvement_pct": 1.004,
  "per_invocation": [
    {
      "invocation_id": "hot-finalize-blocks",
      "label": "hot finalize blocks",
      "baseline_run_id": 9,
      "candidate_run_id": 12,
      "measured_pct": 1.004,
      "matches_expected_signal": false,
      "observations": [
        "Run envelopes were clean: baseline run 9 and candidate run 12 both succeeded, were not interrupted, processed 50 measured blocks and 210 transactions, and matched the run-id maps.",
        "Catalog block timing comparison showed commit_us_per_block moving from 108833.94us to 107741.78us, a 1.004% improvement; this is positive but below the expected 8% +/- 5% commit-time window.",
        "The run-level block_total_us comparison improved by 1.846%, from 63077316us to 61913162us.",
        "`calculate_node_hashes` moved in the expected direction on exclusive wall time: 1927177us baseline to 1827456us candidate, a 5.174% improvement. Calls dropped from 83094 to 100 after replacing recursive hashing with the explicit post-order pass.",
        "`calculate_node_hashes` inclusive wall time dropped by 66.967%, but that figure is not directly comparable because the implementation intentionally removes recursive nested span accounting; exclusive wall time is the better mechanism metric.",
        "`get_block_hash` also improved slightly, from 138910us to 134065us self wall, a 3.488% improvement, with calls increasing from 36980 to 37401.",
        "Grouped by replayed block hash, commit time improved 6.696% for 9407bf..., 1.430% for 06f198..., 0.458% for 615df0..., and 0.164% for 35c1c0..., but regressed 2.806% for a2ebb2....",
        "Top span-delta inspection did not show a new MARF-side regression absorbing the expected gain; the largest non-target movements were small broad Clarity/SQLite timing shifts consistent with replay variance."
      ]
    }
  ],
  "caveats": [
    "The accepted mechanism signal is stronger than the macro commit-time signal: `calculate_node_hashes` exclusive wall improved 5.174%, but commit time improved only 1.004%.",
    "`calculate_node_hashes` inclusive wall and call-count deltas are structurally affected by the recursive-to-iterative refactor, so exclusive wall is the fair span metric.",
    "Commit-time movement is uneven across the five replayed block hashes, including a 2.806% regression on `a2ebb2...`."
  ],
  "pr_body_summary": "Benchmark replay shows the refactor moved the intended MARF seal hashing path, but the end-to-end commit-time win is smaller than predicted. Across the hot finalize block replay, average commit time improved by 1.004% versus the expected 8% +/- 5%, while total block time improved by 1.846%. The `calculate_node_hashes` span improved by 5.174% in exclusive wall time and its recursive call count collapsed from 83,094 to 100, which supports the implementation mechanism. Per-block commit movement was mixed, ranging from a 6.696% gain on `9407bf...` to a 2.806% regression on `a2ebb2...`, so this should ship only with the caveat that the macro commit-time gain is modest.",
  "db_queries": [
    {
      "purpose": "Envelope sanity comparison for baseline run 9 and candidate run 12.",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513.csv"
    },
    {
      "purpose": "Paired span comparison for calculate_node_hashes, the analyzer's primary suspected mechanism span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-calculate_node_hashes.csv"
    },
    {
      "purpose": "Paired span comparison for get_block_hash, the analyzer's secondary suspected span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-get_block_hash.csv"
    },
    {
      "purpose": "Paired block timing comparison for the commit_time expected signal.",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c.csv"
    },
    {
      "purpose": "Per-block paired timing dump to inspect variance and outliers behind the small aggregate commit gain.",
      "query_digest": "f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e",
      "rows_returned": 50,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e.csv"
    },
    {
      "purpose": "Top span movement comparison to check whether sibling spans absorbed the expected commit-time gain.",
      "query_digest": "7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc",
      "rows_returned": 40,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc.csv"
    },
    {
      "purpose": "Grouped timing summary by replayed block hash to compare representative block shape.",
      "query_digest": "3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6.csv"
    }
  ]
}` verbatim — that prose is the canonical
  Result section the results-analyzer agent committed to (it reads
  per-invocation traces; you do not). Append the per-invocation table
  from the verdict's `per_invocation[]` (label, baseline run id,
  candidate run id, measured %, matches_expected_signal) for the
  reviewer. If the verdict carries non-empty `caveats[]`, list them
  as a bullet group under a `**Caveats.**` line at the end of the
  section. In `Validation`, summarize tests/verification from
  `implementation.md` without inventing anything.
- If `{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "marf-deferred-seal-postorder-hash-cache",
  "axis": "commit_time",
  "verdict": "mixed",
  "confidence": "medium",
  "headline_rationale": "The deferred MARF seal hashing mechanism moved in the right direction, but measured commit time improved only 1.004%, below the 8% +/- 5% hypothesis window.",
  "headline_improvement_pct": 1.004,
  "per_invocation": [
    {
      "invocation_id": "hot-finalize-blocks",
      "label": "hot finalize blocks",
      "baseline_run_id": 9,
      "candidate_run_id": 12,
      "measured_pct": 1.004,
      "matches_expected_signal": false,
      "observations": [
        "Run envelopes were clean: baseline run 9 and candidate run 12 both succeeded, were not interrupted, processed 50 measured blocks and 210 transactions, and matched the run-id maps.",
        "Catalog block timing comparison showed commit_us_per_block moving from 108833.94us to 107741.78us, a 1.004% improvement; this is positive but below the expected 8% +/- 5% commit-time window.",
        "The run-level block_total_us comparison improved by 1.846%, from 63077316us to 61913162us.",
        "`calculate_node_hashes` moved in the expected direction on exclusive wall time: 1927177us baseline to 1827456us candidate, a 5.174% improvement. Calls dropped from 83094 to 100 after replacing recursive hashing with the explicit post-order pass.",
        "`calculate_node_hashes` inclusive wall time dropped by 66.967%, but that figure is not directly comparable because the implementation intentionally removes recursive nested span accounting; exclusive wall time is the better mechanism metric.",
        "`get_block_hash` also improved slightly, from 138910us to 134065us self wall, a 3.488% improvement, with calls increasing from 36980 to 37401.",
        "Grouped by replayed block hash, commit time improved 6.696% for 9407bf..., 1.430% for 06f198..., 0.458% for 615df0..., and 0.164% for 35c1c0..., but regressed 2.806% for a2ebb2....",
        "Top span-delta inspection did not show a new MARF-side regression absorbing the expected gain; the largest non-target movements were small broad Clarity/SQLite timing shifts consistent with replay variance."
      ]
    }
  ],
  "caveats": [
    "The accepted mechanism signal is stronger than the macro commit-time signal: `calculate_node_hashes` exclusive wall improved 5.174%, but commit time improved only 1.004%.",
    "`calculate_node_hashes` inclusive wall and call-count deltas are structurally affected by the recursive-to-iterative refactor, so exclusive wall is the fair span metric.",
    "Commit-time movement is uneven across the five replayed block hashes, including a 2.806% regression on `a2ebb2...`."
  ],
  "pr_body_summary": "Benchmark replay shows the refactor moved the intended MARF seal hashing path, but the end-to-end commit-time win is smaller than predicted. Across the hot finalize block replay, average commit time improved by 1.004% versus the expected 8% +/- 5%, while total block time improved by 1.846%. The `calculate_node_hashes` span improved by 5.174% in exclusive wall time and its recursive call count collapsed from 83,094 to 100, which supports the implementation mechanism. Per-block commit movement was mixed, ranging from a 6.696% gain on `9407bf...` to a 2.806% regression on `a2ebb2...`, so this should ship only with the caveat that the macro commit-time gain is modest.",
  "db_queries": [
    {
      "purpose": "Envelope sanity comparison for baseline run 9 and candidate run 12.",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513.csv"
    },
    {
      "purpose": "Paired span comparison for calculate_node_hashes, the analyzer's primary suspected mechanism span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-calculate_node_hashes.csv"
    },
    {
      "purpose": "Paired span comparison for get_block_hash, the analyzer's secondary suspected span.",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-get_block_hash.csv"
    },
    {
      "purpose": "Paired block timing comparison for the commit_time expected signal.",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c.csv"
    },
    {
      "purpose": "Per-block paired timing dump to inspect variance and outliers behind the small aggregate commit gain.",
      "query_digest": "f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e",
      "rows_returned": 50,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/f8ff62a8244b70790acdcbba3db4ef5ea9adb5f1dd0ca6d1976941087637fc9e.csv"
    },
    {
      "purpose": "Top span movement comparison to check whether sibling spans absorbed the expected commit-time gain.",
      "query_digest": "7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc",
      "rows_returned": 40,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/7b8fe52fe3c76ff3f2f431ac73d1fc0f33fa6485f5d0114538d97b33251407dc.csv"
    },
    {
      "purpose": "Grouped timing summary by replayed block hash to compare representative block shape.",
      "query_digest": "3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6",
      "rows_returned": 5,
      "output_path": "analyze/marf-deferred-seal-postorder-hash-cache/queries/3e58e8cfbfbab50cd6c20447fa3618b0914dc1d7fef5a69cc2ea66de83253ca6.csv"
    }
  ]
}` is `{}` (no verdict was produced
  for this `normal_pr` target — typically because Phase 3.5 was
  skipped or the agent failed) you MUST NOT publish a PR. Surface
  this gap as a `## Benchmark result` paragraph that says
  "Results-analyzer did not produce a verdict for this target; the
  measured `improvement_pct` from `{
  "target_id": "marf-deferred-seal-postorder-hash-cache",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    12
  ],
  "baseline_run_ids": [
    9
  ],
  "improvement_pct": 1.004,
  "base_sha": "f4cab0a011e273e1f1f9b5249afee2fba6123da5",
  "head_sha": "58df008290aaf1c90b13ad768eb5f067cb944b0a",
  "reason": "mixed: The accepted mechanism signal is stronger than the macro commit-time signal: `calculate_node_hashes` exclusive wall improved 5.174%, but commit time improved only 1.004%.; `calculate_node_hashes` inclusive wall and call-count deltas are structurally affected by the recursive-to-iterative refactor, so exclusive wall is the fair span metric.; Commit-time movement is uneven across the five replayed block hashes, including a 2.806% regression on `a2ebb2...`."
}` has not
  been judged against the analyzer's `expected_signal`. Hold for
  operator review." Operator review will decide whether to re-run
  Phase 3.5 or ship without a verdict.
- For `consensus_poc_pr`: `{
  "target_id": "marf-deferred-seal-postorder-hash-cache",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    12
  ],
  "baseline_run_ids": [
    9
  ],
  "improvement_pct": 1.004,
  "base_sha": "f4cab0a011e273e1f1f9b5249afee2fba6123da5",
  "head_sha": "58df008290aaf1c90b13ad768eb5f067cb944b0a",
  "reason": "mixed: The accepted mechanism signal is stronger than the macro commit-time signal: `calculate_node_hashes` exclusive wall improved 5.174%, but commit time improved only 1.004%.; `calculate_node_hashes` inclusive wall and call-count deltas are structurally affected by the recursive-to-iterative refactor, so exclusive wall is the fair span metric.; Commit-time movement is uneven across the five replayed block hashes, including a 2.806% regression on `a2ebb2...`."
}` is `{}` (no benchmark ran). Do NOT invent improvement numbers. State explicitly that the benchmark was skipped by design (the harness encodes pre-change consensus). Cite the analyzer's `expected_improvement` vector from `{
  "id": "marf-deferred-seal-postorder-hash-cache",
  "merged_from": [
    {
      "family_id": "marf-trie-seal-hash-recalculation",
      "target_index": 0
    }
  ],
  "convergence_count": 1,
  "target_span": "calculate_node_hashes",
  "bucket": "block_commit",
  "hotspot": {
    "span": "calculate_node_hashes",
    "self_wall_us": 381328360,
    "total_wall_us": 1272836450,
    "calls": 2132356,
    "location": "stackslib/src/chainstate/stacks/index/storage.rs:818"
  },
  "files": [
    "stackslib/src/chainstate/stacks/index/storage.rs",
    "stackslib/src/chainstate/stacks/index/node.rs",
    "stackslib/src/chainstate/stacks/index/cache.rs",
    "stackslib/src/chainstate/stacks/index/test/storage.rs",
    "stackslib/src/chainstate/stacks/index/test/marf.rs"
  ],
  "evidence": "Run 6 ranks TrieRAM::calculate_node_hashes as the #2 exclusive span: 381.328s self wall, 1,272.836s inclusive wall, 2,132,356 calls, 100% block recurrence, and no transaction association. The per-block distribution is broad rather than a single spike: 15,000/15,000 blocks, p50 18.794ms, p95 58.877ms, p99 118.061ms, top3 share 2.6%. All five representatives are the top five blocks for this span. In each trace, calculate_node_hashes sits under Segment: Finalize (merkle+seal) and dominates the finalize subtree: 5,032.9ms of 5,053.2ms for 0x06f198..., 3,476.5ms of 3,518.2ms for 0x35c1c0..., 2,664.3ms of 2,688.4ms for 0x9407bf..., 1,524.2ms of 1,549.2ms for 0x615df0..., and 1,324.1ms of 1,344.3ms for 0xa2ebb2.... The suspected inner_get_trie_ancestor_hashes_bytes path is present but much smaller in these traces, topping out at 38.736ms, so it is not the primary handle. Code in TrieRAM::inner_seal_marf calls calculate_node_hashes only in Deferred/All mode; calculate_node_hashes clones each node with get_nodetype(...).to_owned(), serializes node consensus bytes, scans ptrs, recursively hashes same-block children, looks up ancestor block hashes via the existing get_block_hash_caching cache, and writes deferred hashes back. Existing code already caches block-id to block-hash lookups, so the actionable work is reducing the deferred seal walk's clone/recursion/pointer traversal overhead while preserving the identical hash byte stream.",
  "evidence_queries": [
    {
      "purpose": "Rank run-level hotspot and capture self/inclusive wall time for the target span.",
      "sql_path": "queries/top_spans_by_self_wall.sql",
      "params": {
        "limit": "80",
        "run_id": "6"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/top-spans-self-wall.csv",
      "key_observation": "calculate_node_hashes: 381328.36ms self wall, 1272836.45ms inclusive wall, 2132356 calls, avg self 178.83us/call.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Confirm the span is block-level commit work recurring across the whole sampled workload.",
      "sql_path": "queries/span_recurrence.sql",
      "params": {
        "run_id": "6"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/span-recurrence.csv",
      "key_observation": "calculate_node_hashes appears in 15000/15000 blocks (100.0%) and 0 transactions.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Show the signal is broad and not top-block dominated.",
      "sql_path": "queries/span_per_block_distribution.sql",
      "params": {
        "run_id": "6",
        "span_id": "84"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/calculate-node-hashes-block-distribution.csv",
      "key_observation": "15000 blocks, p50 18.794ms, p95 58.877ms, p99 118.061ms, top3 share 2.6%.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Identify stable replay block hashes for the hottest representatives.",
      "sql_path": "queries/top_blocks_for_span.sql",
      "params": {
        "limit": "20",
        "run_id": "6",
        "span_id": "84"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/calculate-node-hashes-top-blocks.csv",
      "key_observation": "The five candidate representatives are the top five blocks for calculate_node_hashes, with self wall 4457.745ms, 3104.324ms, 2386.753ms, 1358.211ms, and 1169.588ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the hottest representative and verify calculate_node_hashes dominates finalize rather than an anchor.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0x06f1987a4a34a5f1ab301b9291700ffd6edfd9b555b357c30446c62621a8b547"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-06f198.csv",
      "key_observation": "Segment: Finalize wall 5053.211ms; descendant calculate_node_hashes wall 5032.916ms; inner_get_trie_ancestor_hashes_bytes wall 17.820ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the second representative and confirm the same finalize/seal shape.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0x35c1c0ee7fe2def3b6f3f8cebd733439ae71950d267185888467b629e4fd0bdb"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-35c1c0.csv",
      "key_observation": "Segment: Finalize wall 3518.175ms; descendant calculate_node_hashes wall 3476.476ms; inner_get_trie_ancestor_hashes_bytes wall 38.736ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the third representative and confirm the same finalize/seal shape.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0x9407bf9e1bbe701776f97ffcdf9f2d36f5f786d03b78c61d0af832a9d556e722"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-9407bf.csv",
      "key_observation": "Segment: Finalize wall 2688.394ms; descendant calculate_node_hashes wall 2664.332ms; inner_get_trie_ancestor_hashes_bytes wall 20.975ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the fourth representative and confirm the same finalize/seal shape.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0x615df05829a3d8184b3001020c2b9a969277d9a40c8556c167d150a2554e942c"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-615df0.csv",
      "key_observation": "Segment: Finalize wall 1549.222ms; descendant calculate_node_hashes wall 1524.160ms; inner_get_trie_ancestor_hashes_bytes wall 23.543ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    },
    {
      "purpose": "Trace the fifth representative and confirm the same finalize/seal shape.",
      "sql_path": "queries/profiler_trace_block.sql",
      "params": {
        "max_rows": "1200",
        "min_wall_ms": "2",
        "run_id": "6",
        "stacks_block_hash": "0xa2ebb236804dcf78a43de7db54afea63c0ee145adde25b50c02e1c658fd08b7a"
      },
      "output_path": "analysis/marf-trie-seal-hash-recalculation/queries/trace-block-a2ebb2.csv",
      "key_observation": "Segment: Finalize wall 1344.289ms; descendant calculate_node_hashes wall 1324.119ms; inner_get_trie_ancestor_hashes_bytes wall 17.302ms.",
      "supports_invocations": [
        "hot-finalize-blocks"
      ]
    }
  ],
  "proposed_change": "Refactor TrieRAM::calculate_node_hashes into a deferred seal hasher that computes the same post-order hashes with an explicit work stack or per-node memo indexed by TrieRAM slot. While a node is borrowed, serialize the node consensus prefix and collect the minimal child descriptors needed for hashing, then drop the borrow before walking children; store computed hashes in a parallel Vec<Option<TrieHash>> or equivalent and write them back to TrieRAM once computed. This avoids cloning full TrieNodeType values and repeatedly scanning large pointer arrays during recursive seal, while preserving get_block_hash_caching for backptrs, write_node_hash semantics for Deferred mode, and the All-mode equality assertion against eager hashing.",
  "expected_improvement": {
    "tx_latency": 0.0,
    "tenure_throughput": 0.0,
    "commit_time": 8.0
  },
  "risk": "medium",
  "verification_plan": "Use existing MARF storage tests that compare deferred/immediate/all hash modes and merkle verification, especially stackslib/src/chainstate/stacks/index/test/storage.rs and stackslib/src/chainstate/stacks/index/test/marf.rs. Add focused tests for root hash equality across Immediate, Deferred, and All modes over Node4/16/48/256 backptr-heavy tries. Then run the targeted replay below and compare calculate_node_hashes plus block commit/finalize timing; no Clarity cost movement is expected.",
  "verification_replay": {
    "rationale": "Replay the five hottest finalize blocks to isolate deferred MARF seal hashing while keeping profiler detail for span-level verification.",
    "invocations": [
      {
        "id": "hot-finalize-blocks",
        "label": "hot finalize blocks",
        "purpose": "Measure whether the deferred seal hasher reduces commit/finalize time on blocks where calculate_node_hashes dominates.",
        "samples": {
          "kind": "blocks",
          "blocks": [
            "0x06f1987a4a34a5f1ab301b9291700ffd6edfd9b555b357c30446c62621a8b547",
            "0x35c1c0ee7fe2def3b6f3f8cebd733439ae71950d267185888467b629e4fd0bdb",
            "0x9407bf9e1bbe701776f97ffcdf9f2d36f5f786d03b78c61d0af832a9d556e722",
            "0x615df05829a3d8184b3001020c2b9a969277d9a40c8556c167d150a2554e942c",
            "0xa2ebb236804dcf78a43de7db54afea63c0ee145adde25b50c02e1c658fd08b7a"
          ]
        },
        "warmup": 0,
        "repetitions": 10,
        "profiler": "rich",
        "expected_signal": {
          "axis": "commit_time",
          "direction": "improves",
          "estimate_pct": 8.0,
          "tolerance_pct": 5.0
        }
      }
    ],
    "suspected_spans": [
      "calculate_node_hashes",
      "get_block_hash"
    ]
  },
  "merge_notes": "Singleton target retained; no true duplicate structural change was found.",
  "consensus_breaking": false,
  "delivery_mode": "normal_pr",
  "bench_eligible": true
}` only as an analyzer estimate.
- Mention risk briefly if it is present in the target JSON.

# Output format

- `pr-title.txt` should contain exactly one plain-text line.
- `pr-body.md` should be valid markdown with the sections above.

Do not edit source code. Do not stage, commit, push, or publish anything.
