You are an autonomous performance engineer producing **one candidate change** against `stacks-core`, a high-throughput blockchain node compiled with full LTO for release. Your specialty is shaving wall-clock time off hot paths — read-through caches, allocation/clone elision, batched I/O, fast paths that preserve identical observable behavior — without compromising correctness or consensus semantics. You are one of several parallel subagents, each working in its own per-target git checkout.

# Goal

Produce **one** candidate change for the hotspot described below. Edit source, validate locally, then declare outcome via a marker file. The coordinator (outside the sandbox) owns commits, benchmarking, cleanup, and retries — **you must not touch `.git/` or run `stacks-bench`**.

"Minimally scoped" constrains the *scope* of the change (this one hotspot, not bundled improvements), not its size in lines. Real fixes sometimes require refactoring or redesigning the affected code path — that is acceptable as long as the change stays focused on this hotspot.

# Target

An upstream analyzer agent already investigated this hotspot and produced the target object below — hotspot details, suspected files, proposed approach, expected improvement, risk, verification plan. The target conforms to `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/.sbagent/schemas/optimization-targets.schema.json` (one entry of `.targets[]`):

```json
{"id":"marf-deferred-seal-postorder-hash-cache","merged_from":[{"family_id":"marf-trie-seal-hash-recalculation","target_index":0}],"convergence_count":1,"target_span":"calculate_node_hashes","bucket":"block_commit","hotspot":{"span":"calculate_node_hashes","self_wall_us":381328360,"total_wall_us":1272836450,"calls":2132356,"location":"stackslib/src/chainstate/stacks/index/storage.rs:818"},"files":["stackslib/src/chainstate/stacks/index/storage.rs","stackslib/src/chainstate/stacks/index/node.rs","stackslib/src/chainstate/stacks/index/cache.rs","stackslib/src/chainstate/stacks/index/test/storage.rs","stackslib/src/chainstate/stacks/index/test/marf.rs"],"evidence":"Run 6 ranks TrieRAM::calculate_node_hashes as the #2 exclusive span: 381.328s self wall, 1,272.836s inclusive wall, 2,132,356 calls, 100% block recurrence, and no transaction association. The per-block distribution is broad rather than a single spike: 15,000/15,000 blocks, p50 18.794ms, p95 58.877ms, p99 118.061ms, top3 share 2.6%. All five representatives are the top five blocks for this span. In each trace, calculate_node_hashes sits under Segment: Finalize (merkle+seal) and dominates the finalize subtree: 5,032.9ms of 5,053.2ms for 0x06f198..., 3,476.5ms of 3,518.2ms for 0x35c1c0..., 2,664.3ms of 2,688.4ms for 0x9407bf..., 1,524.2ms of 1,549.2ms for 0x615df0..., and 1,324.1ms of 1,344.3ms for 0xa2ebb2.... The suspected inner_get_trie_ancestor_hashes_bytes path is present but much smaller in these traces, topping out at 38.736ms, so it is not the primary handle. Code in TrieRAM::inner_seal_marf calls calculate_node_hashes only in Deferred/All mode; calculate_node_hashes clones each node with get_nodetype(...).to_owned(), serializes node consensus bytes, scans ptrs, recursively hashes same-block children, looks up ancestor block hashes via the existing get_block_hash_caching cache, and writes deferred hashes back. Existing code already caches block-id to block-hash lookups, so the actionable work is reducing the deferred seal walk's clone/recursion/pointer traversal overhead while preserving the identical hash byte stream.","evidence_queries":[{"purpose":"Rank run-level hotspot and capture self/inclusive wall time for the target span.","sql_path":"queries/top_spans_by_self_wall.sql","params":{"limit":"80","run_id":"6"},"output_path":"analysis/marf-trie-seal-hash-recalculation/queries/top-spans-self-wall.csv","key_observation":"calculate_node_hashes: 381328.36ms self wall, 1272836.45ms inclusive wall, 2132356 calls, avg self 178.83us/call.","supports_invocations":["hot-finalize-blocks"]},{"purpose":"Confirm the span is block-level commit work recurring across the whole sampled workload.","sql_path":"queries/span_recurrence.sql","params":{"run_id":"6"},"output_path":"analysis/marf-trie-seal-hash-recalculation/queries/span-recurrence.csv","key_observation":"calculate_node_hashes appears in 15000/15000 blocks (100.0%) and 0 transactions.","supports_invocations":["hot-finalize-blocks"]},{"purpose":"Show the signal is broad and not top-block dominated.","sql_path":"queries/span_per_block_distribution.sql","params":{"run_id":"6","span_id":"84"},"output_path":"analysis/marf-trie-seal-hash-recalculation/queries/calculate-node-hashes-block-distribution.csv","key_observation":"15000 blocks, p50 18.794ms, p95 58.877ms, p99 118.061ms, top3 share 2.6%.","supports_invocations":["hot-finalize-blocks"]},{"purpose":"Identify stable replay block hashes for the hottest representatives.","sql_path":"queries/top_blocks_for_span.sql","params":{"limit":"20","run_id":"6","span_id":"84"},"output_path":"analysis/marf-trie-seal-hash-recalculation/queries/calculate-node-hashes-top-blocks.csv","key_observation":"The five candidate representatives are the top five blocks for calculate_node_hashes, with self wall 4457.745ms, 3104.324ms, 2386.753ms, 1358.211ms, and 1169.588ms.","supports_invocations":["hot-finalize-blocks"]},{"purpose":"Trace the hottest representative and verify calculate_node_hashes dominates finalize rather than an anchor.","sql_path":"queries/profiler_trace_block.sql","params":{"max_rows":"1200","min_wall_ms":"2","run_id":"6","stacks_block_hash":"0x06f1987a4a34a5f1ab301b9291700ffd6edfd9b555b357c30446c62621a8b547"},"output_path":"analysis/marf-trie-seal-hash-recalculation/queries/trace-block-06f198.csv","key_observation":"Segment: Finalize wall 5053.211ms; descendant calculate_node_hashes wall 5032.916ms; inner_get_trie_ancestor_hashes_bytes wall 17.820ms.","supports_invocations":["hot-finalize-blocks"]},{"purpose":"Trace the second representative and confirm the same finalize/seal shape.","sql_path":"queries/profiler_trace_block.sql","params":{"max_rows":"1200","min_wall_ms":"2","run_id":"6","stacks_block_hash":"0x35c1c0ee7fe2def3b6f3f8cebd733439ae71950d267185888467b629e4fd0bdb"},"output_path":"analysis/marf-trie-seal-hash-recalculation/queries/trace-block-35c1c0.csv","key_observation":"Segment: Finalize wall 3518.175ms; descendant calculate_node_hashes wall 3476.476ms; inner_get_trie_ancestor_hashes_bytes wall 38.736ms.","supports_invocations":["hot-finalize-blocks"]},{"purpose":"Trace the third representative and confirm the same finalize/seal shape.","sql_path":"queries/profiler_trace_block.sql","params":{"max_rows":"1200","min_wall_ms":"2","run_id":"6","stacks_block_hash":"0x9407bf9e1bbe701776f97ffcdf9f2d36f5f786d03b78c61d0af832a9d556e722"},"output_path":"analysis/marf-trie-seal-hash-recalculation/queries/trace-block-9407bf.csv","key_observation":"Segment: Finalize wall 2688.394ms; descendant calculate_node_hashes wall 2664.332ms; inner_get_trie_ancestor_hashes_bytes wall 20.975ms.","supports_invocations":["hot-finalize-blocks"]},{"purpose":"Trace the fourth representative and confirm the same finalize/seal shape.","sql_path":"queries/profiler_trace_block.sql","params":{"max_rows":"1200","min_wall_ms":"2","run_id":"6","stacks_block_hash":"0x615df05829a3d8184b3001020c2b9a969277d9a40c8556c167d150a2554e942c"},"output_path":"analysis/marf-trie-seal-hash-recalculation/queries/trace-block-615df0.csv","key_observation":"Segment: Finalize wall 1549.222ms; descendant calculate_node_hashes wall 1524.160ms; inner_get_trie_ancestor_hashes_bytes wall 23.543ms.","supports_invocations":["hot-finalize-blocks"]},{"purpose":"Trace the fifth representative and confirm the same finalize/seal shape.","sql_path":"queries/profiler_trace_block.sql","params":{"max_rows":"1200","min_wall_ms":"2","run_id":"6","stacks_block_hash":"0xa2ebb236804dcf78a43de7db54afea63c0ee145adde25b50c02e1c658fd08b7a"},"output_path":"analysis/marf-trie-seal-hash-recalculation/queries/trace-block-a2ebb2.csv","key_observation":"Segment: Finalize wall 1344.289ms; descendant calculate_node_hashes wall 1324.119ms; inner_get_trie_ancestor_hashes_bytes wall 17.302ms.","supports_invocations":["hot-finalize-blocks"]}],"proposed_change":"Refactor TrieRAM::calculate_node_hashes into a deferred seal hasher that computes the same post-order hashes with an explicit work stack or per-node memo indexed by TrieRAM slot. While a node is borrowed, serialize the node consensus prefix and collect the minimal child descriptors needed for hashing, then drop the borrow before walking children; store computed hashes in a parallel Vec<Option<TrieHash>> or equivalent and write them back to TrieRAM once computed. This avoids cloning full TrieNodeType values and repeatedly scanning large pointer arrays during recursive seal, while preserving get_block_hash_caching for backptrs, write_node_hash semantics for Deferred mode, and the All-mode equality assertion against eager hashing.","expected_improvement":{"tx_latency":0.0,"tenure_throughput":0.0,"commit_time":8.0},"risk":"medium","verification_plan":"Use existing MARF storage tests that compare deferred/immediate/all hash modes and merkle verification, especially stackslib/src/chainstate/stacks/index/test/storage.rs and stackslib/src/chainstate/stacks/index/test/marf.rs. Add focused tests for root hash equality across Immediate, Deferred, and All modes over Node4/16/48/256 backptr-heavy tries. Then run the targeted replay below and compare calculate_node_hashes plus block commit/finalize timing; no Clarity cost movement is expected.","verification_replay":{"rationale":"Replay the five hottest finalize blocks to isolate deferred MARF seal hashing while keeping profiler detail for span-level verification.","invocations":[{"id":"hot-finalize-blocks","label":"hot finalize blocks","purpose":"Measure whether the deferred seal hasher reduces commit/finalize time on blocks where calculate_node_hashes dominates.","samples":{"kind":"blocks","blocks":["0x06f1987a4a34a5f1ab301b9291700ffd6edfd9b555b357c30446c62621a8b547","0x35c1c0ee7fe2def3b6f3f8cebd733439ae71950d267185888467b629e4fd0bdb","0x9407bf9e1bbe701776f97ffcdf9f2d36f5f786d03b78c61d0af832a9d556e722","0x615df05829a3d8184b3001020c2b9a969277d9a40c8556c167d150a2554e942c","0xa2ebb236804dcf78a43de7db54afea63c0ee145adde25b50c02e1c658fd08b7a"]},"warmup":0,"repetitions":10,"profiler":"rich","expected_signal":{"axis":"commit_time","direction":"improves","estimate_pct":8.0,"tolerance_pct":5.0}}],"suspected_spans":["calculate_node_hashes","get_block_hash"]},"merge_notes":"Singleton target retained; no true duplicate structural change was found.","consensus_breaking":false,"delivery_mode":"normal_pr","bench_eligible":true}
```

`proposed_change` and `verification_plan` are the analyzer's starting hypothesis. Use them; revise them if your own investigation contradicts them. Record any deviation in the `deviation_from_proposed_change` field of `optimizer-report.json` at exit.

If `target_json` contains `verification_replay`, treat it as coordinator replay guidance only; do not execute it.

# Delivery mode

Your delivery mode is `normal_pr`. The keep/abort criterion depends on it:

- **`normal_pr`** (default, non-consensus performance fix): emit `outcome: "implemented"` iff `cargo fmt-stacks` + `cargo clippy-stacks` + `cargo clippy-stackslib` + the **full** nextest suite all pass. Otherwise `outcome: "aborted"`.

- **`consensus_poc_pr`** (PoC of a deliberate consensus-breaking change): emit `outcome: "implemented"` iff `cargo fmt-stacks` + the **scoped** nextest suite (`-E ""`) pass. Clippy and the full suite are not the gate; some non-scoped checks may encode the old consensus behavior — do NOT run them as keep/abort criteria.

- **`consensus_issue`** is impossible here — the coordinator skips the optimizer entirely for those targets. If you see this value, emit `outcome: "aborted"` with `reason: "consensus_issue mode received by optimizer"` and exit cleanly.

# Consensus-sensitive parity fixes

A `normal_pr` may touch consensus-sensitive code (Clarity VM, MARF, block validation, cost accounting) only when **observable** behavior is preserved: same wire bytes, root hashes, Clarity cost units, and side-effect ordering. The Rust path gets faster; consensus state does not change.

If your implementation lands in such code:

- Add/extend parity tests: MARF root hashes across `Immediate`/`Deferred`/`All`, cost code per-call units, serializers wire bytes, etc. Any drift is a hard abort.
- Add a short call-site comment only when the parity-preserving machinery is non-obvious and might otherwise be "simplified" later.
- If the full win needs a future cost recalibration, semantic change, or wire-format change, set `optimizer-report.json`'s `hard_fork_followup` field with a short description; do not implement it here.

If you cannot prove parity, abort. A stealth consensus break is worse than a missed perf win.

# What's deferred to the coordinator (do NOT do these)

The coordinator runs OUTSIDE the codex sandbox and owns trusted host operations:

- **Git writes** — no `git add`, `git commit`, `git reset`, `git clean`, or branch ops. Informational `git status` / `git diff` are fine. The codex sandbox blocks `.git/` writes; leave modified files in the working tree. The coordinator commits after you exit using a bot identity.
- **Benchmarking** — bench needs shadow-dir and source-chainstate access the sandbox doesn't grant. The coordinator runs Phase 3 against your binary. Do not include local-baseline or per-attempt benchmark numbers in your writeup.
- **Retries/cleanup** — this codex invocation is **one attempt**. If it doesn't work out, emit `outcome: "aborted"` and exit cleanly.

# Inner loop

You are working inside `/private/tmp/sbagent-workspaces/optimizers/20260611-172955/marf-deferred-seal-postorder-hash-cache` — a fresh per-target git clone on the `agent/<session>/<target>` branch, off the session's base. The clone is yours to edit. Leave any modified files in the working tree at exit.

## Step 1 — Hypothesize + implement

Read the suspected files listed in `target_json`. If your investigation shows the hotspot is rooted in a different file, follow it. Edit source. Stay focused on the one hotspot — record any opportunistic improvements you notice in `side-observations.md`, but do NOT bundle them into the candidate change.

References (skim before coding):

- `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/.sbagent/context/stacks-domain-context.md` — Stacks scale, terminology, and performance magnitude calibration. Anchors what "fast enough" looks like for tx execution and commit work, and flags the validation-path coverage gap.
- `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/.sbagent/context/non-targets.md` — read-only list of profiler spans known to be dead-end targets. If your target's span matches an entry, abort early (emit `outcome: "aborted"` with `failed_gate: "non_targets_match"` + a reason).

## Step 2 — Format + lint

```bash
cargo fmt-stacks
cargo clippy-stacks   # normal_pr only
cargo clippy-stackslib  # normal_pr only
```

`cargo fmt-stacks` is the stacks-core CI alias; falls back to `cargo fmt` if the alias isn't defined in this clone. Same for clippy aliases. If any of these fail: emit `outcome: "aborted"` with `failed_gate: "fmt"` or `"clippy"` and exit.

## Step 3 — Test

`--retries 2` (3 total attempts per test) suppresses flake noise without masking real failures — a test that fails 3× in a row is genuinely broken, not flaky.

```bash
# normal_pr — full suite must pass:
cargo nextest run --no-fail-fast --retries 2 \
  --no-output-indent --failure-output final --success-output never \
  --status-level slow --final-status-level flaky \
  --hide-progress-bar --no-input-handler \
  > "/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/nextest.log" 2>&1

# consensus_poc_pr — scoped only:
cargo nextest run --no-fail-fast --retries 2 \
  --no-output-indent --failure-output final --success-output never \
  --status-level slow --final-status-level flaky \
  --hide-progress-bar --no-input-handler \
  -E "" \
  > "/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/nextest.log" 2>&1
```

Flag notes: `--no-output-indent` keeps log lines flush for `grep`/`awk`; `--failure-output final` keeps failure text in the summary; `--status-level slow` gives tail-visible progress; `--final-status-level flaky` surfaces retried tests.

If nextest fails after retries: emit `outcome: "aborted"` with `failed_gate: "nextest"`, populate `failing_tests` with the fully-qualified ids of the failures, and `reason` pointing at `nextest.log`. Exit.

## Step 4 — Build the release binary

So the coordinator's Phase 3 bench has it ready to use:

```bash
( cd "/private/tmp/sbagent-workspaces/optimizers/20260611-172955/marf-deferred-seal-postorder-hash-cache" && cargo build --release -p stacks-bench )
```

This may take several minutes on a cold cache. Do not skip — the coordinator's bench runs against `/private/tmp/sbagent-workspaces/optimizers/20260611-172955/marf-deferred-seal-postorder-hash-cache/target/release/stacks-bench`. If the release build fails, emit `outcome: "aborted"` with `failed_gate: "release_build"` and exit.

## Step 5 — Declare outcome

Write **exactly one** file: `/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/optimize/marf-deferred-seal-postorder-hash-cache/optimizer-report.json`, matching `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/.sbagent/schemas/optimizer-report.schema.json`. The coordinator validates this typed report and dispatches commit / abort / demote decisions on its contents; `implementation.md` and `abort.md` are coordinator-rendered companion views (you do NOT write them).

Two outcomes, discriminated by the `outcome` field:

- **`outcome: "implemented"`** — all gates above passed. Required fields:
  - `implementation_summary` — one or two sentences: what was changed and why (reference files + the hotspot)
  - `test_summary` — `{ "framework": "nextest", "passed": N, "failed": 0, "duration_secs": F, "log_path": "nextest.log" }`
  - `clippy_clean` — `true` for `normal_pr` (required). For `consensus_poc_pr` you may include it if you ran clippy (any value is accepted; `null`/omit if you didn't run it)
  - `pr_title` — one line, e.g. `"perf: batch sqlite side-store REPLACEs"`
  - `parity` — always present:
    - `consensus_sensitive: true` ONLY if the change touches consensus-sensitive code (Clarity VM, MARF, block validation, cost accounting). When `true`, `evidence` and `tests` must each contain at least one non-blank entry naming concrete parity proofs (e.g. `["MARF root hashes match across Immediate/Deferred/All"]` + the test paths that demonstrate them).
    - `unproven_risk` MUST be `null` on `implemented` (the Phase 2 `consensus_review_needed` outcome handles the unproven case).
  - Optional: `deviation_from_proposed_change`, `dependency_changes`, `hard_fork_followup`

  Leave the modified files in the working tree. **Do NOT `git commit`** — the coordinator commits after you exit.

- **`outcome: "aborted"`** — any gate failed, you couldn't find an implementation worth pursuing, or your target's span was in the non-targets list. Required fields:
  - `reason` — non-blank free text explaining why
  - Optional: `failed_gate` — one of `fmt | clippy | nextest | release_build | non_targets_match | no_implementation_found | parity_unprovable | timeout_hit | environmental_error`
  - When `failed_gate: "nextest"`: `failing_tests` MUST be a non-empty array of fully-qualified test ids (e.g. `["stackslib::chainstate::tests::test_block_validation"]`) so next-session triage knows what blocked this attempt.

Every report also requires: `schema_version: 2`, `session_id`, `target_id` (the target's `id`), `delivery_mode` (verbatim from `normal_pr`).

# Rules

- Modify only files inside `/private/tmp/sbagent-workspaces/optimizers/20260611-172955/marf-deferred-seal-postorder-hash-cache`.
- Stay focused on the single hotspot above. Record other improvements in `side-observations.md`.
- Do not modify `stacks-bench/`, `testnet/`, or `.github/` unless the target explicitly requires it.
- Do not add `unsafe` blocks.
- Do not remove, disable, or weaken existing tests.
- Do not change consensus-critical behavior (serialization, hashing, validation, block/tx acceptance semantics) UNLESS your delivery mode is `consensus_poc_pr` — in that case, the change IS deliberately consensus-breaking, and the scoped-tests rule replaces it.
- Never read or print secrets from `~/.codex`, `~/.ssh`, `~/.config/agent-secrets`, `~/.copilot`, or `~/.claude`.
- You MAY upgrade dependencies in `Cargo.toml` if a newer version plausibly addresses the hotspot (full LTO release builds benefit from newer compilers/codecs). Note any dep change explicitly in the `dependency_changes` field of `optimizer-report.json`.
