# marf-deferred-seal-postorder-hash-cache

Verdict: **mixed** with **medium** confidence.

The candidate moved the intended MARF seal hashing mechanism, but the commit-axis result is smaller than the analyzer hypothesis. Baseline run `9` and candidate run `12` both completed cleanly with 50 measured blocks and 210 transactions. Average commit time improved from `108833.94us` to `107741.78us` per block, a `1.004%` gain versus the expected `8% +/- 5%`.

Mechanism evidence is positive: `calculate_node_hashes` exclusive wall improved `5.174%` and calls dropped from `83094` to `100`, consistent with replacing recursive per-node hashing with an explicit post-order pass. `get_block_hash` also improved `3.488%`.

The per-block shape is uneven. Commit time improved `6.696%` on `9407bf...`, `1.430%` on `06f198...`, `0.458%` on `615df0...`, and `0.164%` on `35c1c0...`, but regressed `2.806%` on `a2ebb2...`.

Operator note: this is not a clean accept because the macro commit-time result misses the expected tolerance window. If shipped, carry the caveat that the implementation has a real span-level win but only a modest measured commit-time gain on this replay.
