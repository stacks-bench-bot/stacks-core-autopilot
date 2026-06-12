You are preparing a GitHub pull request for an autonomous optimization run on `stacks-core`. There are two PR shapes you may be asked to write — see "Delivery mode" below — and the expected framing differs significantly between them.

# Goal

Write concise, factual PR artifacts for this target:

- `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/clarity-side-store-bulk-put/pr-title.txt` — a single-line PR title
- `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/clarity-side-store-bulk-put/pr-body.md` — a markdown PR body

Do NOT create the PR yourself. Do NOT use GitHub tools. Only write the two files above.

# Delivery mode

Your delivery mode for this target is `normal_pr`. Two PR shapes:

- **`normal_pr`** — a standard performance optimization. The optimizer ran the full nextest suite; the Phase 3.5 results-analyzer judged measured vs the analyzer's `expected_signal` per invocation and committed an `accepted` or `mixed` verdict with `confidence >= results_analysis.confidence_floor`. The verdict's `pr_body_summary` is the canonical Result-section prose (read it verbatim from `{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "clarity-side-store-bulk-put",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "high",
  "headline_rationale": "The write-heavy replay improved tx execution latency by 4.18%, within the expected 5% +/- 4% band, and the SQLite side-store write spans moved in the predicted direction.",
  "headline_improvement_pct": 4.184,
  "per_invocation": [
    {
      "invocation_id": "write-heavy-txs",
      "label": "write-heavy txs",
      "baseline_run_id": 7,
      "candidate_run_id": 10,
      "measured_pct": 4.184,
      "matches_expected_signal": true,
      "observations": [
        "Both bench-run envelopes succeeded, were not interrupted, and matched the recorded run ids: baseline 7 and candidate 10.",
        "DB block timing shows execution_us_per_block improved from 1323303.175 us to 1267941.063 us, a 4.184% tx-latency improvement; total_us_per_block improved 3.544%.",
        "All four replayed tx hashes improved on stacks_tx_stats.duration_us averages: 37ad67a3 +4.842%, 408f81be +5.184%, 92639041 +3.286%, and 9f0416be +3.507%.",
        "The exact old SqliteConnection::put span is absent in the candidate, while the replacement SqliteConnection::put_many span accounts for 2940091 us across 240 batch calls versus baseline put at 3139064 us across 118300 per-item calls.",
        "PersistentWritableMarfStore::put_all_data total wall improved from 5109628 us to 4756109 us, a 6.919% reduction with the same 240 parent calls."
      ]
    }
  ],
  "caveats": [
    "Commit_us_per_block regressed by 3.619%, partially offsetting the execution gain at the whole-block level; total_us_per_block still improved by 3.544%.",
    "SqliteConnection::put_many remains a top candidate span at 2940091 us self wall, so batching reduced dispatch/prepare overhead but did not eliminate SQLite write cost."
  ],
  "pr_body_summary": "The write-heavy transaction replay moved in the expected direction: tx execution latency improved by 4.18%, within the analyzer's 5% +/- 4% expectation, and total block time improved by 3.54%. The profiler evidence matches the proposed mechanism: the old per-item `SqliteConnection::put` calls disappeared, the new `put_many` batch path handled the side-store writes, and `PersistentWritableMarfStore::put_all_data` total wall time fell by 6.92%. All four replayed tx hashes improved on average duration, with per-sample gains between 3.29% and 5.18%. Commit timing regressed by 3.62% per block, so the total-block improvement is smaller than the execution-latency gain, but it does not contradict the tx-latency mechanism.",
  "db_queries": [
    {
      "purpose": "compare_run_summary envelope sanity",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare_block_timing tx latency context",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare span put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-0990b192238d.csv"
    },
    {
      "purpose": "compare span put_all_data parent movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-277ef1175b32.csv"
    },
    {
      "purpose": "compare span SqliteConnection::put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-444a5cfe565a.csv"
    },
    {
      "purpose": "compare span PersistentWritableMarfStore::put_all_data movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-af612d0f59d6.csv"
    },
    {
      "purpose": "side-store put span family including new put_many",
      "query_digest": "a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e",
      "rows_returned": 10,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e-e42255c1d3ce.csv"
    },
    {
      "purpose": "top candidate spans by self wall for compensation check",
      "query_digest": "d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523",
      "rows_returned": 25,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523-e42255c1d3ce.csv"
    },
    {
      "purpose": "per tx hash duration comparison for write-heavy samples",
      "query_digest": "334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c",
      "rows_returned": 4,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c-e42255c1d3ce.csv"
    },
    {
      "purpose": "put_all_data per-block distribution comparison",
      "query_digest": "e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13",
      "rows_returned": 2,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13-e42255c1d3ce.csv"
    }
  ]
}`). The PR is a regular draft (or non-draft per operator preference) seeking review and merge in the usual way.

- **`consensus_poc_pr`** — a deliberate consensus-breaking change shipped as a PoC. The optimizer ran nextest filtered to `poc_test_scope` ONLY; the full suite is not the acceptance gate and may encode old consensus expectations that the change deliberately invalidates. **No benchmark ran** — the bench harness encodes pre-change consensus rules and would either crash or produce meaningless numbers. The PR is ALWAYS a draft and the publisher applies safety labels (`consensus-change`, `needs-HIP`, `do-not-merge`) to prevent accidental merging. The PR is the entry point for HIP-style discussion of the consensus change.

If `normal_pr` is `consensus_poc_pr`, the framing in your PR body MUST make the consensus nature obvious:

- Title: prefer `consensus(PoC): <specific change summary>` or `perf(consensus PoC): <…>` so the consensus nature shows up at a glance.
- `## Summary`: state explicitly that this is a consensus-breaking PoC and that the change requires HIP-style coordination before merge.
- `## What changed`: same content, no special framing needed.
- `## Benchmark result`: the bench was SKIPPED BY DESIGN. State this explicitly. Do not invent improvement numbers. Cite the analyzer's `expected_improvement` vector from the target JSON if useful, but make clear it's an analyzer estimate, not a measured result.
- `## Validation`: the scoped nextest run is the acceptance gate. Cite the scoped tests that passed (from `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/clarity-side-store-bulk-put/nextest.log`) and the breakage_class. Note explicitly that the full suite was NOT the gate and that some non-scoped tests may encode pre-change consensus expectations the fix invalidates. Do NOT claim full-suite passage.
- Add a final `## Consensus / HIP coordination` section pulling from the target's `consensus_writeup` field — what the rule change is, who pays for it, what HIP discussion would be required.

# Inputs

- Session id: `20260611-172955`
- Target id: `clarity-side-store-bulk-put`
- Output directory: `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/clarity-side-store-bulk-put`
- Worktree directory: `/private/tmp/sbagent-workspaces/optimizers/20260611-172955/clarity-side-store-bulk-put`
- Accepted target JSON:

```json
{
  "id": "clarity-side-store-bulk-put",
  "merged_from": [
    {
      "family_id": "dlmm-add-liquidity-multi-throughput",
      "target_index": 0
    }
  ],
  "convergence_count": 1,
  "target_span": "put",
  "bucket": "block_processing",
  "hotspot": {
    "span": "put",
    "self_wall_us": 297586640,
    "total_wall_us": 297586640,
    "calls": 1038880,
    "location": "clarity/src/vm/database/sqlite.rs:133"
  },
  "files": [
    "clarity/src/vm/database/sqlite.rs",
    "stackslib/src/clarity_vm/database/marf.rs",
    "clarity/src/vm/database/key_value_wrapper.rs",
    "clarity/src/vm/database/clarity_store.rs"
  ],
  "evidence": "Representative traces 37ad67a3, 408f81be, 92639041, and 9f0416be all run under Transaction -> try_mine_tx_with_len -> PersistentWritableMarfStore::put_all_data after VM execution. That span loops over 1401-1502 staged edits and spends 515-770 ms almost entirely in SqliteConnection::put. The code path is RollbackWrapper::commit collecting bottom-level edits, calling ClarityBackingStore::put_all_data, then PersistentWritableMarfStore::put_all_data converting each value to a MARFValue and invoking SqliteConnection::put once per item before MARF::insert_batch. SqliteConnection::put is a single REPLACE INTO data_table statement via conn.execute, so this target is storage mechanics, not Clarity cost accounting. The fifth representative, 74a98eed, was inspected and is instead dominated by MARF Trie::walk_backptr inside VM reads; it does not invalidate the put target but should not be used as the primary replay sample for it.",
  "evidence_queries": [
    {
      "purpose": "Rank the storage write span in the full baseline run.",
      "sql_path": "queries/top_spans_by_self_wall.sql",
      "params": {
        "limit": "100",
        "run_id": "6"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/top-spans-by-self-wall.csv",
      "key_observation": "SqliteConnection::put is span_id 60 with 297586.64 ms self wall across 1038880 calls; avg self is 286.449 us/call.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Confirm add-liquidity-multi is the promoted throughput family and identify the near-binding axis.",
      "sql_path": "queries/top_clarity_consumers_by_contract.sql",
      "params": {
        "limit": "25",
        "run_id": "6"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/top-clarity-consumers.csv",
      "key_observation": "add-liquidity-multi has 592 calls and consumes 45.44% of run write_count, 44.09% write_length, 37.92% read_length, 35.68% read_count, and 29.86% runtime.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "List concrete add-liquidity-multi transactions and their Clarity write volume.",
      "sql_path": "queries/txs_for_contract.sql",
      "params": {
        "contract_name": "dlmm-liquidity-router-v-1-2",
        "function_name": "add-liquidity-multi",
        "issuer_address": "SM1FKXGNZJWSTWDWXQZJNF7B5TV5ZB235JTCXYXKD",
        "limit": "100",
        "run_id": "6"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/txs-add-liquidity-multi.csv",
      "key_observation": "The top five representatives run for 1937-2243 ms and carry 1399-1650 Clarity write_count each.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Inspect representative 37ad67a3 and isolate post-VM side-store writes.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "37ad67a35e440ee7bb3f35620c3ccb26937103eb446b6a15f9b7814fedef9637"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/trace-37ad67a3.csv",
      "key_observation": "put_all_data is 565.408 ms; child SqliteConnection::put is 539.374 ms self across 1502 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Inspect representative 408f81be and isolate post-VM side-store writes.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "408f81be04c3bbf1cf0593233fa75334536c68251e851153322db976d3085898"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/trace-408f81be.csv",
      "key_observation": "put_all_data is 540.743 ms; child SqliteConnection::put is 515.217 ms self across 1502 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Inspect representative 92639041 and isolate post-VM side-store writes.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "9263904171da1a1a3d3b7e538b12b7c8984d0aa221a6588567f933ffa6a995e7"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/trace-92639041.csv",
      "key_observation": "put_all_data is 791.306 ms; child SqliteConnection::put is 769.613 ms self across 1502 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Inspect representative 9f0416be and isolate post-VM side-store writes.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "9f0416becf87bb90dcb0bcb2c6e9641efc97342c159b0d6d6937fe1e93f9f610"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/trace-9f0416be.csv",
      "key_observation": "put_all_data is 541.240 ms; child SqliteConnection::put is 517.346 ms self across 1401 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Characterize per-call shape for the put span.",
      "sql_path": "queries/span_per_sample_distribution.sql",
      "params": {
        "run_id": "6",
        "span_id": "60"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/span-put-sample-distribution.csv",
      "key_observation": "SqliteConnection::put has p95 self 417.44 us and p99 self 569.0 us across 1038880 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Confirm put can dominate individual replay blocks.",
      "sql_path": "queries/span_per_block_distribution.sql",
      "params": {
        "run_id": "6",
        "span_id": "60"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/span-put-block-distribution.csv",
      "key_observation": "SqliteConnection::put has max per-block self wall 978.535 ms and p99 block self wall 491.435 ms.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    }
  ],
  "proposed_change": "Add a bulk side-store write helper beside SqliteConnection::put, for example SqliteConnection::put_many(conn, items), that prepares the REPLACE INTO data_table (key, value) VALUES (?, ?) statement once against the existing rusqlite Transaction and executes it for all converted side-store values. Use that helper in PersistentWritableMarfStore::put_all_data after building the MARF keys/values, and in MemoryBackingStore::put_all_data for parity. Keep MARF::insert_batch unchanged and preserve the exact key/value strings and error mapping.",
  "expected_improvement": {
    "tx_latency": 5.0,
    "tenure_throughput": 0.0,
    "commit_time": 0.0
  },
  "risk": "medium",
  "verification_plan": "Check Clarity backing-store unit coverage for put/get round trips, rollback commit behavior, and MARF side-store reads by hash. Add focused regression coverage if no test asserts that batched put_all_data writes exactly the same data_table rows as individual puts. Then run the targeted replay below and compare put and put_all_data spans, plus transaction duration.",
  "verification_replay": {
    "rationale": "Replay the representatives where post-VM side-store writes dominate, then compare transaction latency and the put/put_all_data spans.",
    "invocations": [
      {
        "id": "write-heavy-txs",
        "label": "write-heavy txs",
        "purpose": "Measure whether batching side-store writes reduces the SQLite put-heavy add-liquidity executions.",
        "samples": {
          "kind": "txids",
          "txids": [
            "0x37ad67a35e440ee7bb3f35620c3ccb26937103eb446b6a15f9b7814fedef9637",
            "0x408f81be04c3bbf1cf0593233fa75334536c68251e851153322db976d3085898",
            "0x9263904171da1a1a3d3b7e538b12b7c8984d0aa221a6588567f933ffa6a995e7",
            "0x9f0416becf87bb90dcb0bcb2c6e9641efc97342c159b0d6d6937fe1e93f9f610"
          ]
        },
        "warmup": 0,
        "repetitions": 20,
        "profiler": "rich",
        "expected_signal": {
          "axis": "tx_latency",
          "direction": "improves",
          "estimate_pct": 5.0,
          "tolerance_pct": 4.0
        }
      }
    ],
    "suspected_spans": [
      "put",
      "put_all_data"
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
  "target_id": "clarity-side-store-bulk-put",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    10
  ],
  "baseline_run_ids": [
    7
  ],
  "improvement_pct": 4.184,
  "base_sha": "f4cab0a011e273e1f1f9b5249afee2fba6123da5",
  "head_sha": "ae1afdbb92f99d9748c1c8a29898a666c494b47f"
}
```

- Phase 3.5 results-analyzer verdict for this target (the authoritative
  source for the `Benchmark result` section on `normal_pr`):

```json
{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "clarity-side-store-bulk-put",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "high",
  "headline_rationale": "The write-heavy replay improved tx execution latency by 4.18%, within the expected 5% +/- 4% band, and the SQLite side-store write spans moved in the predicted direction.",
  "headline_improvement_pct": 4.184,
  "per_invocation": [
    {
      "invocation_id": "write-heavy-txs",
      "label": "write-heavy txs",
      "baseline_run_id": 7,
      "candidate_run_id": 10,
      "measured_pct": 4.184,
      "matches_expected_signal": true,
      "observations": [
        "Both bench-run envelopes succeeded, were not interrupted, and matched the recorded run ids: baseline 7 and candidate 10.",
        "DB block timing shows execution_us_per_block improved from 1323303.175 us to 1267941.063 us, a 4.184% tx-latency improvement; total_us_per_block improved 3.544%.",
        "All four replayed tx hashes improved on stacks_tx_stats.duration_us averages: 37ad67a3 +4.842%, 408f81be +5.184%, 92639041 +3.286%, and 9f0416be +3.507%.",
        "The exact old SqliteConnection::put span is absent in the candidate, while the replacement SqliteConnection::put_many span accounts for 2940091 us across 240 batch calls versus baseline put at 3139064 us across 118300 per-item calls.",
        "PersistentWritableMarfStore::put_all_data total wall improved from 5109628 us to 4756109 us, a 6.919% reduction with the same 240 parent calls."
      ]
    }
  ],
  "caveats": [
    "Commit_us_per_block regressed by 3.619%, partially offsetting the execution gain at the whole-block level; total_us_per_block still improved by 3.544%.",
    "SqliteConnection::put_many remains a top candidate span at 2940091 us self wall, so batching reduced dispatch/prepare overhead but did not eliminate SQLite write cost."
  ],
  "pr_body_summary": "The write-heavy transaction replay moved in the expected direction: tx execution latency improved by 4.18%, within the analyzer's 5% +/- 4% expectation, and total block time improved by 3.54%. The profiler evidence matches the proposed mechanism: the old per-item `SqliteConnection::put` calls disappeared, the new `put_many` batch path handled the side-store writes, and `PersistentWritableMarfStore::put_all_data` total wall time fell by 6.92%. All four replayed tx hashes improved on average duration, with per-sample gains between 3.29% and 5.18%. Commit timing regressed by 3.62% per block, so the total-block improvement is smaller than the execution-latency gain, but it does not contradict the tx-latency mechanism.",
  "db_queries": [
    {
      "purpose": "compare_run_summary envelope sanity",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare_block_timing tx latency context",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare span put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-0990b192238d.csv"
    },
    {
      "purpose": "compare span put_all_data parent movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-277ef1175b32.csv"
    },
    {
      "purpose": "compare span SqliteConnection::put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-444a5cfe565a.csv"
    },
    {
      "purpose": "compare span PersistentWritableMarfStore::put_all_data movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-af612d0f59d6.csv"
    },
    {
      "purpose": "side-store put span family including new put_many",
      "query_digest": "a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e",
      "rows_returned": 10,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e-e42255c1d3ce.csv"
    },
    {
      "purpose": "top candidate spans by self wall for compensation check",
      "query_digest": "d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523",
      "rows_returned": 25,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523-e42255c1d3ce.csv"
    },
    {
      "purpose": "per tx hash duration comparison for write-heavy samples",
      "query_digest": "334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c",
      "rows_returned": 4,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c-e42255c1d3ce.csv"
    },
    {
      "purpose": "put_all_data per-block distribution comparison",
      "query_digest": "e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13",
      "rows_returned": 2,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13-e42255c1d3ce.csv"
    }
  ]
}
```

  Important: when `normal_pr` is `normal_pr` and
  `{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "clarity-side-store-bulk-put",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "high",
  "headline_rationale": "The write-heavy replay improved tx execution latency by 4.18%, within the expected 5% +/- 4% band, and the SQLite side-store write spans moved in the predicted direction.",
  "headline_improvement_pct": 4.184,
  "per_invocation": [
    {
      "invocation_id": "write-heavy-txs",
      "label": "write-heavy txs",
      "baseline_run_id": 7,
      "candidate_run_id": 10,
      "measured_pct": 4.184,
      "matches_expected_signal": true,
      "observations": [
        "Both bench-run envelopes succeeded, were not interrupted, and matched the recorded run ids: baseline 7 and candidate 10.",
        "DB block timing shows execution_us_per_block improved from 1323303.175 us to 1267941.063 us, a 4.184% tx-latency improvement; total_us_per_block improved 3.544%.",
        "All four replayed tx hashes improved on stacks_tx_stats.duration_us averages: 37ad67a3 +4.842%, 408f81be +5.184%, 92639041 +3.286%, and 9f0416be +3.507%.",
        "The exact old SqliteConnection::put span is absent in the candidate, while the replacement SqliteConnection::put_many span accounts for 2940091 us across 240 batch calls versus baseline put at 3139064 us across 118300 per-item calls.",
        "PersistentWritableMarfStore::put_all_data total wall improved from 5109628 us to 4756109 us, a 6.919% reduction with the same 240 parent calls."
      ]
    }
  ],
  "caveats": [
    "Commit_us_per_block regressed by 3.619%, partially offsetting the execution gain at the whole-block level; total_us_per_block still improved by 3.544%.",
    "SqliteConnection::put_many remains a top candidate span at 2940091 us self wall, so batching reduced dispatch/prepare overhead but did not eliminate SQLite write cost."
  ],
  "pr_body_summary": "The write-heavy transaction replay moved in the expected direction: tx execution latency improved by 4.18%, within the analyzer's 5% +/- 4% expectation, and total block time improved by 3.54%. The profiler evidence matches the proposed mechanism: the old per-item `SqliteConnection::put` calls disappeared, the new `put_many` batch path handled the side-store writes, and `PersistentWritableMarfStore::put_all_data` total wall time fell by 6.92%. All four replayed tx hashes improved on average duration, with per-sample gains between 3.29% and 5.18%. Commit timing regressed by 3.62% per block, so the total-block improvement is smaller than the execution-latency gain, but it does not contradict the tx-latency mechanism.",
  "db_queries": [
    {
      "purpose": "compare_run_summary envelope sanity",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare_block_timing tx latency context",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare span put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-0990b192238d.csv"
    },
    {
      "purpose": "compare span put_all_data parent movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-277ef1175b32.csv"
    },
    {
      "purpose": "compare span SqliteConnection::put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-444a5cfe565a.csv"
    },
    {
      "purpose": "compare span PersistentWritableMarfStore::put_all_data movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-af612d0f59d6.csv"
    },
    {
      "purpose": "side-store put span family including new put_many",
      "query_digest": "a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e",
      "rows_returned": 10,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e-e42255c1d3ce.csv"
    },
    {
      "purpose": "top candidate spans by self wall for compensation check",
      "query_digest": "d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523",
      "rows_returned": 25,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523-e42255c1d3ce.csv"
    },
    {
      "purpose": "per tx hash duration comparison for write-heavy samples",
      "query_digest": "334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c",
      "rows_returned": 4,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c-e42255c1d3ce.csv"
    },
    {
      "purpose": "put_all_data per-block distribution comparison",
      "query_digest": "e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13",
      "rows_returned": 2,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13-e42255c1d3ce.csv"
    }
  ]
}` is non-empty, use its `pr_body_summary`
  verbatim as the body of `## Benchmark result`. The `verdict` +
  `confidence` lattice, the per-invocation breakdown, and the
  `caveats[]` array are operator-facing context. Do NOT re-synthesize
  numbers from `improvement_pct` alone — the verdict already explains
  why the number means what it means.

- Implementation notes are in `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/clarity-side-store-bulk-put/implementation.md`
- Test output (truncate as needed) lives in `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/clarity-side-store-bulk-put/nextest.log` and `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/clarity-side-store-bulk-put/nextest.stderr.log`. Cite specific numbers from these files in the `Validation` section rather than paraphrasing.
- Build log (for any flag/version-related notes) is at `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/clarity-side-store-bulk-put/cargo-build.log`.

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
  "target_id": "clarity-side-store-bulk-put",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "high",
  "headline_rationale": "The write-heavy replay improved tx execution latency by 4.18%, within the expected 5% +/- 4% band, and the SQLite side-store write spans moved in the predicted direction.",
  "headline_improvement_pct": 4.184,
  "per_invocation": [
    {
      "invocation_id": "write-heavy-txs",
      "label": "write-heavy txs",
      "baseline_run_id": 7,
      "candidate_run_id": 10,
      "measured_pct": 4.184,
      "matches_expected_signal": true,
      "observations": [
        "Both bench-run envelopes succeeded, were not interrupted, and matched the recorded run ids: baseline 7 and candidate 10.",
        "DB block timing shows execution_us_per_block improved from 1323303.175 us to 1267941.063 us, a 4.184% tx-latency improvement; total_us_per_block improved 3.544%.",
        "All four replayed tx hashes improved on stacks_tx_stats.duration_us averages: 37ad67a3 +4.842%, 408f81be +5.184%, 92639041 +3.286%, and 9f0416be +3.507%.",
        "The exact old SqliteConnection::put span is absent in the candidate, while the replacement SqliteConnection::put_many span accounts for 2940091 us across 240 batch calls versus baseline put at 3139064 us across 118300 per-item calls.",
        "PersistentWritableMarfStore::put_all_data total wall improved from 5109628 us to 4756109 us, a 6.919% reduction with the same 240 parent calls."
      ]
    }
  ],
  "caveats": [
    "Commit_us_per_block regressed by 3.619%, partially offsetting the execution gain at the whole-block level; total_us_per_block still improved by 3.544%.",
    "SqliteConnection::put_many remains a top candidate span at 2940091 us self wall, so batching reduced dispatch/prepare overhead but did not eliminate SQLite write cost."
  ],
  "pr_body_summary": "The write-heavy transaction replay moved in the expected direction: tx execution latency improved by 4.18%, within the analyzer's 5% +/- 4% expectation, and total block time improved by 3.54%. The profiler evidence matches the proposed mechanism: the old per-item `SqliteConnection::put` calls disappeared, the new `put_many` batch path handled the side-store writes, and `PersistentWritableMarfStore::put_all_data` total wall time fell by 6.92%. All four replayed tx hashes improved on average duration, with per-sample gains between 3.29% and 5.18%. Commit timing regressed by 3.62% per block, so the total-block improvement is smaller than the execution-latency gain, but it does not contradict the tx-latency mechanism.",
  "db_queries": [
    {
      "purpose": "compare_run_summary envelope sanity",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare_block_timing tx latency context",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare span put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-0990b192238d.csv"
    },
    {
      "purpose": "compare span put_all_data parent movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-277ef1175b32.csv"
    },
    {
      "purpose": "compare span SqliteConnection::put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-444a5cfe565a.csv"
    },
    {
      "purpose": "compare span PersistentWritableMarfStore::put_all_data movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-af612d0f59d6.csv"
    },
    {
      "purpose": "side-store put span family including new put_many",
      "query_digest": "a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e",
      "rows_returned": 10,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e-e42255c1d3ce.csv"
    },
    {
      "purpose": "top candidate spans by self wall for compensation check",
      "query_digest": "d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523",
      "rows_returned": 25,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523-e42255c1d3ce.csv"
    },
    {
      "purpose": "per tx hash duration comparison for write-heavy samples",
      "query_digest": "334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c",
      "rows_returned": 4,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c-e42255c1d3ce.csv"
    },
    {
      "purpose": "put_all_data per-block distribution comparison",
      "query_digest": "e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13",
      "rows_returned": 2,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13-e42255c1d3ce.csv"
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
  "target_id": "clarity-side-store-bulk-put",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "high",
  "headline_rationale": "The write-heavy replay improved tx execution latency by 4.18%, within the expected 5% +/- 4% band, and the SQLite side-store write spans moved in the predicted direction.",
  "headline_improvement_pct": 4.184,
  "per_invocation": [
    {
      "invocation_id": "write-heavy-txs",
      "label": "write-heavy txs",
      "baseline_run_id": 7,
      "candidate_run_id": 10,
      "measured_pct": 4.184,
      "matches_expected_signal": true,
      "observations": [
        "Both bench-run envelopes succeeded, were not interrupted, and matched the recorded run ids: baseline 7 and candidate 10.",
        "DB block timing shows execution_us_per_block improved from 1323303.175 us to 1267941.063 us, a 4.184% tx-latency improvement; total_us_per_block improved 3.544%.",
        "All four replayed tx hashes improved on stacks_tx_stats.duration_us averages: 37ad67a3 +4.842%, 408f81be +5.184%, 92639041 +3.286%, and 9f0416be +3.507%.",
        "The exact old SqliteConnection::put span is absent in the candidate, while the replacement SqliteConnection::put_many span accounts for 2940091 us across 240 batch calls versus baseline put at 3139064 us across 118300 per-item calls.",
        "PersistentWritableMarfStore::put_all_data total wall improved from 5109628 us to 4756109 us, a 6.919% reduction with the same 240 parent calls."
      ]
    }
  ],
  "caveats": [
    "Commit_us_per_block regressed by 3.619%, partially offsetting the execution gain at the whole-block level; total_us_per_block still improved by 3.544%.",
    "SqliteConnection::put_many remains a top candidate span at 2940091 us self wall, so batching reduced dispatch/prepare overhead but did not eliminate SQLite write cost."
  ],
  "pr_body_summary": "The write-heavy transaction replay moved in the expected direction: tx execution latency improved by 4.18%, within the analyzer's 5% +/- 4% expectation, and total block time improved by 3.54%. The profiler evidence matches the proposed mechanism: the old per-item `SqliteConnection::put` calls disappeared, the new `put_many` batch path handled the side-store writes, and `PersistentWritableMarfStore::put_all_data` total wall time fell by 6.92%. All four replayed tx hashes improved on average duration, with per-sample gains between 3.29% and 5.18%. Commit timing regressed by 3.62% per block, so the total-block improvement is smaller than the execution-latency gain, but it does not contradict the tx-latency mechanism.",
  "db_queries": [
    {
      "purpose": "compare_run_summary envelope sanity",
      "query_digest": "0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513",
      "rows_returned": 5,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/0f04dc09410fb42f650793e293b4b69d4e1f853e13bece5b7ce8f955b4c9c513-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare_block_timing tx latency context",
      "query_digest": "9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c",
      "rows_returned": 6,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/9e906e8b79e87478de12d542c5eaa714b124204121971142ce164e0f817b5c7c-e42255c1d3ce.csv"
    },
    {
      "purpose": "compare span put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-0990b192238d.csv"
    },
    {
      "purpose": "compare span put_all_data parent movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 1,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-277ef1175b32.csv"
    },
    {
      "purpose": "compare span SqliteConnection::put mechanism movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-444a5cfe565a.csv"
    },
    {
      "purpose": "compare span PersistentWritableMarfStore::put_all_data movement",
      "query_digest": "5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c",
      "rows_returned": 0,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/5db9e3dab0e264ccc41ab213eeef0da16bfb2d9eb3f6ff191330f3a3d36d021c-af612d0f59d6.csv"
    },
    {
      "purpose": "side-store put span family including new put_many",
      "query_digest": "a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e",
      "rows_returned": 10,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/a470fa23e65342fee2596ff394120d4a6a47bb1bafdaf54478cc875f4fe4131e-e42255c1d3ce.csv"
    },
    {
      "purpose": "top candidate spans by self wall for compensation check",
      "query_digest": "d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523",
      "rows_returned": 25,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/d2636460eb5fc4468d5bfa2f22ae9158e13ef260c23efeed798d56b8d557f523-e42255c1d3ce.csv"
    },
    {
      "purpose": "per tx hash duration comparison for write-heavy samples",
      "query_digest": "334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c",
      "rows_returned": 4,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/334175ed1b29b63080ba6780f8302c32c38458a7d1a2d39245f3333b90030b1c-e42255c1d3ce.csv"
    },
    {
      "purpose": "put_all_data per-block distribution comparison",
      "query_digest": "e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13",
      "rows_returned": 2,
      "output_path": "analyze/clarity-side-store-bulk-put/queries/e13033fd9fbb090e322a2f5d1b40cf8689ac10012f797a77828e24d73262ce13-e42255c1d3ce.csv"
    }
  ]
}` is `{}` (no verdict was produced
  for this `normal_pr` target — typically because Phase 3.5 was
  skipped or the agent failed) you MUST NOT publish a PR. Surface
  this gap as a `## Benchmark result` paragraph that says
  "Results-analyzer did not produce a verdict for this target; the
  measured `improvement_pct` from `{
  "target_id": "clarity-side-store-bulk-put",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    10
  ],
  "baseline_run_ids": [
    7
  ],
  "improvement_pct": 4.184,
  "base_sha": "f4cab0a011e273e1f1f9b5249afee2fba6123da5",
  "head_sha": "ae1afdbb92f99d9748c1c8a29898a666c494b47f"
}` has not
  been judged against the analyzer's `expected_signal`. Hold for
  operator review." Operator review will decide whether to re-run
  Phase 3.5 or ship without a verdict.
- For `consensus_poc_pr`: `{
  "target_id": "clarity-side-store-bulk-put",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    10
  ],
  "baseline_run_ids": [
    7
  ],
  "improvement_pct": 4.184,
  "base_sha": "f4cab0a011e273e1f1f9b5249afee2fba6123da5",
  "head_sha": "ae1afdbb92f99d9748c1c8a29898a666c494b47f"
}` is `{}` (no benchmark ran). Do NOT invent improvement numbers. State explicitly that the benchmark was skipped by design (the harness encodes pre-change consensus). Cite the analyzer's `expected_improvement` vector from `{
  "id": "clarity-side-store-bulk-put",
  "merged_from": [
    {
      "family_id": "dlmm-add-liquidity-multi-throughput",
      "target_index": 0
    }
  ],
  "convergence_count": 1,
  "target_span": "put",
  "bucket": "block_processing",
  "hotspot": {
    "span": "put",
    "self_wall_us": 297586640,
    "total_wall_us": 297586640,
    "calls": 1038880,
    "location": "clarity/src/vm/database/sqlite.rs:133"
  },
  "files": [
    "clarity/src/vm/database/sqlite.rs",
    "stackslib/src/clarity_vm/database/marf.rs",
    "clarity/src/vm/database/key_value_wrapper.rs",
    "clarity/src/vm/database/clarity_store.rs"
  ],
  "evidence": "Representative traces 37ad67a3, 408f81be, 92639041, and 9f0416be all run under Transaction -> try_mine_tx_with_len -> PersistentWritableMarfStore::put_all_data after VM execution. That span loops over 1401-1502 staged edits and spends 515-770 ms almost entirely in SqliteConnection::put. The code path is RollbackWrapper::commit collecting bottom-level edits, calling ClarityBackingStore::put_all_data, then PersistentWritableMarfStore::put_all_data converting each value to a MARFValue and invoking SqliteConnection::put once per item before MARF::insert_batch. SqliteConnection::put is a single REPLACE INTO data_table statement via conn.execute, so this target is storage mechanics, not Clarity cost accounting. The fifth representative, 74a98eed, was inspected and is instead dominated by MARF Trie::walk_backptr inside VM reads; it does not invalidate the put target but should not be used as the primary replay sample for it.",
  "evidence_queries": [
    {
      "purpose": "Rank the storage write span in the full baseline run.",
      "sql_path": "queries/top_spans_by_self_wall.sql",
      "params": {
        "limit": "100",
        "run_id": "6"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/top-spans-by-self-wall.csv",
      "key_observation": "SqliteConnection::put is span_id 60 with 297586.64 ms self wall across 1038880 calls; avg self is 286.449 us/call.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Confirm add-liquidity-multi is the promoted throughput family and identify the near-binding axis.",
      "sql_path": "queries/top_clarity_consumers_by_contract.sql",
      "params": {
        "limit": "25",
        "run_id": "6"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/top-clarity-consumers.csv",
      "key_observation": "add-liquidity-multi has 592 calls and consumes 45.44% of run write_count, 44.09% write_length, 37.92% read_length, 35.68% read_count, and 29.86% runtime.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "List concrete add-liquidity-multi transactions and their Clarity write volume.",
      "sql_path": "queries/txs_for_contract.sql",
      "params": {
        "contract_name": "dlmm-liquidity-router-v-1-2",
        "function_name": "add-liquidity-multi",
        "issuer_address": "SM1FKXGNZJWSTWDWXQZJNF7B5TV5ZB235JTCXYXKD",
        "limit": "100",
        "run_id": "6"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/txs-add-liquidity-multi.csv",
      "key_observation": "The top five representatives run for 1937-2243 ms and carry 1399-1650 Clarity write_count each.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Inspect representative 37ad67a3 and isolate post-VM side-store writes.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "37ad67a35e440ee7bb3f35620c3ccb26937103eb446b6a15f9b7814fedef9637"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/trace-37ad67a3.csv",
      "key_observation": "put_all_data is 565.408 ms; child SqliteConnection::put is 539.374 ms self across 1502 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Inspect representative 408f81be and isolate post-VM side-store writes.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "408f81be04c3bbf1cf0593233fa75334536c68251e851153322db976d3085898"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/trace-408f81be.csv",
      "key_observation": "put_all_data is 540.743 ms; child SqliteConnection::put is 515.217 ms self across 1502 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Inspect representative 92639041 and isolate post-VM side-store writes.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "9263904171da1a1a3d3b7e538b12b7c8984d0aa221a6588567f933ffa6a995e7"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/trace-92639041.csv",
      "key_observation": "put_all_data is 791.306 ms; child SqliteConnection::put is 769.613 ms self across 1502 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Inspect representative 9f0416be and isolate post-VM side-store writes.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "9f0416becf87bb90dcb0bcb2c6e9641efc97342c159b0d6d6937fe1e93f9f610"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/trace-9f0416be.csv",
      "key_observation": "put_all_data is 541.240 ms; child SqliteConnection::put is 517.346 ms self across 1401 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Characterize per-call shape for the put span.",
      "sql_path": "queries/span_per_sample_distribution.sql",
      "params": {
        "run_id": "6",
        "span_id": "60"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/span-put-sample-distribution.csv",
      "key_observation": "SqliteConnection::put has p95 self 417.44 us and p99 self 569.0 us across 1038880 calls.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    },
    {
      "purpose": "Confirm put can dominate individual replay blocks.",
      "sql_path": "queries/span_per_block_distribution.sql",
      "params": {
        "run_id": "6",
        "span_id": "60"
      },
      "output_path": "analysis/dlmm-add-liquidity-multi-throughput/queries/span-put-block-distribution.csv",
      "key_observation": "SqliteConnection::put has max per-block self wall 978.535 ms and p99 block self wall 491.435 ms.",
      "supports_invocations": [
        "write-heavy-txs"
      ]
    }
  ],
  "proposed_change": "Add a bulk side-store write helper beside SqliteConnection::put, for example SqliteConnection::put_many(conn, items), that prepares the REPLACE INTO data_table (key, value) VALUES (?, ?) statement once against the existing rusqlite Transaction and executes it for all converted side-store values. Use that helper in PersistentWritableMarfStore::put_all_data after building the MARF keys/values, and in MemoryBackingStore::put_all_data for parity. Keep MARF::insert_batch unchanged and preserve the exact key/value strings and error mapping.",
  "expected_improvement": {
    "tx_latency": 5.0,
    "tenure_throughput": 0.0,
    "commit_time": 0.0
  },
  "risk": "medium",
  "verification_plan": "Check Clarity backing-store unit coverage for put/get round trips, rollback commit behavior, and MARF side-store reads by hash. Add focused regression coverage if no test asserts that batched put_all_data writes exactly the same data_table rows as individual puts. Then run the targeted replay below and compare put and put_all_data spans, plus transaction duration.",
  "verification_replay": {
    "rationale": "Replay the representatives where post-VM side-store writes dominate, then compare transaction latency and the put/put_all_data spans.",
    "invocations": [
      {
        "id": "write-heavy-txs",
        "label": "write-heavy txs",
        "purpose": "Measure whether batching side-store writes reduces the SQLite put-heavy add-liquidity executions.",
        "samples": {
          "kind": "txids",
          "txids": [
            "0x37ad67a35e440ee7bb3f35620c3ccb26937103eb446b6a15f9b7814fedef9637",
            "0x408f81be04c3bbf1cf0593233fa75334536c68251e851153322db976d3085898",
            "0x9263904171da1a1a3d3b7e538b12b7c8984d0aa221a6588567f933ffa6a995e7",
            "0x9f0416becf87bb90dcb0bcb2c6e9641efc97342c159b0d6d6937fe1e93f9f610"
          ]
        },
        "warmup": 0,
        "repetitions": 20,
        "profiler": "rich",
        "expected_signal": {
          "axis": "tx_latency",
          "direction": "improves",
          "estimate_pct": 5.0,
          "tolerance_pct": 4.0
        }
      }
    ],
    "suspected_spans": [
      "put",
      "put_all_data"
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
