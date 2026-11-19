WITH expected_hours_per_year AS (
  SELECT
    EXTRACT(YEAR FROM hour_utc) AS year,
    COUNT(*) AS expected_hours
  FROM UNNEST(GENERATE_TIMESTAMP_ARRAY(
    TIMESTAMP '2015-01-01 00:00:00+00',
    TIMESTAMP '2020-09-30 23:00:00+00',
    INTERVAL 1 HOUR)) AS hour_utc
  GROUP BY year
),

country_load_hours AS (
  SELECT
    area_code,
    EXTRACT(YEAR FROM utc_timestamp) AS year,
    COUNT(*) AS filled_hours
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type = 'load_actual_entsoe_transparency'
    AND (STRPOS(area_code, '_') = 0 OR area_code = 'GB_UKM')
  GROUP BY area_code, year
),

coverage_by_country_and_year AS (
  SELECT
    country_load_hours.area_code,
    country_load_hours.year,
    country_load_hours.filled_hours,
    SAFE_DIVIDE(country_load_hours.filled_hours, expected_hours_per_year.expected_hours) AS coverage_share
  FROM country_load_hours
  INNER JOIN expected_hours_per_year
    ON country_load_hours.year = expected_hours_per_year.year
)

SELECT
  area_code,
  SUM(filled_hours) AS filled_hours_2015_to_2020,
  SUM(filled_hours) >= 50000 AS meets_whole_period_rule,
  ROUND(100 * MAX(IF(year = 2015, coverage_share, NULL)), 1) AS coverage_2015_pct,
  ROUND(100 * MAX(IF(year = 2016, coverage_share, NULL)), 1) AS coverage_2016_pct,
  ROUND(100 * MAX(IF(year = 2017, coverage_share, NULL)), 1) AS coverage_2017_pct,
  ROUND(100 * MAX(IF(year = 2018, coverage_share, NULL)), 1) AS coverage_2018_pct,
  ROUND(100 * MAX(IF(year = 2019, coverage_share, NULL)), 1) AS coverage_2019_pct,
  ROUND(100 * MAX(IF(year = 2020, coverage_share, NULL)), 1) AS coverage_2020_pct,
  COUNTIF(coverage_share >= 0.9) AS years_with_90_pct_coverage
FROM coverage_by_country_and_year
GROUP BY area_code
ORDER BY years_with_90_pct_coverage DESC, area_code;
