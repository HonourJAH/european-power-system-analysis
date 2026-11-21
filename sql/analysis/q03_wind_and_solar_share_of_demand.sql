CREATE TEMP FUNCTION period_labels(utc_hour TIMESTAMP) RETURNS ARRAY<STRING> AS (
  ARRAY_CONCAT(
    ['whole_period'],
    IF(EXTRACT(MONTH FROM utc_hour) <= 9,
       [CONCAT('year_', CAST(EXTRACT(YEAR FROM utc_hour) AS STRING))], ARRAY<STRING>[]),
    IF(EXTRACT(MONTH FROM utc_hour) IN (1, 2), ['winter'], ARRAY<STRING>[]),
    IF(EXTRACT(MONTH FROM utc_hour) IN (6, 7, 8), ['summer'], ARRAY<STRING>[]),
    IF(EXTRACT(MONTH FROM utc_hour) IN (3, 4, 5) AND EXTRACT(YEAR FROM utc_hour) <= 2019,
       ['spring_2015_2019'], ARRAY<STRING>[]),
    IF(EXTRACT(MONTH FROM utc_hour) IN (3, 4, 5) AND EXTRACT(YEAR FROM utc_hour) = 2020,
       ['spring_2020'], ARRAY<STRING>[])
  )
);

WITH selected_countries AS (
  SELECT area_code, wind_measure_type
  FROM UNNEST([
    STRUCT('AT' AS area_code, 'wind_onshore_generation_actual' AS wind_measure_type),
    ('BE', 'wind_generation_actual'),
    ('BG', 'wind_onshore_generation_actual'),
    ('CH', 'wind_onshore_generation_actual'),
    ('CZ', 'wind_onshore_generation_actual'),
    ('DE', 'wind_generation_actual'),
    ('DK', 'wind_generation_actual'),
    ('EE', 'wind_onshore_generation_actual'),
    ('ES', 'wind_onshore_generation_actual'),
    ('FR', 'wind_onshore_generation_actual'),
    ('GB_UKM', 'wind_generation_actual'),
    ('GR', 'wind_onshore_generation_actual'),
    ('IT', 'wind_onshore_generation_actual'),
    ('LT', 'wind_onshore_generation_actual'),
    ('NL', 'wind_generation_actual'),
    ('RO', 'wind_onshore_generation_actual'),
    ('SI', 'wind_onshore_generation_actual')
  ])
),

hourly_readings AS (
  SELECT
    readings.area_code,
    readings.utc_timestamp,
    MAX(IF(readings.measure_type = 'load_actual_entsoe_transparency', readings.reading, NULL)) AS load_mw,
    MAX(IF(readings.measure_type = 'solar_generation_actual', readings.reading, NULL)) AS solar_mw,
    MAX(IF(readings.measure_type = selected_countries.wind_measure_type, readings.reading, NULL)) AS wind_mw
  FROM `bigquery-514705.power_system.time_series_hourly_long` AS readings
  INNER JOIN selected_countries
    ON readings.area_code = selected_countries.area_code
  WHERE readings.utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
    AND readings.measure_type IN ('load_actual_entsoe_transparency', 'solar_generation_actual',
                                  'wind_generation_actual', 'wind_onshore_generation_actual')
  GROUP BY readings.area_code, readings.utc_timestamp
),

complete_hours AS (
  SELECT
    hourly_readings.area_code,
    hourly_readings.utc_timestamp,
    hourly_readings.load_mw,
    hourly_readings.solar_mw,
    hourly_readings.wind_mw
  FROM hourly_readings
  LEFT JOIN `bigquery-514705.power_system.suspect_load_hours` AS suspect_load_hours
    ON hourly_readings.area_code = suspect_load_hours.area_code
    AND hourly_readings.utc_timestamp = suspect_load_hours.utc_timestamp
  WHERE hourly_readings.load_mw IS NOT NULL
    AND hourly_readings.solar_mw IS NOT NULL
    AND hourly_readings.wind_mw IS NOT NULL
    AND suspect_load_hours.utc_timestamp IS NULL
),

expected_hours AS (
  SELECT
    period_label,
    COUNT(*) AS expected_hours
  FROM UNNEST(GENERATE_TIMESTAMP_ARRAY(
    TIMESTAMP '2015-01-01 00:00:00+00',
    TIMESTAMP '2020-09-30 23:00:00+00',
    INTERVAL 1 HOUR)) AS utc_hour,
  UNNEST(period_labels(utc_hour)) AS period_label
  GROUP BY period_label
),

period_summary AS (
  SELECT
    area_code,
    period_label,
    COUNT(*) AS matched_hours,
    AVG(load_mw) AS mean_load_mw,
    AVG(wind_mw) AS mean_wind_mw,
    AVG(solar_mw) AS mean_solar_mw
  FROM complete_hours,
  UNNEST(period_labels(utc_timestamp)) AS period_label
  GROUP BY area_code, period_label
),

period_shares AS (
  SELECT
    period_summary.area_code,
    period_summary.period_label,
    period_summary.matched_hours,
    IF(period_summary.period_label = 'whole_period',
       period_summary.matched_hours >= 50000,
       SAFE_DIVIDE(period_summary.matched_hours, expected_hours.expected_hours) >= 0.9) AS meets_rule,
    100 * SAFE_DIVIDE(period_summary.mean_wind_mw, period_summary.mean_load_mw) AS wind_share_pct,
    100 * SAFE_DIVIDE(period_summary.mean_solar_mw, period_summary.mean_load_mw) AS solar_share_pct,
    100 * SAFE_DIVIDE(period_summary.mean_wind_mw + period_summary.mean_solar_mw, period_summary.mean_load_mw) AS combined_share_pct
  FROM period_summary
  INNER JOIN expected_hours
    ON period_summary.period_label = expected_hours.period_label
)

SELECT
  country_names.country_name,
  period_shares.area_code,
  MAX(IF(period_label = 'whole_period', matched_hours, NULL)) AS whole_period_matched_hours,
  ROUND(MAX(IF(period_label = 'whole_period' AND meets_rule, wind_share_pct, NULL)), 1) AS whole_period_wind_pct,
  ROUND(MAX(IF(period_label = 'whole_period' AND meets_rule, solar_share_pct, NULL)), 1) AS whole_period_solar_pct,
  ROUND(MAX(IF(period_label = 'whole_period' AND meets_rule, combined_share_pct, NULL)), 1) AS whole_period_combined_pct,
  ROUND(MAX(IF(period_label = 'year_2015' AND meets_rule, combined_share_pct, NULL)), 1) AS combined_2015_pct,
  ROUND(MAX(IF(period_label = 'year_2016' AND meets_rule, combined_share_pct, NULL)), 1) AS combined_2016_pct,
  ROUND(MAX(IF(period_label = 'year_2017' AND meets_rule, combined_share_pct, NULL)), 1) AS combined_2017_pct,
  ROUND(MAX(IF(period_label = 'year_2018' AND meets_rule, combined_share_pct, NULL)), 1) AS combined_2018_pct,
  ROUND(MAX(IF(period_label = 'year_2019' AND meets_rule, combined_share_pct, NULL)), 1) AS combined_2019_pct,
  ROUND(MAX(IF(period_label = 'year_2020' AND meets_rule, combined_share_pct, NULL)), 1) AS combined_2020_pct,
  ROUND(MAX(IF(period_label = 'winter' AND meets_rule, combined_share_pct, NULL)), 1) AS winter_pct,
  ROUND(MAX(IF(period_label = 'summer' AND meets_rule, combined_share_pct, NULL)), 1) AS summer_pct,
  ROUND(MAX(IF(period_label = 'spring_2015_2019' AND meets_rule, combined_share_pct, NULL)), 1) AS spring_2015_2019_pct,
  ROUND(MAX(IF(period_label = 'spring_2020' AND meets_rule, combined_share_pct, NULL)), 1) AS spring_2020_pct
FROM period_shares
INNER JOIN `bigquery-514705.power_system.country_names` AS country_names
  ON period_shares.area_code = country_names.area_code
GROUP BY country_names.country_name, period_shares.area_code
ORDER BY country_names.country_name;
