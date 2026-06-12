WITH span_rows AS (
  SELECT
    pss.benchmark_run_id,
    ps.context,
    ps.name,
    SUM(pss.self_wall_time_us) AS self_wall_us,
    SUM(pss.wall_time_us) AS total_wall_us,
    SUM(pss.call_count) AS calls
  FROM profiler_span_summary AS pss
  JOIN profiler_span AS ps ON ps.id = pss.profiler_span_id
  WHERE pss.benchmark_run_id IN (9, 12)
  GROUP BY pss.benchmark_run_id, ps.context, ps.name
),
paired AS (
  SELECT
    COALESCE(b.context, c.context) AS context,
    COALESCE(b.name, c.name) AS name,
    b.self_wall_us AS baseline_self_wall_us,
    c.self_wall_us AS candidate_self_wall_us,
    c.self_wall_us - b.self_wall_us AS self_wall_delta_us,
    ROUND(100.0 * (b.self_wall_us - c.self_wall_us) / NULLIF(b.self_wall_us, 0), 3)
      AS self_wall_improvement_pct,
    b.total_wall_us AS baseline_total_wall_us,
    c.total_wall_us AS candidate_total_wall_us,
    c.total_wall_us - b.total_wall_us AS total_wall_delta_us,
    ROUND(100.0 * (b.total_wall_us - c.total_wall_us) / NULLIF(b.total_wall_us, 0), 3)
      AS total_wall_improvement_pct,
    b.calls AS baseline_calls,
    c.calls AS candidate_calls,
    c.calls - b.calls AS call_delta
  FROM span_rows AS b
  JOIN span_rows AS c
    ON c.context IS b.context
   AND c.name = b.name
   AND c.benchmark_run_id = 12
  WHERE b.benchmark_run_id = 9
)
SELECT *
FROM paired
ORDER BY ABS(self_wall_delta_us) DESC
LIMIT 40;
