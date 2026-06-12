-- Aggregate trace records for exact target txids and suspected spans in baseline run 8 vs candidate run 11.
WITH target_tx(tx_hash_hex) AS (
  VALUES
    ('9728154c1239b04662827d03388ded4608eb53f42f24f36c7a0c9f05d5478a23'),
    ('ac4eaf264a66347202d171f77b1e88dde72e1aff48000e83b343ef62e15e235a'),
    ('bd001e976f03206f10e6404abe289f73e8a3c4da8db5ac7d035763c0bee65171'),
    ('7b5f49a4fdc3164fc923982d7619608831c0847c476d4761708d75fc5df1f3fa'),
    ('695be269b728d5d55e07191115d513658a05dd97e266e59506cc38e3f733c11a')
), wanted_span(name) AS (
  VALUES
    ('at-block'),
    ('evaluate_at_block'),
    ('get_data'),
    ('get_value'),
    ('get_metadata'),
    ('get_by_key'),
    ('get_path'),
    ('walk'),
    ('walk_backptr')
), scoped AS (
  SELECT
    CASE pr.benchmark_run_id WHEN 8 THEN 'baseline' WHEN 11 THEN 'candidate' END AS side,
    tx.tx_hash_hex,
    ps.context,
    ps.name,
    pr.call_count,
    pr.sample_count,
    COALESCE(pr.est_wall_us, pr.wall_time_us) AS wall_us,
    COALESCE(pr.est_self_wall_us, pr.self_wall_time_us) AS self_wall_us
  FROM profiler_record AS pr
  JOIN stacks_tx AS tx ON tx.id = pr.stacks_tx_id
  JOIN target_tx AS tt ON tt.tx_hash_hex = tx.tx_hash_hex
  JOIN profiler_span AS ps ON ps.id = pr.profiler_span_id
  JOIN wanted_span AS ws ON ws.name = ps.name
  WHERE pr.benchmark_run_id IN (8, 11)
), agg AS (
  SELECT
    side,
    context,
    name,
    COUNT(*) AS records,
    SUM(call_count) AS calls,
    SUM(sample_count) AS samples,
    SUM(wall_us) AS total_wall_us,
    SUM(self_wall_us) AS self_wall_us
  FROM scoped
  GROUP BY side, context, name
), keys AS (
  SELECT context, name FROM agg GROUP BY context, name
)
SELECT
  k.context,
  k.name,
  MAX(CASE WHEN side='baseline' THEN records END) AS baseline_records,
  MAX(CASE WHEN side='candidate' THEN records END) AS candidate_records,
  MAX(CASE WHEN side='baseline' THEN calls END) AS baseline_calls,
  MAX(CASE WHEN side='candidate' THEN calls END) AS candidate_calls,
  MAX(CASE WHEN side='candidate' THEN calls END) - MAX(CASE WHEN side='baseline' THEN calls END) AS call_delta,
  ROUND(MAX(CASE WHEN side='baseline' THEN total_wall_us END), 3) AS baseline_total_wall_us,
  ROUND(MAX(CASE WHEN side='candidate' THEN total_wall_us END), 3) AS candidate_total_wall_us,
  ROUND(MAX(CASE WHEN side='candidate' THEN total_wall_us END) - MAX(CASE WHEN side='baseline' THEN total_wall_us END), 3) AS total_wall_delta_us,
  ROUND(100.0 * (MAX(CASE WHEN side='baseline' THEN total_wall_us END) - MAX(CASE WHEN side='candidate' THEN total_wall_us END)) / NULLIF(MAX(CASE WHEN side='baseline' THEN total_wall_us END), 0), 3) AS total_wall_improvement_pct,
  ROUND(MAX(CASE WHEN side='baseline' THEN self_wall_us END), 3) AS baseline_self_wall_us,
  ROUND(MAX(CASE WHEN side='candidate' THEN self_wall_us END), 3) AS candidate_self_wall_us,
  ROUND(MAX(CASE WHEN side='candidate' THEN self_wall_us END) - MAX(CASE WHEN side='baseline' THEN self_wall_us END), 3) AS self_wall_delta_us,
  ROUND(100.0 * (MAX(CASE WHEN side='baseline' THEN self_wall_us END) - MAX(CASE WHEN side='candidate' THEN self_wall_us END)) / NULLIF(MAX(CASE WHEN side='baseline' THEN self_wall_us END), 0), 3) AS self_wall_improvement_pct
FROM keys AS k
LEFT JOIN agg AS a ON a.context = k.context AND a.name = k.name
GROUP BY k.context, k.name
ORDER BY ABS(COALESCE(total_wall_delta_us, self_wall_delta_us, 0)) DESC;
