
WITH tx_runs AS (
  SELECT
    benchmark_run_id,
    stacks_tx_id,
    COUNT(*) AS samples,
    AVG(total_duration_us) AS avg_total_us,
    AVG(execution_duration_us) AS avg_execution_us,
    AVG(commit_duration_us) AS avg_commit_us,
    MIN(total_duration_us) AS min_total_us,
    MAX(total_duration_us) AS max_total_us
  FROM stacks_tx_stats
  WHERE benchmark_run_id IN (:baseline_run_id, :candidate_run_id)
  GROUP BY benchmark_run_id, stacks_tx_id
), paired AS (
  SELECT
    b.stacks_tx_id,
    b.samples AS baseline_samples,
    c.samples AS candidate_samples,
    b.avg_total_us AS baseline_avg_total_us,
    c.avg_total_us AS candidate_avg_total_us,
    100.0 * (b.avg_total_us - c.avg_total_us) / NULLIF(b.avg_total_us, 0) AS total_improvement_pct,
    b.avg_execution_us AS baseline_avg_execution_us,
    c.avg_execution_us AS candidate_avg_execution_us,
    100.0 * (b.avg_execution_us - c.avg_execution_us) / NULLIF(b.avg_execution_us, 0) AS execution_improvement_pct,
    b.avg_commit_us AS baseline_avg_commit_us,
    c.avg_commit_us AS candidate_avg_commit_us,
    100.0 * (b.avg_commit_us - c.avg_commit_us) / NULLIF(b.avg_commit_us, 0) AS commit_improvement_pct,
    b.min_total_us AS baseline_min_total_us,
    b.max_total_us AS baseline_max_total_us,
    c.min_total_us AS candidate_min_total_us,
    c.max_total_us AS candidate_max_total_us
  FROM tx_runs b
  JOIN tx_runs c ON c.stacks_tx_id = b.stacks_tx_id
  WHERE b.benchmark_run_id = :baseline_run_id AND c.benchmark_run_id = :candidate_run_id
)
SELECT
  stacks_tx_id,
  baseline_samples,
  candidate_samples,
  ROUND(baseline_avg_total_us, 3) AS baseline_avg_total_us,
  ROUND(candidate_avg_total_us, 3) AS candidate_avg_total_us,
  ROUND(total_improvement_pct, 3) AS total_improvement_pct,
  ROUND(baseline_avg_execution_us, 3) AS baseline_avg_execution_us,
  ROUND(candidate_avg_execution_us, 3) AS candidate_avg_execution_us,
  ROUND(execution_improvement_pct, 3) AS execution_improvement_pct,
  ROUND(baseline_avg_commit_us, 3) AS baseline_avg_commit_us,
  ROUND(candidate_avg_commit_us, 3) AS candidate_avg_commit_us,
  ROUND(commit_improvement_pct, 3) AS commit_improvement_pct,
  baseline_min_total_us,
  baseline_max_total_us,
  candidate_min_total_us,
  candidate_max_total_us
FROM paired
ORDER BY stacks_tx_id;
