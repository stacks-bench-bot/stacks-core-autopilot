# clarity-side-store-bulk-put

Verdict: accepted, high confidence. The write-heavy replay matched the expected tx-latency signal: baseline run 7 and candidate run 10 both completed successfully without interruption, and candidate tx execution latency improved by 4.18% against the expected 5% +/- 4% band.

Mechanism evidence lines up with the change. The old per-item `SqliteConnection::put` span had 3.139 s self wall across 118,300 calls in the baseline and is absent in the candidate; the replacement `SqliteConnection::put_many` path has 2.940 s self wall across 240 batch calls. The parent `PersistentWritableMarfStore::put_all_data` span improved 6.92% total wall time, from 5.110 s to 4.756 s.

Per-tx averages all moved positive: `37ad67a3` improved 4.842%, `408f81be` improved 5.184%, `92639041` improved 3.286%, and `9f0416be` improved 3.507%. Whole-block total time improved 3.544%.

Caveat: commit time regressed 3.619% per block, partially offsetting the execution gain at the full-block level. `put_many` also remains a top candidate span, so batching reduced overhead but did not remove SQLite write cost.
