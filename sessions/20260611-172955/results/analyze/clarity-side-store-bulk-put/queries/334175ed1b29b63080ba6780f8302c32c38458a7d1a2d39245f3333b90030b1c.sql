
WITH tx_runs AS (
  SELECT
    s.benchmark_run_id,
    lower(hex(t.tx_hash)) AS tx_hash,
    COUNT(*) AS samples,
    AVG(s.duration_us) AS avg_duration_us,
    MIN(s.duration_us) AS min_duration_us,
    MAX(s.duration_us) AS max_duration_us
  FROM stacks_tx_stats s
  JOIN stacks_tx t ON t.id = s.stacks_tx_id
  WHERE s.benchmark_run_id IN (:baseline_run_id, :candidate_run_id)
  GROUP BY s.benchmark_run_id, t.tx_hash
), paired AS (
  SELECT
    b.tx_hash,
    b.samples AS baseline_samples,
    c.samples AS candidate_samples,
    b.avg_duration_us AS baseline_avg_duration_us,
    c.avg_duration_us AS candidate_avg_duration_us,
    100.0 * (b.avg_duration_us - c.avg_duration_us) / NULLIF(b.avg_duration_us, 0) AS duration_improvement_pct,
    b.min_duration_us AS baseline_min_duration_us,
    b.max_duration_us AS baseline_max_duration_us,
    c.min_duration_us AS candidate_min_duration_us,
    c.max_duration_us AS candidate_max_duration_us
  FROM tx_runs b
  JOIN tx_runs c ON c.tx_hash = b.tx_hash
  WHERE b.benchmark_run_id = :baseline_run_id AND c.benchmark_run_id = :candidate_run_id
)
SELECT
  tx_hash,
  baseline_samples,
  candidate_samples,
  ROUND(baseline_avg_duration_us, 3) AS baseline_avg_duration_us,
  ROUND(candidate_avg_duration_us, 3) AS candidate_avg_duration_us,
  ROUND(duration_improvement_pct, 3) AS duration_improvement_pct,
  baseline_min_duration_us,
  baseline_max_duration_us,
  candidate_min_duration_us,
  candidate_max_duration_us
FROM paired
ORDER BY tx_hash;
