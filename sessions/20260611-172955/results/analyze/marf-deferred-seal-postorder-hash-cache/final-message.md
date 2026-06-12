Wrote both artifacts:

- [results-analysis.json](/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/analyze/marf-deferred-seal-postorder-hash-cache/results-analysis.json)
- [results-analysis.md](/private/tmp/sbagent-workspaces/sessions/20260611-172955/results/analyze/marf-deferred-seal-postorder-hash-cache/results-analysis.md)

Verdict is `mixed` with `medium` confidence. The mechanism moved (`calculate_node_hashes` self wall improved `5.174%`), but commit time improved only `1.004%`, below the expected `8% +/- 5%` window.

Validation: `results-analysis.json` is valid against the provided schema. No tests or benchmarks were run.