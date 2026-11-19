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

country_load_readings AS (
  SELECT
    area_code,
    utc_timestamp,
    reading AS load_mw
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type = 'load_actual_entsoe_transparency'
    AND (STRPOS(area_code, '_') = 0 OR area_code = 'GB_UKM')
    AND utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
    AND EXTRACT(MONTH FROM utc_timestamp) <= 9
),

readings_with_suspect_flag AS (
  SELECT
    country_load_readings.area_code,
    EXTRACT(YEAR FROM country_load_readings.utc_timestamp) AS year,
    country_load_readings.load_mw,
    suspect_load_hours.utc_timestamp IS NOT NULL AS is_suspect_hour
  FROM country_load_readings
  LEFT JOIN `bigquery-514705.power_system.suspect_load_hours` AS suspect_load_hours
    ON country_load_readings.area_code = suspect_load_hours.area_code
    AND country_load_readings.utc_timestamp = suspect_load_hours.utc_timestamp
),

country_year_summary AS (
  SELECT
    area_code,
    year,
    COUNTIF(NOT is_suspect_hour) AS valid_hours,
    COUNTIF(is_suspect_hour) AS suspect_hours_excluded,
    AVG(IF(NOT is_suspect_hour, load_mw, NULL)) AS mean_load_mw
  FROM readings_with_suspect_flag
  GROUP BY area_code, year
),

country_year_with_coverage AS (
  SELECT
    country_year_summary.area_code,
    country_year_summary.year,
    country_year_summary.valid_hours,
    country_year_summary.suspect_hours_excluded,
    country_year_summary.mean_load_mw,
    SAFE_DIVIDE(country_year_summary.valid_hours, expected_hours_january_to_september.expected_hours) AS coverage_share
  FROM country_year_summary
  INNER JOIN expected_hours_january_to_september
    ON country_year_summary.year = expected_hours_january_to_september.year
),

country_years_wide AS (
  SELECT
    area_code,
    MAX(IF(year = 2015 AND coverage_share >= 0.9, mean_load_mw, NULL)) AS mean_2015_mw,
    MAX(IF(year = 2016 AND coverage_share >= 0.9, mean_load_mw, NULL)) AS mean_2016_mw,
    MAX(IF(year = 2017 AND coverage_share >= 0.9, mean_load_mw, NULL)) AS mean_2017_mw,
    MAX(IF(year = 2018 AND coverage_share >= 0.9, mean_load_mw, NULL)) AS mean_2018_mw,
    MAX(IF(year = 2019 AND coverage_share >= 0.9, mean_load_mw, NULL)) AS mean_2019_mw,
    MAX(IF(year = 2020 AND coverage_share >= 0.9, mean_load_mw, NULL)) AS mean_2020_mw,
    COUNTIF(coverage_share >= 0.9) AS years_meeting_coverage_rule,
    SUM(valid_hours) AS valid_hours_in_window,
    SUM(suspect_hours_excluded) AS suspect_hours_excluded
  FROM country_year_with_coverage
  GROUP BY area_code
)

SELECT
  area_code,
  ROUND(mean_2015_mw, 1) AS mean_2015_mw,
  ROUND(mean_2016_mw, 1) AS mean_2016_mw,
  ROUND(mean_2017_mw, 1) AS mean_2017_mw,
  ROUND(mean_2018_mw, 1) AS mean_2018_mw,
  ROUND(mean_2019_mw, 1) AS mean_2019_mw,
  ROUND(mean_2020_mw, 1) AS mean_2020_mw,
  ROUND(100 * SAFE_DIVIDE(mean_2020_mw, mean_2019_mw) - 100, 1) AS change_2020_vs_2019_pct,
  years_meeting_coverage_rule,
  valid_hours_in_window,
  suspect_hours_excluded
FROM country_years_wide
ORDER BY area_code;
