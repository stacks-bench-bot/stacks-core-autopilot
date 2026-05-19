Implemented the candidate change and wrote the coordinator report.

Changed:
- [storage.rs](/private/tmp/sbagent-workspaces/optimizers/20260518-190321-nextest-flags-smoke/marf-deferred-node-hash-direct-digest/stackslib/src/chainstate/stacks/index/storage.rs): added direct `Digest::update` hashing for deferred MARF node consensus bytes and child hash appends.
- [test/storage.rs](/private/tmp/sbagent-workspaces/optimizers/20260518-190321-nextest-flags-smoke/marf-deferred-node-hash-direct-digest/stackslib/src/chainstate/stacks/index/test/storage.rs): added parity coverage against the existing consensus serializer for Node4/16/48/256.

Validation passed:
- `cargo fmt-stacks`
- `cargo clippy-stacks`
- `cargo clippy-stackslib`
- full `cargo nextest run`: 10490 passed, 0 failed, 847.405s
- `cargo build --release -p stacks-bench`

Report written: `/Users/cylwit/Code/github.com/stacks-bench-bot/stacks-core-autopilot/sessions/20260518-190321-nextest-flags-smoke/results/optimize/marf-deferred-node-hash-direct-digest/optimizer-report.json`