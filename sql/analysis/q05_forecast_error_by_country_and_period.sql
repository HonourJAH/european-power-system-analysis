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

WITH country_load_by_hour AS (
  SELECT
    area_code,
    utc_timestamp,
    MAX(IF(measure_type = 'load_actual_entsoe_transparency', reading, NULL)) AS actual_load_mw,
    MAX(IF(measure_type = 'load_forecast_entsoe_transparency', reading, NULL)) AS forecast_load_mw
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type IN ('load_actual_entsoe_transparency', 'load_forecast_entsoe_transparency')
    AND (STRPOS(area_code, '_') = 0 OR area_code = 'GB_UKM')
    AND utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
  GROUP BY area_code, utc_timestamp
),

hourly_errors AS (
  SELECT
    country_load_by_hour.area_code,
    country_load_by_hour.utc_timestamp,
    100 * ABS(country_load_by_hour.forecast_load_mw - country_load_by_hour.actual_load_mw)
        / country_load_by_hour.actual_load_mw AS error_pct,
    country_load_by_hour.forecast_load_mw > 2 * country_load_by_hour.actual_load_mw
      OR country_load_by_hour.forecast_load_mw < 0.5 * country_load_by_hour.actual_load_mw AS is_extreme_forecast_hour
  FROM country_load_by_hour
  LEFT JOIN `bigquery-514705.power_system.suspect_load_hours` AS suspect_load_hours
    ON country_load_by_hour.area_code = suspect_load_hours.area_code
    AND country_load_by_hour.utc_timestamp = suspect_load_hours.utc_timestamp
  WHERE country_load_by_hour.actual_load_mw > 0
    AND country_load_by_hour.forecast_load_mw IS NOT NULL
    AND suspect_load_hours.utc_timestamp IS NULL
),

period_summary AS (
  SELECT
    area_code,
    period_label,
    COUNT(*) AS matched_hours,
    AVG(error_pct) AS mean_error_pct,
    AVG(IF(NOT is_extreme_forecast_hour, error_pct, NULL)) AS mean_error_without_extreme_hours_pct,
    APPROX_QUANTILES(error_pct, 100)[OFFSET(50)] AS median_error_pct,
    APPROX_QUANTILES(error_pct, 100)[OFFSET(90)] AS p90_error_pct,
    100 * SAFE_DIVIDE(COUNTIF(error_pct > 5), COUNT(*)) AS share_above_5_pct,
    COUNTIF(is_extreme_forecast_hour) AS extreme_forecast_hours
  FROM hourly_errors,
  UNNEST(period_labels(utc_timestamp)) AS period_label
  GROUP BY area_code, period_label
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

period_results AS (
  SELECT
    period_summary.*,
    IF(period_summary.period_label = 'whole_period',
       period_summary.matched_hours >= 50000,
       SAFE_DIVIDE(period_summary.matched_hours, expected_hours.expected_hours) >= 0.9) AS meets_rule
  FROM period_summary
  INNER JOIN expected_hours
    ON period_summary.period_label = expected_hours.period_label
)

SELECT
  country_names.country_name,
  period_results.area_code,
  MAX(IF(period_label = 'whole_period', matched_hours, NULL)) AS whole_period_matched_hours,
  MAX(IF(period_label = 'whole_period', meets_rule, NULL)) AS whole_period_meets_rule,
  ROUND(MAX(IF(period_label = 'whole_period' AND meets_rule, mean_error_pct, NULL)), 2) AS mean_error_pct,
  ROUND(MAX(IF(period_label = 'whole_period' AND meets_rule, mean_error_without_extreme_hours_pct, NULL)), 2) AS mean_error_without_extreme_hours_pct,
  ROUND(MAX(IF(period_label = 'whole_period' AND meets_rule, median_error_pct, NULL)), 2) AS median_error_pct,
  ROUND(MAX(IF(period_label = 'whole_period' AND meets_rule, p90_error_pct, NULL)), 2) AS p90_error_pct,
  ROUND(MAX(IF(period_label = 'whole_period' AND meets_rule, share_above_5_pct, NULL)), 1) AS share_above_5_pct,
  MAX(IF(period_label = 'whole_period', extreme_forecast_hours, NULL)) AS extreme_forecast_hours,
  ROUND(MAX(IF(period_label = 'year_2015' AND meets_rule, median_error_pct, NULL)), 2) AS median_2015_pct,
  ROUND(MAX(IF(period_label = 'year_2016' AND meets_rule, median_error_pct, NULL)), 2) AS median_2016_pct,
  ROUND(MAX(IF(period_label = 'year_2017' AND meets_rule, median_error_pct, NULL)), 2) AS median_2017_pct,
  ROUND(MAX(IF(period_label = 'year_2018' AND meets_rule, median_error_pct, NULL)), 2) AS median_2018_pct,
  ROUND(MAX(IF(period_label = 'year_2019' AND meets_rule, median_error_pct, NULL)), 2) AS median_2019_pct,
  ROUND(MAX(IF(period_label = 'year_2020' AND meets_rule, median_error_pct, NULL)), 2) AS median_2020_pct,
  ROUND(MAX(IF(period_label = 'winter' AND meets_rule, median_error_pct, NULL)), 2) AS median_winter_pct,
  ROUND(MAX(IF(period_label = 'summer' AND meets_rule, median_error_pct, NULL)), 2) AS median_summer_pct,
  ROUND(MAX(IF(period_label = 'spring_2015_2019' AND meets_rule, median_error_pct, NULL)), 2) AS median_spring_2015_2019_pct,
  ROUND(MAX(IF(period_label = 'spring_2020' AND meets_rule, median_error_pct, NULL)), 2) AS median_spring_2020_pct
FROM period_results
INNER JOIN `bigquery-514705.power_system.country_names` AS country_names
  ON period_results.area_code = country_names.area_code
GROUP BY country_names.country_name, period_results.area_code
ORDER BY country_names.country_name;
