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

country_generation_readings AS (
  SELECT
    area_code,
    EXTRACT(YEAR FROM utc_timestamp) AS year,
    IF(measure_type = 'solar_generation_actual', 'solar', 'wind') AS generation_type
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
    AND (STRPOS(area_code, '_') = 0 OR area_code = 'GB_UKM')
    AND (
      measure_type = 'solar_generation_actual'
      OR measure_type = 'wind_generation_actual'
      OR (measure_type = 'wind_onshore_generation_actual'
          AND area_code NOT IN ('BE', 'DE', 'DK', 'GB_UKM', 'NL', 'PT'))
    )
),

hours_by_country_and_year AS (
  SELECT
    area_code,
    year,
    COUNTIF(generation_type = 'solar') AS solar_hours,
    COUNTIF(generation_type = 'wind') AS wind_hours
  FROM country_generation_readings
  GROUP BY area_code, year
),

coverage_by_country_and_year AS (
  SELECT
    country_names.country_name,
    country_names.area_code,
    expected_hours_per_year.year,
    COALESCE(hours_by_country_and_year.solar_hours, 0) AS solar_hours,
    COALESCE(hours_by_country_and_year.wind_hours, 0) AS wind_hours,
    SAFE_DIVIDE(COALESCE(hours_by_country_and_year.solar_hours, 0), expected_hours_per_year.expected_hours) AS solar_share,
    SAFE_DIVIDE(COALESCE(hours_by_country_and_year.wind_hours, 0), expected_hours_per_year.expected_hours) AS wind_share
  FROM `bigquery-514705.power_system.country_names` AS country_names
  CROSS JOIN expected_hours_per_year
  LEFT JOIN hours_by_country_and_year
    ON country_names.area_code = hours_by_country_and_year.area_code
    AND expected_hours_per_year.year = hours_by_country_and_year.year
)

SELECT
  country_name,
  area_code,
  IF(area_code IN ('BE', 'DE', 'DK', 'GB_UKM', 'NL', 'PT'),
     'wind_generation_actual', 'wind_onshore_generation_actual') AS wind_measure_used,
  COUNTIF(solar_share >= 0.9) AS years_solar_ok,
  COUNTIF(wind_share >= 0.9) AS years_wind_ok,
  COUNTIF(solar_share >= 0.9 AND wind_share >= 0.9) AS years_both_ok,
  ROUND(100 * MIN(solar_share), 1) AS lowest_yearly_solar_pct,
  ROUND(100 * MIN(wind_share), 1) AS lowest_yearly_wind_pct,
  SUM(solar_hours) AS solar_hours_2015_2020,
  SUM(wind_hours) AS wind_hours_2015_2020
FROM coverage_by_country_and_year
GROUP BY country_name, area_code
ORDER BY years_both_ok DESC, country_name;
