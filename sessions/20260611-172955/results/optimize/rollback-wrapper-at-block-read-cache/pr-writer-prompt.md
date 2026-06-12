You are preparing a GitHub pull request for an autonomous optimization run on `stacks-core`. There are two PR shapes you may be asked to write — see "Delivery mode" below — and the expected framing differs significantly between them.

# Goal

Write concise, factual PR artifacts for this target:

- `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/rollback-wrapper-at-block-read-cache/pr-title.txt` — a single-line PR title
- `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/rollback-wrapper-at-block-read-cache/pr-body.md` — a markdown PR body

Do NOT create the PR yourself. Do NOT use GitHub tools. Only write the two files above.

# Delivery mode

Your delivery mode for this target is `normal_pr`. Two PR shapes:

- **`normal_pr`** — a standard performance optimization. The optimizer ran the full nextest suite; the Phase 3.5 results-analyzer judged measured vs the analyzer's `expected_signal` per invocation and committed an `accepted` or `mixed` verdict with `confidence >= results_analysis.confidence_floor`. The verdict's `pr_body_summary` is the canonical Result-section prose (read it verbatim from `{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "rollback-wrapper-at-block-read-cache",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "medium",
  "headline_rationale": "The representative-heavy replay improved exact target transaction latency by 27.22%, with matching reductions in at-block and backing MARF read spans.",
  "headline_improvement_pct": 27.22,
  "per_invocation": [
    {
      "invocation_id": "representative-heavy",
      "label": "representative heavy txs",
      "baseline_run_id": 8,
      "candidate_run_id": 11,
      "measured_pct": 27.22,
      "matches_expected_signal": true,
      "observations": [
        "Both bench envelopes succeeded without interruption and matched the run-id maps: baseline run 8, candidate run 11, 100 measured blocks/transactions each.",
        "Exact DB replay tx comparison over the five requested txids and 20 repetitions each improved average duration from 1,263,375.9 us to 919,480.78 us, a 27.22% improvement; each individual txid improved between 24.294% and 30.595%.",
        "Block execution time moved in the same direction, improving 27.22% per block; total block time improved 26.843%.",
        "The suspected mechanism moved directly: at-block total wall improved 28.815%, ExecutionState::evaluate_at_block improved 28.82%, PersistentWritableMarfStore::get_data total wall improved 36.662%, MARF get_by_key/get_path/walk improved about 37.5%, and Trie::walk_backptr improved 37.171%.",
        "Backend MARF call counts dropped while Clarity/RollbackWrapper get_data/get_value call counts stayed flat, consistent with a read-through cache avoiding repeated materialized backing-store reads without changing Clarity-level reads.",
        "All deterministic Clarity cost deltas for the target tx set were zero, so the result is a wall-time latency gain rather than a tenure-budget change."
      ]
    }
  ],
  "caveats": [
    "The measured 27.22% tx-latency gain is well above the expected 6% +/- 4% estimate; the direction and mechanism match, but confidence is medium because the magnitude estimate was not close.",
    "This replay is intentionally concentrated on five heavy dual-stacking snapshot txids, so the headline should be read as representative-heavy replay latency, not broad network-average throughput.",
    "The optimizer also cached ordinary metadata reads, and metadata backing-store spans dropped materially; get_metadata_manual remained uncached as reported by the optimizer."
  ],
  "pr_body_summary": "The representative-heavy replay accepted the hypothesis: exact target transaction latency improved 27.22% across the five requested txids and 20 repetitions each. The profile moved in the expected place: at-block/evaluate_at_block total wall fell about 28.8%, PersistentWritableMarfStore::get_data fell 36.7%, and the MARF walk path fell about 37%. Clarity-level cost counters were unchanged, so this is a wall-time latency improvement rather than a consensus budget change. The measured gain is materially larger than the analyzer's 6% estimate, likely because the implementation also reduced ordinary metadata backing reads in this workload.",
  "db_queries": [
    {
      "purpose": "Envelope sanity for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5",
      "rows_returned": 5,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5.csv"
    },
    {
      "purpose": "Block timing comparison for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035.csv"
    },
    {
      "purpose": "Suspected span comparison for get_data between baseline run 8 and candidate run 11",
      "query_digest": "fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522",
      "rows_returned": 4,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522.csv"
    },
    {
      "purpose": "Suspected span comparison for get_value between baseline run 8 and candidate run 11",
      "query_digest": "77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584.csv"
    },
    {
      "purpose": "Suspected span comparison for get_by_key between baseline run 8 and candidate run 11",
      "query_digest": "48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66.csv"
    },
    {
      "purpose": "Suspected span comparison for get_path between baseline run 8 and candidate run 11",
      "query_digest": "15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1.csv"
    },
    {
      "purpose": "Suspected span comparison for walk between baseline run 8 and candidate run 11",
      "query_digest": "4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f.csv"
    },
    {
      "purpose": "Suspected span comparison for walk_backptr between baseline run 8 and candidate run 11",
      "query_digest": "731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac.csv"
    },
    {
      "purpose": "Baseline top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069.csv"
    },
    {
      "purpose": "Baseline top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4.csv"
    },
    {
      "purpose": "Baseline transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4.csv"
    },
    {
      "purpose": "Candidate top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d.csv"
    },
    {
      "purpose": "Candidate top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5.csv"
    },
    {
      "purpose": "Candidate transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89.csv"
    },
    {
      "purpose": "Exact replay tx latency comparison for the five representative txids",
      "query_digest": "2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742.csv"
    },
    {
      "purpose": "Trace-level mechanism summary for target txids across at-block and suspected storage spans",
      "query_digest": "99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3",
      "rows_returned": 15,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3.csv"
    }
  ]
}`). The PR is a regular draft (or non-draft per operator preference) seeking review and merge in the usual way.

- **`consensus_poc_pr`** — a deliberate consensus-breaking change shipped as a PoC. The optimizer ran nextest filtered to `poc_test_scope` ONLY; the full suite is not the acceptance gate and may encode old consensus expectations that the change deliberately invalidates. **No benchmark ran** — the bench harness encodes pre-change consensus rules and would either crash or produce meaningless numbers. The PR is ALWAYS a draft and the publisher applies safety labels (`consensus-change`, `needs-HIP`, `do-not-merge`) to prevent accidental merging. The PR is the entry point for HIP-style discussion of the consensus change.

If `normal_pr` is `consensus_poc_pr`, the framing in your PR body MUST make the consensus nature obvious:

- Title: prefer `consensus(PoC): <specific change summary>` or `perf(consensus PoC): <…>` so the consensus nature shows up at a glance.
- `## Summary`: state explicitly that this is a consensus-breaking PoC and that the change requires HIP-style coordination before merge.
- `## What changed`: same content, no special framing needed.
- `## Benchmark result`: the bench was SKIPPED BY DESIGN. State this explicitly. Do not invent improvement numbers. Cite the analyzer's `expected_improvement` vector from the target JSON if useful, but make clear it's an analyzer estimate, not a measured result.
- `## Validation`: the scoped nextest run is the acceptance gate. Cite the scoped tests that passed (from `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/rollback-wrapper-at-block-read-cache/nextest.log`) and the breakage_class. Note explicitly that the full suite was NOT the gate and that some non-scoped tests may encode pre-change consensus expectations the fix invalidates. Do NOT claim full-suite passage.
- Add a final `## Consensus / HIP coordination` section pulling from the target's `consensus_writeup` field — what the rule change is, who pays for it, what HIP discussion would be required.

# Inputs

- Session id: `20260611-172955`
- Target id: `rollback-wrapper-at-block-read-cache`
- Output directory: `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/rollback-wrapper-at-block-read-cache`
- Worktree directory: `/private/tmp/sbagent-workspaces/optimizers/20260611-172955/rollback-wrapper-at-block-read-cache`
- Accepted target JSON:

```json
{
  "id": "rollback-wrapper-at-block-read-cache",
  "merged_from": [
    {
      "family_id": "dual-stacking-snapshot-balance-fanout",
      "target_index": 0
    }
  ],
  "convergence_count": 1,
  "target_span": "get_data",
  "bucket": "block_processing",
  "hotspot": {
    "span": "get_data",
    "self_wall_us": 5517700,
    "total_wall_us": 531004890,
    "calls": 11318323,
    "location": "stackslib/src/clarity_vm/database/marf.rs:852"
  },
  "files": [
    "clarity/src/vm/database/key_value_wrapper.rs",
    "stackslib/src/clarity_vm/database/marf.rs",
    "clarity/src/vm/contexts.rs",
    "clarity/src/vm/database/clarity_db.rs"
  ],
  "evidence": "All five representatives follow the same tree: Transaction -> try_mine_tx_with_len -> with_abort_callback -> execute-contract dual-stacking-v2_1_0.capture-snapshot-balances-optimizer -> map -> capture-participant-balances-optimizer -> capture-participant-snapshot. The hot child is 60 at-block evaluations per tx, totaling about 1.48s-1.56s of nested work in the trace summaries. Under those at-block closures, repeated get_data/get_value calls enter PersistentWritableMarfStore::get_data and then MARF get_by_key/get_path/walk/walk_backptr. Representative totals for PersistentWritableMarfStore::get_data are about 478ms-539ms per tx with roughly 2,960-3,165 calls, while MARF get_by_key/get_path/walk totals are about 548ms-596ms per tx with roughly 4,900-5,200 calls. Code confirms the handle: ExecutionState::evaluate_at_block sets a historical block hash with query_pending_data=false, RollbackWrapper then bypasses pending writes and calls the backing store for every materialized read, and PersistentWritableMarfStore::get_data performs marf.get(chain_tip, key) plus side-store lookup. The existing RollbackWrapper maps only cache pending writes, not materialized historical store reads. The top Clarity-cost query shows this family's max axis share is 5.48%, so this target moves wall-time latency, not tenure budget.",
  "evidence_queries": [
    {
      "purpose": "Confirm the family size, top representative durations, and stable per-call Clarity read shape.",
      "sql_path": "queries/txs_for_contract.sql",
      "params": {
        "contract_name": "dual-stacking-v2_1_0",
        "function_name": "capture-snapshot-balances-optimizer",
        "issuer_address": "SP1HFCRKEJ8BYW4D0E3FAWHFDX8A25PPAA83HWWZ9",
        "limit": "100",
        "run_id": "6"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/dual-stacking-txs.csv",
      "key_observation": "59 calls; top five representative durations are 1688.226ms, 1627.729ms, 1615.264ms, 1610.986ms, and 1605.459ms, with about 5.5k read_count each.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Place this contract function in the run-level latency distribution.",
      "sql_path": "queries/top_contract_calls.sql",
      "params": {
        "limit": "50",
        "run_id": "6"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/top-contract-calls.csv",
      "key_observation": "dual-stacking-v2_1_0.capture-snapshot-balances-optimizer ranks 4th by contract-call wall time with 59 calls, 83449.53ms total, and 1414.399ms average.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Confirm this is not a tenure-throughput target on a binding Clarity-cost axis.",
      "sql_path": "queries/top_clarity_consumers_by_contract.sql",
      "params": {
        "limit": "50",
        "run_id": "6"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/top-clarity-consumers.csv",
      "key_observation": "family max_axis_share_pct is 5.48%; runtime is the largest family share at 5.48%, while read_length is 1.98%, write_count 0.55%, and write_length 0.21%.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Identify the shared storage spans the target should move.",
      "sql_path": "queries/top_spans_by_self_wall.sql",
      "params": {
        "limit": "60",
        "run_id": "6"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/top-spans-self.csv",
      "key_observation": "PersistentWritableMarfStore::get_data has 531004.89ms total wall over 11318323 calls; Trie::walk_backptr has 932669.18ms self wall over 48440451 calls.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0x9728154c and confirm at-block historical reads dominate the tx tree.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "9728154c1239b04662827d03388ded4608eb53f42f24f36c7a0c9f05d5478a23"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-9728154c.csv",
      "key_observation": "tx wall is 1688.226ms; capture-participant-snapshot is 1643.659ms; trace aggregation shows 60 at-block calls totaling 1562.102ms and PersistentWritableMarfStore::get_data rows totaling 489.411ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0xac4eaf26 and confirm the same at-block/MARF read shape.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "ac4eaf264a66347202d171f77b1e88dde72e1aff48000e83b343ef62e15e235a"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-ac4eaf26.csv",
      "key_observation": "tx wall is 1627.729ms; capture-participant-snapshot is 1589.582ms; trace aggregation shows 60 at-block calls totaling 1509.249ms and PersistentWritableMarfStore::get_data rows totaling 485.349ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0xbd001e97 and confirm the same at-block/MARF read shape.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "bd001e976f03206f10e6404abe289f73e8a3c4da8db5ac7d035763c0bee65171"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-bd001e97.csv",
      "key_observation": "tx wall is 1615.264ms; capture-participant-snapshot is 1573.540ms; trace aggregation shows 60 at-block calls totaling 1497.216ms and PersistentWritableMarfStore::get_data rows totaling 484.760ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0x7b5f49a4 and confirm the same at-block/MARF read shape.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "7b5f49a4fdc3164fc923982d7619608831c0847c476d4761708d75fc5df1f3fa"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-7b5f49a4.csv",
      "key_observation": "tx wall is 1610.986ms; capture-participant-snapshot is 1574.605ms; trace aggregation shows 60 at-block calls totaling 1497.446ms and PersistentWritableMarfStore::get_data rows totaling 538.753ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0x695be269 and confirm the same at-block/MARF read shape.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "695be269b728d5d55e07191115d513658a05dd97e266e59506cc38e3f733c11a"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-695be269.csv",
      "key_observation": "tx wall is 1605.459ms; capture-participant-snapshot is 1568.942ms; trace aggregation shows 60 at-block calls totaling 1482.623ms and PersistentWritableMarfStore::get_data rows totaling 478.082ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    }
  ],
  "proposed_change": "Add a transaction-local read-through cache to RollbackWrapper for materialized backing-store reads while query_pending_data is false. Track the active block hash after successful set_block_hash, and cache raw store results by (active_block_hash, key) for get_data/get_value and by (active_block_hash, contract, metadata_key) for metadata reads. Do not cache reads that consult pending data, do not cache proof reads, and clear or scope the cache with the RollbackWrapper lifetime so it cannot cross transactions. Refactor get_data and get_value through a shared raw-read helper so cached hex/string values still deserialize through the existing Clarity type paths and preserve cost accounting.",
  "expected_improvement": {
    "tx_latency": 6.0,
    "tenure_throughput": 0.0,
    "commit_time": 0.0
  },
  "risk": "medium",
  "verification_plan": "Add focused RollbackWrapper/ClarityDatabase tests that repeated at-block reads return the same values before and after pending writes in the surrounding tx, that restored block hash resumes pending-data visibility, and that metadata and value reads remain isolated by block hash. Then run targeted replay on the representative txids and compare get_data, get_by_key, walk, walk_backptr, and tx latency.",
  "verification_replay": {
    "rationale": "The cache is intra-transaction, so the representative tx replay directly measures whether repeated at-block historical reads avoid backing MARF work.",
    "invocations": [
      {
        "id": "representative-heavy",
        "label": "representative heavy txs",
        "purpose": "Measure tx-latency and MARF-read reduction on the five triaged snapshot optimizer transactions.",
        "samples": {
          "kind": "txids",
          "txids": [
            "0x9728154c1239b04662827d03388ded4608eb53f42f24f36c7a0c9f05d5478a23",
            "0xac4eaf264a66347202d171f77b1e88dde72e1aff48000e83b343ef62e15e235a",
            "0xbd001e976f03206f10e6404abe289f73e8a3c4da8db5ac7d035763c0bee65171",
            "0x7b5f49a4fdc3164fc923982d7619608831c0847c476d4761708d75fc5df1f3fa",
            "0x695be269b728d5d55e07191115d513658a05dd97e266e59506cc38e3f733c11a"
          ]
        },
        "warmup": 0,
        "repetitions": 20,
        "profiler": "rich",
        "expected_signal": {
          "axis": "tx_latency",
          "direction": "improves",
          "estimate_pct": 6.0,
          "tolerance_pct": 4.0
        }
      }
    ],
    "suspected_spans": [
      "get_data",
      "get_value",
      "get_by_key",
      "get_path",
      "walk",
      "walk_backptr"
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
  "target_id": "rollback-wrapper-at-block-read-cache",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    11
  ],
  "baseline_run_ids": [
    8
  ],
  "improvement_pct": 27.22,
  "base_sha": "f4cab0a011e273e1f1f9b5249afee2fba6123da5",
  "head_sha": "fdfafc482a765472e4b2f7da1611c65eb67fe2c3"
}
```

- Phase 3.5 results-analyzer verdict for this target (the authoritative
  source for the `Benchmark result` section on `normal_pr`):

```json
{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "rollback-wrapper-at-block-read-cache",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "medium",
  "headline_rationale": "The representative-heavy replay improved exact target transaction latency by 27.22%, with matching reductions in at-block and backing MARF read spans.",
  "headline_improvement_pct": 27.22,
  "per_invocation": [
    {
      "invocation_id": "representative-heavy",
      "label": "representative heavy txs",
      "baseline_run_id": 8,
      "candidate_run_id": 11,
      "measured_pct": 27.22,
      "matches_expected_signal": true,
      "observations": [
        "Both bench envelopes succeeded without interruption and matched the run-id maps: baseline run 8, candidate run 11, 100 measured blocks/transactions each.",
        "Exact DB replay tx comparison over the five requested txids and 20 repetitions each improved average duration from 1,263,375.9 us to 919,480.78 us, a 27.22% improvement; each individual txid improved between 24.294% and 30.595%.",
        "Block execution time moved in the same direction, improving 27.22% per block; total block time improved 26.843%.",
        "The suspected mechanism moved directly: at-block total wall improved 28.815%, ExecutionState::evaluate_at_block improved 28.82%, PersistentWritableMarfStore::get_data total wall improved 36.662%, MARF get_by_key/get_path/walk improved about 37.5%, and Trie::walk_backptr improved 37.171%.",
        "Backend MARF call counts dropped while Clarity/RollbackWrapper get_data/get_value call counts stayed flat, consistent with a read-through cache avoiding repeated materialized backing-store reads without changing Clarity-level reads.",
        "All deterministic Clarity cost deltas for the target tx set were zero, so the result is a wall-time latency gain rather than a tenure-budget change."
      ]
    }
  ],
  "caveats": [
    "The measured 27.22% tx-latency gain is well above the expected 6% +/- 4% estimate; the direction and mechanism match, but confidence is medium because the magnitude estimate was not close.",
    "This replay is intentionally concentrated on five heavy dual-stacking snapshot txids, so the headline should be read as representative-heavy replay latency, not broad network-average throughput.",
    "The optimizer also cached ordinary metadata reads, and metadata backing-store spans dropped materially; get_metadata_manual remained uncached as reported by the optimizer."
  ],
  "pr_body_summary": "The representative-heavy replay accepted the hypothesis: exact target transaction latency improved 27.22% across the five requested txids and 20 repetitions each. The profile moved in the expected place: at-block/evaluate_at_block total wall fell about 28.8%, PersistentWritableMarfStore::get_data fell 36.7%, and the MARF walk path fell about 37%. Clarity-level cost counters were unchanged, so this is a wall-time latency improvement rather than a consensus budget change. The measured gain is materially larger than the analyzer's 6% estimate, likely because the implementation also reduced ordinary metadata backing reads in this workload.",
  "db_queries": [
    {
      "purpose": "Envelope sanity for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5",
      "rows_returned": 5,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5.csv"
    },
    {
      "purpose": "Block timing comparison for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035.csv"
    },
    {
      "purpose": "Suspected span comparison for get_data between baseline run 8 and candidate run 11",
      "query_digest": "fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522",
      "rows_returned": 4,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522.csv"
    },
    {
      "purpose": "Suspected span comparison for get_value between baseline run 8 and candidate run 11",
      "query_digest": "77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584.csv"
    },
    {
      "purpose": "Suspected span comparison for get_by_key between baseline run 8 and candidate run 11",
      "query_digest": "48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66.csv"
    },
    {
      "purpose": "Suspected span comparison for get_path between baseline run 8 and candidate run 11",
      "query_digest": "15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1.csv"
    },
    {
      "purpose": "Suspected span comparison for walk between baseline run 8 and candidate run 11",
      "query_digest": "4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f.csv"
    },
    {
      "purpose": "Suspected span comparison for walk_backptr between baseline run 8 and candidate run 11",
      "query_digest": "731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac.csv"
    },
    {
      "purpose": "Baseline top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069.csv"
    },
    {
      "purpose": "Baseline top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4.csv"
    },
    {
      "purpose": "Baseline transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4.csv"
    },
    {
      "purpose": "Candidate top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d.csv"
    },
    {
      "purpose": "Candidate top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5.csv"
    },
    {
      "purpose": "Candidate transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89.csv"
    },
    {
      "purpose": "Exact replay tx latency comparison for the five representative txids",
      "query_digest": "2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742.csv"
    },
    {
      "purpose": "Trace-level mechanism summary for target txids across at-block and suspected storage spans",
      "query_digest": "99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3",
      "rows_returned": 15,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3.csv"
    }
  ]
}
```

  Important: when `normal_pr` is `normal_pr` and
  `{
  "schema_version": 1,
  "session_id": "20260611-172955",
  "target_id": "rollback-wrapper-at-block-read-cache",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "medium",
  "headline_rationale": "The representative-heavy replay improved exact target transaction latency by 27.22%, with matching reductions in at-block and backing MARF read spans.",
  "headline_improvement_pct": 27.22,
  "per_invocation": [
    {
      "invocation_id": "representative-heavy",
      "label": "representative heavy txs",
      "baseline_run_id": 8,
      "candidate_run_id": 11,
      "measured_pct": 27.22,
      "matches_expected_signal": true,
      "observations": [
        "Both bench envelopes succeeded without interruption and matched the run-id maps: baseline run 8, candidate run 11, 100 measured blocks/transactions each.",
        "Exact DB replay tx comparison over the five requested txids and 20 repetitions each improved average duration from 1,263,375.9 us to 919,480.78 us, a 27.22% improvement; each individual txid improved between 24.294% and 30.595%.",
        "Block execution time moved in the same direction, improving 27.22% per block; total block time improved 26.843%.",
        "The suspected mechanism moved directly: at-block total wall improved 28.815%, ExecutionState::evaluate_at_block improved 28.82%, PersistentWritableMarfStore::get_data total wall improved 36.662%, MARF get_by_key/get_path/walk improved about 37.5%, and Trie::walk_backptr improved 37.171%.",
        "Backend MARF call counts dropped while Clarity/RollbackWrapper get_data/get_value call counts stayed flat, consistent with a read-through cache avoiding repeated materialized backing-store reads without changing Clarity-level reads.",
        "All deterministic Clarity cost deltas for the target tx set were zero, so the result is a wall-time latency gain rather than a tenure-budget change."
      ]
    }
  ],
  "caveats": [
    "The measured 27.22% tx-latency gain is well above the expected 6% +/- 4% estimate; the direction and mechanism match, but confidence is medium because the magnitude estimate was not close.",
    "This replay is intentionally concentrated on five heavy dual-stacking snapshot txids, so the headline should be read as representative-heavy replay latency, not broad network-average throughput.",
    "The optimizer also cached ordinary metadata reads, and metadata backing-store spans dropped materially; get_metadata_manual remained uncached as reported by the optimizer."
  ],
  "pr_body_summary": "The representative-heavy replay accepted the hypothesis: exact target transaction latency improved 27.22% across the five requested txids and 20 repetitions each. The profile moved in the expected place: at-block/evaluate_at_block total wall fell about 28.8%, PersistentWritableMarfStore::get_data fell 36.7%, and the MARF walk path fell about 37%. Clarity-level cost counters were unchanged, so this is a wall-time latency improvement rather than a consensus budget change. The measured gain is materially larger than the analyzer's 6% estimate, likely because the implementation also reduced ordinary metadata backing reads in this workload.",
  "db_queries": [
    {
      "purpose": "Envelope sanity for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5",
      "rows_returned": 5,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5.csv"
    },
    {
      "purpose": "Block timing comparison for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035.csv"
    },
    {
      "purpose": "Suspected span comparison for get_data between baseline run 8 and candidate run 11",
      "query_digest": "fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522",
      "rows_returned": 4,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522.csv"
    },
    {
      "purpose": "Suspected span comparison for get_value between baseline run 8 and candidate run 11",
      "query_digest": "77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584.csv"
    },
    {
      "purpose": "Suspected span comparison for get_by_key between baseline run 8 and candidate run 11",
      "query_digest": "48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66.csv"
    },
    {
      "purpose": "Suspected span comparison for get_path between baseline run 8 and candidate run 11",
      "query_digest": "15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1.csv"
    },
    {
      "purpose": "Suspected span comparison for walk between baseline run 8 and candidate run 11",
      "query_digest": "4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f.csv"
    },
    {
      "purpose": "Suspected span comparison for walk_backptr between baseline run 8 and candidate run 11",
      "query_digest": "731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac.csv"
    },
    {
      "purpose": "Baseline top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069.csv"
    },
    {
      "purpose": "Baseline top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4.csv"
    },
    {
      "purpose": "Baseline transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4.csv"
    },
    {
      "purpose": "Candidate top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d.csv"
    },
    {
      "purpose": "Candidate top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5.csv"
    },
    {
      "purpose": "Candidate transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89.csv"
    },
    {
      "purpose": "Exact replay tx latency comparison for the five representative txids",
      "query_digest": "2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742.csv"
    },
    {
      "purpose": "Trace-level mechanism summary for target txids across at-block and suspected storage spans",
      "query_digest": "99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3",
      "rows_returned": 15,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3.csv"
    }
  ]
}` is non-empty, use its `pr_body_summary`
  verbatim as the body of `## Benchmark result`. The `verdict` +
  `confidence` lattice, the per-invocation breakdown, and the
  `caveats[]` array are operator-facing context. Do NOT re-synthesize
  numbers from `improvement_pct` alone — the verdict already explains
  why the number means what it means.

- Implementation notes are in `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/rollback-wrapper-at-block-read-cache/implementation.md`
- Test output (truncate as needed) lives in `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/rollback-wrapper-at-block-read-cache/nextest.log` and `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/rollback-wrapper-at-block-read-cache/nextest.stderr.log`. Cite specific numbers from these files in the `Validation` section rather than paraphrasing.
- Build log (for any flag/version-related notes) is at `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/rollback-wrapper-at-block-read-cache/cargo-build.log`.

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
  "target_id": "rollback-wrapper-at-block-read-cache",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "medium",
  "headline_rationale": "The representative-heavy replay improved exact target transaction latency by 27.22%, with matching reductions in at-block and backing MARF read spans.",
  "headline_improvement_pct": 27.22,
  "per_invocation": [
    {
      "invocation_id": "representative-heavy",
      "label": "representative heavy txs",
      "baseline_run_id": 8,
      "candidate_run_id": 11,
      "measured_pct": 27.22,
      "matches_expected_signal": true,
      "observations": [
        "Both bench envelopes succeeded without interruption and matched the run-id maps: baseline run 8, candidate run 11, 100 measured blocks/transactions each.",
        "Exact DB replay tx comparison over the five requested txids and 20 repetitions each improved average duration from 1,263,375.9 us to 919,480.78 us, a 27.22% improvement; each individual txid improved between 24.294% and 30.595%.",
        "Block execution time moved in the same direction, improving 27.22% per block; total block time improved 26.843%.",
        "The suspected mechanism moved directly: at-block total wall improved 28.815%, ExecutionState::evaluate_at_block improved 28.82%, PersistentWritableMarfStore::get_data total wall improved 36.662%, MARF get_by_key/get_path/walk improved about 37.5%, and Trie::walk_backptr improved 37.171%.",
        "Backend MARF call counts dropped while Clarity/RollbackWrapper get_data/get_value call counts stayed flat, consistent with a read-through cache avoiding repeated materialized backing-store reads without changing Clarity-level reads.",
        "All deterministic Clarity cost deltas for the target tx set were zero, so the result is a wall-time latency gain rather than a tenure-budget change."
      ]
    }
  ],
  "caveats": [
    "The measured 27.22% tx-latency gain is well above the expected 6% +/- 4% estimate; the direction and mechanism match, but confidence is medium because the magnitude estimate was not close.",
    "This replay is intentionally concentrated on five heavy dual-stacking snapshot txids, so the headline should be read as representative-heavy replay latency, not broad network-average throughput.",
    "The optimizer also cached ordinary metadata reads, and metadata backing-store spans dropped materially; get_metadata_manual remained uncached as reported by the optimizer."
  ],
  "pr_body_summary": "The representative-heavy replay accepted the hypothesis: exact target transaction latency improved 27.22% across the five requested txids and 20 repetitions each. The profile moved in the expected place: at-block/evaluate_at_block total wall fell about 28.8%, PersistentWritableMarfStore::get_data fell 36.7%, and the MARF walk path fell about 37%. Clarity-level cost counters were unchanged, so this is a wall-time latency improvement rather than a consensus budget change. The measured gain is materially larger than the analyzer's 6% estimate, likely because the implementation also reduced ordinary metadata backing reads in this workload.",
  "db_queries": [
    {
      "purpose": "Envelope sanity for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5",
      "rows_returned": 5,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5.csv"
    },
    {
      "purpose": "Block timing comparison for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035.csv"
    },
    {
      "purpose": "Suspected span comparison for get_data between baseline run 8 and candidate run 11",
      "query_digest": "fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522",
      "rows_returned": 4,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522.csv"
    },
    {
      "purpose": "Suspected span comparison for get_value between baseline run 8 and candidate run 11",
      "query_digest": "77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584.csv"
    },
    {
      "purpose": "Suspected span comparison for get_by_key between baseline run 8 and candidate run 11",
      "query_digest": "48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66.csv"
    },
    {
      "purpose": "Suspected span comparison for get_path between baseline run 8 and candidate run 11",
      "query_digest": "15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1.csv"
    },
    {
      "purpose": "Suspected span comparison for walk between baseline run 8 and candidate run 11",
      "query_digest": "4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f.csv"
    },
    {
      "purpose": "Suspected span comparison for walk_backptr between baseline run 8 and candidate run 11",
      "query_digest": "731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac.csv"
    },
    {
      "purpose": "Baseline top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069.csv"
    },
    {
      "purpose": "Baseline top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4.csv"
    },
    {
      "purpose": "Baseline transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4.csv"
    },
    {
      "purpose": "Candidate top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d.csv"
    },
    {
      "purpose": "Candidate top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5.csv"
    },
    {
      "purpose": "Candidate transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89.csv"
    },
    {
      "purpose": "Exact replay tx latency comparison for the five representative txids",
      "query_digest": "2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742.csv"
    },
    {
      "purpose": "Trace-level mechanism summary for target txids across at-block and suspected storage spans",
      "query_digest": "99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3",
      "rows_returned": 15,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3.csv"
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
  "target_id": "rollback-wrapper-at-block-read-cache",
  "axis": "tx_latency",
  "verdict": "accepted",
  "confidence": "medium",
  "headline_rationale": "The representative-heavy replay improved exact target transaction latency by 27.22%, with matching reductions in at-block and backing MARF read spans.",
  "headline_improvement_pct": 27.22,
  "per_invocation": [
    {
      "invocation_id": "representative-heavy",
      "label": "representative heavy txs",
      "baseline_run_id": 8,
      "candidate_run_id": 11,
      "measured_pct": 27.22,
      "matches_expected_signal": true,
      "observations": [
        "Both bench envelopes succeeded without interruption and matched the run-id maps: baseline run 8, candidate run 11, 100 measured blocks/transactions each.",
        "Exact DB replay tx comparison over the five requested txids and 20 repetitions each improved average duration from 1,263,375.9 us to 919,480.78 us, a 27.22% improvement; each individual txid improved between 24.294% and 30.595%.",
        "Block execution time moved in the same direction, improving 27.22% per block; total block time improved 26.843%.",
        "The suspected mechanism moved directly: at-block total wall improved 28.815%, ExecutionState::evaluate_at_block improved 28.82%, PersistentWritableMarfStore::get_data total wall improved 36.662%, MARF get_by_key/get_path/walk improved about 37.5%, and Trie::walk_backptr improved 37.171%.",
        "Backend MARF call counts dropped while Clarity/RollbackWrapper get_data/get_value call counts stayed flat, consistent with a read-through cache avoiding repeated materialized backing-store reads without changing Clarity-level reads.",
        "All deterministic Clarity cost deltas for the target tx set were zero, so the result is a wall-time latency gain rather than a tenure-budget change."
      ]
    }
  ],
  "caveats": [
    "The measured 27.22% tx-latency gain is well above the expected 6% +/- 4% estimate; the direction and mechanism match, but confidence is medium because the magnitude estimate was not close.",
    "This replay is intentionally concentrated on five heavy dual-stacking snapshot txids, so the headline should be read as representative-heavy replay latency, not broad network-average throughput.",
    "The optimizer also cached ordinary metadata reads, and metadata backing-store spans dropped materially; get_metadata_manual remained uncached as reported by the optimizer."
  ],
  "pr_body_summary": "The representative-heavy replay accepted the hypothesis: exact target transaction latency improved 27.22% across the five requested txids and 20 repetitions each. The profile moved in the expected place: at-block/evaluate_at_block total wall fell about 28.8%, PersistentWritableMarfStore::get_data fell 36.7%, and the MARF walk path fell about 37%. Clarity-level cost counters were unchanged, so this is a wall-time latency improvement rather than a consensus budget change. The measured gain is materially larger than the analyzer's 6% estimate, likely because the implementation also reduced ordinary metadata backing reads in this workload.",
  "db_queries": [
    {
      "purpose": "Envelope sanity for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5",
      "rows_returned": 5,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/70be8f204d8ef126069a4e69fb769884730aeeb954341b00b71842861b775eb5.csv"
    },
    {
      "purpose": "Block timing comparison for representative-heavy baseline run 8 vs candidate run 11",
      "query_digest": "2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2f8b9ecde371bd57a20110ef7ebc441d36bea31e28c27f6fc0eeaa08911c4035.csv"
    },
    {
      "purpose": "Suspected span comparison for get_data between baseline run 8 and candidate run 11",
      "query_digest": "fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522",
      "rows_returned": 4,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/fdfc74f2b83d52455711ac6b8203767e817ca353415310df2777efd31c780522.csv"
    },
    {
      "purpose": "Suspected span comparison for get_value between baseline run 8 and candidate run 11",
      "query_digest": "77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/77e36367c5f66f9712d1e380aa54a0fdc02ede9744d2459f59732ebf16c95584.csv"
    },
    {
      "purpose": "Suspected span comparison for get_by_key between baseline run 8 and candidate run 11",
      "query_digest": "48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/48dbf2aa49d06539149ace1d9a7661a65feae1fa84690d9ac54e286b6bbb9c66.csv"
    },
    {
      "purpose": "Suspected span comparison for get_path between baseline run 8 and candidate run 11",
      "query_digest": "15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/15b41de8ddba6efceca6a59d808f93ab4a216b315e507e249d7380dde1e826b1.csv"
    },
    {
      "purpose": "Suspected span comparison for walk between baseline run 8 and candidate run 11",
      "query_digest": "4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/4e02f95a3b512c59f0216c38eefcab691b744c4ff6cff9a81614286ba151942f.csv"
    },
    {
      "purpose": "Suspected span comparison for walk_backptr between baseline run 8 and candidate run 11",
      "query_digest": "731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac",
      "rows_returned": 2,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/731de1b8675c245c12b201a68c3120e51ab2dddc58915bb799363c0f7f71b5ac.csv"
    },
    {
      "purpose": "Baseline top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/5ccd5058aaf110465637b8c740893608e42547473aaa2af4839c1a91f032f069.csv"
    },
    {
      "purpose": "Baseline top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/aeb0d263e268692a00f782d67e0cbe15d637c6f0d38245f3b9240636ce1ff8d4.csv"
    },
    {
      "purpose": "Baseline transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/c10c09eb9723a9e4dd63b9d1662786b0d13c5ecc02867801a9af417af3aaccc4.csv"
    },
    {
      "purpose": "Candidate top contract-call wall-time ranking for dual-stacking replay",
      "query_digest": "6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/6ea7636c5cb2fa3320f5d344f931b8b581234f66341eb6da1838c9f2319ce36d.csv"
    },
    {
      "purpose": "Candidate top Clarity-cost ranking for dual-stacking replay",
      "query_digest": "f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5",
      "rows_returned": 1,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/f1fe1c88dd2717a808668cf1ce0588308b4fa52d553abafa2c0bd7f661ee8ff5.csv"
    },
    {
      "purpose": "Candidate transaction list for dual-stacking capture-snapshot-balances-optimizer",
      "query_digest": "ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89",
      "rows_returned": 100,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/ff04c7cf066e8061125cc2aeb1572fc229ea534c070df0cdca2af8a8231e0c89.csv"
    },
    {
      "purpose": "Exact replay tx latency comparison for the five representative txids",
      "query_digest": "2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742",
      "rows_returned": 6,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/2815b269592e2548e6026871d8a274a85108c488e14df209ef50bb9137271742.csv"
    },
    {
      "purpose": "Trace-level mechanism summary for target txids across at-block and suspected storage spans",
      "query_digest": "99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3",
      "rows_returned": 15,
      "output_path": "analyze/rollback-wrapper-at-block-read-cache/queries/99ced0f4ff30b6b9c53dd6222d76201a97b0b2fe2bf66cafd9636f87c4c07ba3.csv"
    }
  ]
}` is `{}` (no verdict was produced
  for this `normal_pr` target — typically because Phase 3.5 was
  skipped or the agent failed) you MUST NOT publish a PR. Surface
  this gap as a `## Benchmark result` paragraph that says
  "Results-analyzer did not produce a verdict for this target; the
  measured `improvement_pct` from `{
  "target_id": "rollback-wrapper-at-block-read-cache",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    11
  ],
  "baseline_run_ids": [
    8
  ],
  "improvement_pct": 27.22,
  "base_sha": "f4cab0a011e273e1f1f9b5249afee2fba6123da5",
  "head_sha": "fdfafc482a765472e4b2f7da1611c65eb67fe2c3"
}` has not
  been judged against the analyzer's `expected_signal`. Hold for
  operator review." Operator review will decide whether to re-run
  Phase 3.5 or ship without a verdict.
- For `consensus_poc_pr`: `{
  "target_id": "rollback-wrapper-at-block-read-cache",
  "delivery_mode": "normal_pr",
  "status": "accepted",
  "run_ids": [
    11
  ],
  "baseline_run_ids": [
    8
  ],
  "improvement_pct": 27.22,
  "base_sha": "f4cab0a011e273e1f1f9b5249afee2fba6123da5",
  "head_sha": "fdfafc482a765472e4b2f7da1611c65eb67fe2c3"
}` is `{}` (no benchmark ran). Do NOT invent improvement numbers. State explicitly that the benchmark was skipped by design (the harness encodes pre-change consensus). Cite the analyzer's `expected_improvement` vector from `{
  "id": "rollback-wrapper-at-block-read-cache",
  "merged_from": [
    {
      "family_id": "dual-stacking-snapshot-balance-fanout",
      "target_index": 0
    }
  ],
  "convergence_count": 1,
  "target_span": "get_data",
  "bucket": "block_processing",
  "hotspot": {
    "span": "get_data",
    "self_wall_us": 5517700,
    "total_wall_us": 531004890,
    "calls": 11318323,
    "location": "stackslib/src/clarity_vm/database/marf.rs:852"
  },
  "files": [
    "clarity/src/vm/database/key_value_wrapper.rs",
    "stackslib/src/clarity_vm/database/marf.rs",
    "clarity/src/vm/contexts.rs",
    "clarity/src/vm/database/clarity_db.rs"
  ],
  "evidence": "All five representatives follow the same tree: Transaction -> try_mine_tx_with_len -> with_abort_callback -> execute-contract dual-stacking-v2_1_0.capture-snapshot-balances-optimizer -> map -> capture-participant-balances-optimizer -> capture-participant-snapshot. The hot child is 60 at-block evaluations per tx, totaling about 1.48s-1.56s of nested work in the trace summaries. Under those at-block closures, repeated get_data/get_value calls enter PersistentWritableMarfStore::get_data and then MARF get_by_key/get_path/walk/walk_backptr. Representative totals for PersistentWritableMarfStore::get_data are about 478ms-539ms per tx with roughly 2,960-3,165 calls, while MARF get_by_key/get_path/walk totals are about 548ms-596ms per tx with roughly 4,900-5,200 calls. Code confirms the handle: ExecutionState::evaluate_at_block sets a historical block hash with query_pending_data=false, RollbackWrapper then bypasses pending writes and calls the backing store for every materialized read, and PersistentWritableMarfStore::get_data performs marf.get(chain_tip, key) plus side-store lookup. The existing RollbackWrapper maps only cache pending writes, not materialized historical store reads. The top Clarity-cost query shows this family's max axis share is 5.48%, so this target moves wall-time latency, not tenure budget.",
  "evidence_queries": [
    {
      "purpose": "Confirm the family size, top representative durations, and stable per-call Clarity read shape.",
      "sql_path": "queries/txs_for_contract.sql",
      "params": {
        "contract_name": "dual-stacking-v2_1_0",
        "function_name": "capture-snapshot-balances-optimizer",
        "issuer_address": "SP1HFCRKEJ8BYW4D0E3FAWHFDX8A25PPAA83HWWZ9",
        "limit": "100",
        "run_id": "6"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/dual-stacking-txs.csv",
      "key_observation": "59 calls; top five representative durations are 1688.226ms, 1627.729ms, 1615.264ms, 1610.986ms, and 1605.459ms, with about 5.5k read_count each.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Place this contract function in the run-level latency distribution.",
      "sql_path": "queries/top_contract_calls.sql",
      "params": {
        "limit": "50",
        "run_id": "6"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/top-contract-calls.csv",
      "key_observation": "dual-stacking-v2_1_0.capture-snapshot-balances-optimizer ranks 4th by contract-call wall time with 59 calls, 83449.53ms total, and 1414.399ms average.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Confirm this is not a tenure-throughput target on a binding Clarity-cost axis.",
      "sql_path": "queries/top_clarity_consumers_by_contract.sql",
      "params": {
        "limit": "50",
        "run_id": "6"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/top-clarity-consumers.csv",
      "key_observation": "family max_axis_share_pct is 5.48%; runtime is the largest family share at 5.48%, while read_length is 1.98%, write_count 0.55%, and write_length 0.21%.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Identify the shared storage spans the target should move.",
      "sql_path": "queries/top_spans_by_self_wall.sql",
      "params": {
        "limit": "60",
        "run_id": "6"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/top-spans-self.csv",
      "key_observation": "PersistentWritableMarfStore::get_data has 531004.89ms total wall over 11318323 calls; Trie::walk_backptr has 932669.18ms self wall over 48440451 calls.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0x9728154c and confirm at-block historical reads dominate the tx tree.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "9728154c1239b04662827d03388ded4608eb53f42f24f36c7a0c9f05d5478a23"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-9728154c.csv",
      "key_observation": "tx wall is 1688.226ms; capture-participant-snapshot is 1643.659ms; trace aggregation shows 60 at-block calls totaling 1562.102ms and PersistentWritableMarfStore::get_data rows totaling 489.411ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0xac4eaf26 and confirm the same at-block/MARF read shape.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "ac4eaf264a66347202d171f77b1e88dde72e1aff48000e83b343ef62e15e235a"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-ac4eaf26.csv",
      "key_observation": "tx wall is 1627.729ms; capture-participant-snapshot is 1589.582ms; trace aggregation shows 60 at-block calls totaling 1509.249ms and PersistentWritableMarfStore::get_data rows totaling 485.349ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0xbd001e97 and confirm the same at-block/MARF read shape.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "bd001e976f03206f10e6404abe289f73e8a3c4da8db5ac7d035763c0bee65171"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-bd001e97.csv",
      "key_observation": "tx wall is 1615.264ms; capture-participant-snapshot is 1573.540ms; trace aggregation shows 60 at-block calls totaling 1497.216ms and PersistentWritableMarfStore::get_data rows totaling 484.760ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0x7b5f49a4 and confirm the same at-block/MARF read shape.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "7b5f49a4fdc3164fc923982d7619608831c0847c476d4761708d75fc5df1f3fa"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-7b5f49a4.csv",
      "key_observation": "tx wall is 1610.986ms; capture-participant-snapshot is 1574.605ms; trace aggregation shows 60 at-block calls totaling 1497.446ms and PersistentWritableMarfStore::get_data rows totaling 538.753ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    },
    {
      "purpose": "Inspect representative 0x695be269 and confirm the same at-block/MARF read shape.",
      "sql_path": "queries/profiler_trace_tx.sql",
      "params": {
        "max_rows": "2000",
        "min_wall_ms": "1",
        "run_id": "6",
        "stacks_tx_hash": "695be269b728d5d55e07191115d513658a05dd97e266e59506cc38e3f733c11a"
      },
      "output_path": "analysis/dual-stacking-snapshot-balance-fanout/queries/trace-tx-695be269.csv",
      "key_observation": "tx wall is 1605.459ms; capture-participant-snapshot is 1568.942ms; trace aggregation shows 60 at-block calls totaling 1482.623ms and PersistentWritableMarfStore::get_data rows totaling 478.082ms.",
      "supports_invocations": [
        "representative-heavy"
      ]
    }
  ],
  "proposed_change": "Add a transaction-local read-through cache to RollbackWrapper for materialized backing-store reads while query_pending_data is false. Track the active block hash after successful set_block_hash, and cache raw store results by (active_block_hash, key) for get_data/get_value and by (active_block_hash, contract, metadata_key) for metadata reads. Do not cache reads that consult pending data, do not cache proof reads, and clear or scope the cache with the RollbackWrapper lifetime so it cannot cross transactions. Refactor get_data and get_value through a shared raw-read helper so cached hex/string values still deserialize through the existing Clarity type paths and preserve cost accounting.",
  "expected_improvement": {
    "tx_latency": 6.0,
    "tenure_throughput": 0.0,
    "commit_time": 0.0
  },
  "risk": "medium",
  "verification_plan": "Add focused RollbackWrapper/ClarityDatabase tests that repeated at-block reads return the same values before and after pending writes in the surrounding tx, that restored block hash resumes pending-data visibility, and that metadata and value reads remain isolated by block hash. Then run targeted replay on the representative txids and compare get_data, get_by_key, walk, walk_backptr, and tx latency.",
  "verification_replay": {
    "rationale": "The cache is intra-transaction, so the representative tx replay directly measures whether repeated at-block historical reads avoid backing MARF work.",
    "invocations": [
      {
        "id": "representative-heavy",
        "label": "representative heavy txs",
        "purpose": "Measure tx-latency and MARF-read reduction on the five triaged snapshot optimizer transactions.",
        "samples": {
          "kind": "txids",
          "txids": [
            "0x9728154c1239b04662827d03388ded4608eb53f42f24f36c7a0c9f05d5478a23",
            "0xac4eaf264a66347202d171f77b1e88dde72e1aff48000e83b343ef62e15e235a",
            "0xbd001e976f03206f10e6404abe289f73e8a3c4da8db5ac7d035763c0bee65171",
            "0x7b5f49a4fdc3164fc923982d7619608831c0847c476d4761708d75fc5df1f3fa",
            "0x695be269b728d5d55e07191115d513658a05dd97e266e59506cc38e3f733c11a"
          ]
        },
        "warmup": 0,
        "repetitions": 20,
        "profiler": "rich",
        "expected_signal": {
          "axis": "tx_latency",
          "direction": "improves",
          "estimate_pct": 6.0,
          "tolerance_pct": 4.0
        }
      }
    ],
    "suspected_spans": [
      "get_data",
      "get_value",
      "get_by_key",
      "get_path",
      "walk",
      "walk_backptr"
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
