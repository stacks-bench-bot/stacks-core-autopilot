WITH paired AS (
  SELECT
    sb.block_hash_hex,
    b.commit_duration_us AS baseline_commit_us,
    c.commit_duration_us AS candidate_commit_us,
    b.execution_duration_us AS baseline_execution_us,
    c.execution_duration_us AS candidate_execution_us,
    b.total_duration_us AS baseline_total_us,
    c.total_duration_us AS candidate_total_us
  FROM stacks_block_stats AS b
  JOIN stacks_block_stats AS c
    ON c.synthetic_block_id = b.synthetic_block_id
   AND c.benchmark_run_id = 12
  JOIN synthetic_block AS synth ON synth.id = b.synthetic_block_id
  JOIN stacks_block AS sb ON sb.id = synth.stacks_block_id
  WHERE b.benchmark_run_id = 9
)
SELECT
  block_hash_hex,
  COUNT(*) AS samples,
  ROUND(AVG(baseline_commit_us), 3) AS baseline_commit_us,
  ROUND(AVG(candidate_commit_us), 3) AS candidate_commit_us,
  ROUND(AVG(candidate_commit_us - baseline_commit_us), 3) AS avg_commit_delta_us,
  ROUND(100.0 * (SUM(baseline_commit_us) - SUM(candidate_commit_us)) / NULLIF(SUM(baseline_commit_us), 0), 3)
    AS commit_improvement_pct,
  ROUND(100.0 * (SUM(baseline_execution_us) - SUM(candidate_execution_us)) / NULLIF(SUM(baseline_execution_us), 0), 3)
    AS execution_improvement_pct,
  ROUND(100.0 * (SUM(baseline_total_us) - SUM(candidate_total_us)) / NULLIF(SUM(baseline_total_us), 0), 3)
    AS total_improvement_pct
FROM paired
GROUP BY block_hash_hex
ORDER BY commit_improvement_pct DESC;
