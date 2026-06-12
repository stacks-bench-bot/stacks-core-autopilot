-- Compare exact replay target transaction durations between baseline run 8 and candidate run 11.
WITH target_tx(tx_hash_hex) AS (
  VALUES
    ('9728154c1239b04662827d03388ded4608eb53f42f24f36c7a0c9f05d5478a23'),
    ('ac4eaf264a66347202d171f77b1e88dde72e1aff48000e83b343ef62e15e235a'),
    ('bd001e976f03206f10e6404abe289f73e8a3c4da8db5ac7d035763c0bee65171'),
    ('7b5f49a4fdc3164fc923982d7619608831c0847c476d4761708d75fc5df1f3fa'),
    ('695be269b728d5d55e07191115d513658a05dd97e266e59506cc38e3f733c11a')
), scoped AS (
  SELECT
    CASE sts.benchmark_run_id WHEN 8 THEN 'baseline' WHEN 11 THEN 'candidate' END AS side,
    tx.tx_hash_hex,
    sts.duration_us,
    sts.clarity_runtime,
    sts.clarity_read_count,
    sts.clarity_read_length,
    sts.clarity_write_count,
    sts.clarity_write_length
  FROM stacks_tx_stats AS sts
  JOIN stacks_tx AS tx ON tx.id = sts.stacks_tx_id
  JOIN target_tx AS tt ON tt.tx_hash_hex = tx.tx_hash_hex
  WHERE sts.benchmark_run_id IN (8, 11)
), per_hash AS (
  SELECT
    tx_hash_hex,
    side,
    COUNT(*) AS samples,
    AVG(duration_us) AS avg_duration_us,
    MIN(duration_us) AS min_duration_us,
    MAX(duration_us) AS max_duration_us,
    SUM(duration_us) AS total_duration_us,
    SUM(clarity_runtime) AS clarity_runtime,
    SUM(clarity_read_count) AS clarity_read_count,
    SUM(clarity_read_length) AS clarity_read_length,
    SUM(clarity_write_count) AS clarity_write_count,
    SUM(clarity_write_length) AS clarity_write_length
  FROM scoped
  GROUP BY tx_hash_hex, side
), paired AS (
  SELECT
    p.tx_hash_hex AS row_id,
    MAX(CASE WHEN side='baseline' THEN samples END) AS baseline_samples,
    MAX(CASE WHEN side='candidate' THEN samples END) AS candidate_samples,
    MAX(CASE WHEN side='baseline' THEN avg_duration_us END) AS baseline_avg_duration_us,
    MAX(CASE WHEN side='candidate' THEN avg_duration_us END) AS candidate_avg_duration_us,
    MAX(CASE WHEN side='baseline' THEN min_duration_us END) AS baseline_min_duration_us,
    MAX(CASE WHEN side='candidate' THEN min_duration_us END) AS candidate_min_duration_us,
    MAX(CASE WHEN side='baseline' THEN max_duration_us END) AS baseline_max_duration_us,
    MAX(CASE WHEN side='candidate' THEN max_duration_us END) AS candidate_max_duration_us,
    MAX(CASE WHEN side='baseline' THEN total_duration_us END) AS baseline_total_duration_us,
    MAX(CASE WHEN side='candidate' THEN total_duration_us END) AS candidate_total_duration_us,
    MAX(CASE WHEN side='baseline' THEN clarity_runtime END) AS baseline_clarity_runtime,
    MAX(CASE WHEN side='candidate' THEN clarity_runtime END) AS candidate_clarity_runtime,
    MAX(CASE WHEN side='baseline' THEN clarity_read_count END) AS baseline_clarity_read_count,
    MAX(CASE WHEN side='candidate' THEN clarity_read_count END) AS candidate_clarity_read_count,
    MAX(CASE WHEN side='baseline' THEN clarity_read_length END) AS baseline_clarity_read_length,
    MAX(CASE WHEN side='candidate' THEN clarity_read_length END) AS candidate_clarity_read_length,
    MAX(CASE WHEN side='baseline' THEN clarity_write_count END) AS baseline_clarity_write_count,
    MAX(CASE WHEN side='candidate' THEN clarity_write_count END) AS candidate_clarity_write_count,
    MAX(CASE WHEN side='baseline' THEN clarity_write_length END) AS baseline_clarity_write_length,
    MAX(CASE WHEN side='candidate' THEN clarity_write_length END) AS candidate_clarity_write_length
  FROM per_hash AS p
  GROUP BY p.tx_hash_hex
), overall AS (
  SELECT
    'ALL_TARGET_TXS' AS row_id,
    SUM(CASE WHEN side='baseline' THEN samples END) AS baseline_samples,
    SUM(CASE WHEN side='candidate' THEN samples END) AS candidate_samples,
    SUM(CASE WHEN side='baseline' THEN total_duration_us END) * 1.0 / NULLIF(SUM(CASE WHEN side='baseline' THEN samples END), 0) AS baseline_avg_duration_us,
    SUM(CASE WHEN side='candidate' THEN total_duration_us END) * 1.0 / NULLIF(SUM(CASE WHEN side='candidate' THEN samples END), 0) AS candidate_avg_duration_us,
    MIN(CASE WHEN side='baseline' THEN min_duration_us END) AS baseline_min_duration_us,
    MIN(CASE WHEN side='candidate' THEN min_duration_us END) AS candidate_min_duration_us,
    MAX(CASE WHEN side='baseline' THEN max_duration_us END) AS baseline_max_duration_us,
    MAX(CASE WHEN side='candidate' THEN max_duration_us END) AS candidate_max_duration_us,
    SUM(CASE WHEN side='baseline' THEN total_duration_us END) AS baseline_total_duration_us,
    SUM(CASE WHEN side='candidate' THEN total_duration_us END) AS candidate_total_duration_us,
    SUM(CASE WHEN side='baseline' THEN clarity_runtime END) AS baseline_clarity_runtime,
    SUM(CASE WHEN side='candidate' THEN clarity_runtime END) AS candidate_clarity_runtime,
    SUM(CASE WHEN side='baseline' THEN clarity_read_count END) AS baseline_clarity_read_count,
    SUM(CASE WHEN side='candidate' THEN clarity_read_count END) AS candidate_clarity_read_count,
    SUM(CASE WHEN side='baseline' THEN clarity_read_length END) AS baseline_clarity_read_length,
    SUM(CASE WHEN side='candidate' THEN clarity_read_length END) AS candidate_clarity_read_length,
    SUM(CASE WHEN side='baseline' THEN clarity_write_count END) AS baseline_clarity_write_count,
    SUM(CASE WHEN side='candidate' THEN clarity_write_count END) AS candidate_clarity_write_count,
    SUM(CASE WHEN side='baseline' THEN clarity_write_length END) AS baseline_clarity_write_length,
    SUM(CASE WHEN side='candidate' THEN clarity_write_length END) AS candidate_clarity_write_length
  FROM per_hash
)
SELECT
  row_id,
  baseline_samples,
  candidate_samples,
  ROUND(baseline_avg_duration_us, 3) AS baseline_avg_duration_us,
  ROUND(candidate_avg_duration_us, 3) AS candidate_avg_duration_us,
  ROUND(candidate_avg_duration_us - baseline_avg_duration_us, 3) AS avg_delta_us,
  ROUND(100.0 * (baseline_avg_duration_us - candidate_avg_duration_us) / NULLIF(baseline_avg_duration_us, 0), 3) AS avg_duration_improvement_pct,
  baseline_min_duration_us,
  candidate_min_duration_us,
  baseline_max_duration_us,
  candidate_max_duration_us,
  baseline_total_duration_us,
  candidate_total_duration_us,
  candidate_total_duration_us - baseline_total_duration_us AS total_delta_us,
  ROUND(100.0 * (baseline_total_duration_us - candidate_total_duration_us) / NULLIF(baseline_total_duration_us, 0), 3) AS total_duration_improvement_pct,
  candidate_clarity_runtime - baseline_clarity_runtime AS clarity_runtime_delta,
  candidate_clarity_read_count - baseline_clarity_read_count AS clarity_read_count_delta,
  candidate_clarity_read_length - baseline_clarity_read_length AS clarity_read_length_delta,
  candidate_clarity_write_count - baseline_clarity_write_count AS clarity_write_count_delta,
  candidate_clarity_write_length - baseline_clarity_write_length AS clarity_write_length_delta
FROM (
  SELECT * FROM overall
  UNION ALL
  SELECT * FROM paired
)
ORDER BY CASE row_id WHEN 'ALL_TARGET_TXS' THEN 0 ELSE 1 END, row_id;
