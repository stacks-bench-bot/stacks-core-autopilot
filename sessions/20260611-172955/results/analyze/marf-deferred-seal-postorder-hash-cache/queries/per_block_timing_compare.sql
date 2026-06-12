WITH paired AS (
  SELECT
    b.synthetic_block_id,
    sb.height,
    sb.block_hash_hex,
    b.setup_duration_us AS baseline_setup_us,
    c.setup_duration_us AS candidate_setup_us,
    b.execution_duration_us AS baseline_execution_us,
    c.execution_duration_us AS candidate_execution_us,
    b.commit_duration_us AS baseline_commit_us,
    c.commit_duration_us AS candidate_commit_us,
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
  synthetic_block_id,
  height,
  block_hash_hex,
  baseline_commit_us,
  candidate_commit_us,
  candidate_commit_us - baseline_commit_us AS commit_delta_us,
  ROUND(100.0 * (baseline_commit_us - candidate_commit_us) / NULLIF(baseline_commit_us, 0), 3)
    AS commit_improvement_pct,
  baseline_execution_us,
  candidate_execution_us,
  candidate_execution_us - baseline_execution_us AS execution_delta_us,
  ROUND(100.0 * (baseline_execution_us - candidate_execution_us) / NULLIF(baseline_execution_us, 0), 3)
    AS execution_improvement_pct,
  baseline_total_us,
  candidate_total_us,
  candidate_total_us - baseline_total_us AS total_delta_us,
  ROUND(100.0 * (baseline_total_us - candidate_total_us) / NULLIF(baseline_total_us, 0), 3)
    AS total_improvement_pct
FROM paired
ORDER BY ABS(commit_delta_us) DESC;
