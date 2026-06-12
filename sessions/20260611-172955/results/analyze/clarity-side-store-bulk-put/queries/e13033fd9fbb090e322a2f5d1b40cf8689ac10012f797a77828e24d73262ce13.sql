
WITH span_ids AS (
  SELECT pss.benchmark_run_id, ps.id AS span_id
  FROM profiler_span_summary pss
  JOIN profiler_span ps ON ps.id = pss.profiler_span_id
  WHERE pss.benchmark_run_id IN (:baseline_run_id, :candidate_run_id)
    AND ps.name = 'put_all_data'
    AND ps.context = 'blockstack_lib::clarity_vm::database::marf::PersistentWritableMarfStore'
), per_block AS (
  SELECT
    CASE psbs.benchmark_run_id WHEN :baseline_run_id THEN 'baseline' WHEN :candidate_run_id THEN 'candidate' END AS side,
    psbs.synthetic_block_id,
    SUM(psbs.self_wall_time_us) AS self_wall_us,
    SUM(psbs.wall_time_us) AS total_wall_us,
    SUM(psbs.call_count) AS calls
  FROM profiler_span_block_summary psbs
  JOIN span_ids s ON s.benchmark_run_id = psbs.benchmark_run_id AND s.span_id = psbs.profiler_span_id
  GROUP BY psbs.benchmark_run_id, psbs.synthetic_block_id
), ranked AS (
  SELECT *, row_number() OVER (PARTITION BY side ORDER BY total_wall_us) AS rn, count(*) OVER (PARTITION BY side) AS n
  FROM per_block
), agg AS (
  SELECT
    side,
    COUNT(*) AS blocks,
    AVG(total_wall_us) AS avg_total_wall_us,
    MIN(total_wall_us) AS min_total_wall_us,
    MAX(total_wall_us) AS max_total_wall_us,
    AVG(calls) AS avg_calls
  FROM per_block GROUP BY side
), pct AS (
  SELECT
    side,
    MAX(CASE WHEN rn = CAST((n + 1) / 2 AS INTEGER) THEN total_wall_us END) AS p50_total_wall_us,
    MAX(CASE WHEN rn = CAST((95 * n + 99) / 100 AS INTEGER) THEN total_wall_us END) AS p95_total_wall_us,
    MAX(CASE WHEN rn = CAST((99 * n + 99) / 100 AS INTEGER) THEN total_wall_us END) AS p99_total_wall_us
  FROM ranked GROUP BY side
)
SELECT
  agg.side, blocks,
  ROUND(avg_total_wall_us, 3) AS avg_total_wall_us,
  min_total_wall_us,
  p50_total_wall_us,
  p95_total_wall_us,
  p99_total_wall_us,
  max_total_wall_us,
  ROUND(avg_calls, 3) AS avg_calls
FROM agg JOIN pct USING(side)
ORDER BY side;
