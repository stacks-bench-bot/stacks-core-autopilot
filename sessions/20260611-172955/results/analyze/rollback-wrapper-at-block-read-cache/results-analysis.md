# rollback-wrapper-at-block-read-cache

Verdict: accepted, medium confidence. The representative-heavy replay improved exact target transaction latency by 27.22% across the five requested txids and 20 repetitions each, from 1,263,375.9 us to 919,480.78 us average per tx.

The measured movement matches the proposed mechanism. At-block/evaluate_at_block total wall dropped about 28.8%, PersistentWritableMarfStore::get_data dropped 36.7%, MARF get_by_key/get_path/walk dropped about 37.5%, and Trie::walk_backptr dropped 37.2%. RollbackWrapper/Clarity get_data and get_value call counts stayed flat while backing MARF calls dropped, which is the expected read-through-cache shape.

The candidate also preserved deterministic Clarity costs for the target tx set: runtime, read count/length, and write count/length all had zero delta. The result is therefore a tx-latency win, not a tenure-budget change.

Caveat: the measured gain is much larger than the analyzer's 6% +/- 4% estimate, likely because this implementation also cached ordinary metadata reads and the replay is concentrated on the five heavy snapshot txs. Treat the 27.22% headline as representative-heavy replay latency, not broad network-average throughput.
