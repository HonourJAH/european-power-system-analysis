WITH expected_hours_january_to_september AS (
  SELECT
    EXTRACT(YEAR FROM hour_utc) AS year,
    COUNT(*) AS expected_hours
  FROM UNNEST(GENERATE_TIMESTAMP_ARRAY(
    TIMESTAMP '2015-01-01 00:00:00+00',
    TIMESTAMP '2020-09-30 23:00:00+00',
    INTERVAL 1 HOUR)) AS hour_utc
  WHERE EXTRACT(MONTH FROM hour_utc) <= 9
  GROUP BY year
),

country_load_by_hour AS (
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

matched_hours AS (
  SELECT
    country_load_by_hour.area_code,
    country_load_by_hour.utc_timestamp,
    country_load_by_hour.actual_load_mw,
    country_load_by_hour.forecast_load_mw
  FROM country_load_by_hour
  LEFT JOIN `bigquery-514705.power_system.suspect_load_hours` AS suspect_load_hours
    ON country_load_by_hour.area_code = suspect_load_hours.area_code
    AND country_load_by_hour.utc_timestamp = suspect_load_hours.utc_timestamp
  WHERE country_load_by_hour.actual_load_mw IS NOT NULL
    AND country_load_by_hour.forecast_load_mw IS NOT NULL
    AND suspect_load_hours.utc_timestamp IS NULL
),

matched_hours_by_year AS (
  SELECT
    area_code,
    EXTRACT(YEAR FROM utc_timestamp) AS year,
    COUNTIF(EXTRACT(MONTH FROM utc_timestamp) <= 9) AS january_to_september_hours
  FROM matched_hours
  GROUP BY area_code, year
),

coverage_by_country_and_year AS (
  SELECT
    country_names.area_code,
    expected_hours_january_to_september.year,
    SAFE_DIVIDE(COALESCE(matched_hours_by_year.january_to_september_hours, 0),
                expected_hours_january_to_september.expected_hours) AS coverage_share
  FROM `bigquery-514705.power_system.country_names` AS country_names
  CROSS JOIN expected_hours_january_to_september
  LEFT JOIN matched_hours_by_year
    ON country_names.area_code = matched_hours_by_year.area_code
    AND expected_hours_january_to_september.year = matched_hours_by_year.year
),

coverage_summary AS (
  SELECT
    area_code,
    COUNTIF(coverage_share >= 0.9) AS years_meeting_rule,
    ROUND(100 * MIN(coverage_share), 1) AS lowest_yearly_coverage_pct
  FROM coverage_by_country_and_year
  GROUP BY area_code
),

whole_period_summary AS (
  SELECT
    area_code,
    COUNT(*) AS matched_hours,
    COUNTIF(forecast_load_mw <= 0) AS forecast_zero_or_negative_hours,
    COUNTIF(forecast_load_mw > 2 * actual_load_mw OR forecast_load_mw < 0.5 * actual_load_mw) AS forecast_double_or_half_hours
  FROM matched_hours
  GROUP BY area_code
)

SELECT
  country_names.country_name,
  country_names.area_code,
  COALESCE(whole_period_summary.matched_hours, 0) AS matched_hours_2015_2020,
  COALESCE(whole_period_summary.matched_hours, 0) >= 50000 AS meets_whole_period_rule,
  coverage_summary.years_meeting_rule,
  coverage_summary.lowest_yearly_coverage_pct,
  COALESCE(whole_period_summary.forecast_zero_or_negative_hours, 0) AS forecast_zero_or_negative_hours,
  COALESCE(whole_period_summary.forecast_double_or_half_hours, 0) AS forecast_double_or_half_hours
FROM `bigquery-514705.power_system.country_names` AS country_names
LEFT JOIN whole_period_summary
  ON country_names.area_code = whole_period_summary.area_code
LEFT JOIN coverage_summary
  ON country_names.area_code = coverage_summary.area_code
ORDER BY meets_whole_period_rule DESC, years_meeting_rule DESC, country_names.country_name;
