
SELECT
  CASE pss.benchmark_run_id WHEN :baseline_run_id THEN 'baseline' WHEN :candidate_run_id THEN 'candidate' END AS side,
  ps.context,
  ps.name,
  SUM(pss.self_wall_time_us) AS self_wall_us,
  SUM(pss.wall_time_us) AS total_wall_us,
  SUM(pss.call_count) AS calls,
  ROUND(1.0 * SUM(pss.self_wall_time_us) / NULLIF(SUM(pss.call_count), 0), 3) AS avg_self_us_per_call
FROM profiler_span_summary pss
JOIN profiler_span ps ON ps.id = pss.profiler_span_id
WHERE pss.benchmark_run_id IN (:baseline_run_id, :candidate_run_id)
  AND (
    lower(ps.name) LIKE '%put%'
    OR lower(ps.context) LIKE '%put%'
    OR ps.name = 'execute'
  )
GROUP BY pss.benchmark_run_id, ps.context, ps.name
ORDER BY side, self_wall_us DESC;
