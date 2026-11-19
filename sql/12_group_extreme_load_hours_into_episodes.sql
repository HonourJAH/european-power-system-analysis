WITH country_load_readings AS (
  SELECT
    area_code,
    utc_timestamp,
    reading AS load_mw
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type = 'load_actual_entsoe_transparency'
    AND (STRPOS(area_code, '_') = 0 OR area_code = 'GB_UKM')
    AND utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
),

country_medians AS (
  SELECT
    area_code,
    APPROX_QUANTILES(load_mw, 100)[OFFSET(50)] AS median_load_mw
  FROM country_load_readings
  GROUP BY area_code
),

flagged_hours AS (
  SELECT
    country_load_readings.area_code,
    country_load_readings.utc_timestamp,
    country_load_readings.load_mw,
    country_medians.median_load_mw
  FROM country_load_readings
  INNER JOIN country_medians
    ON country_load_readings.area_code = country_medians.area_code
  WHERE country_load_readings.load_mw > 2 * country_medians.median_load_mw
     OR country_load_readings.load_mw < 0.25 * country_medians.median_load_mw
),

flagged_hours_with_gap AS (
  SELECT
    area_code,
    utc_timestamp,
    load_mw,
    median_load_mw,
    TIMESTAMP_DIFF(
      utc_timestamp,
      LAG(utc_timestamp) OVER (PARTITION BY area_code ORDER BY utc_timestamp),
      HOUR) AS hours_since_previous_flagged_hour
  FROM flagged_hours
),

flagged_hours_with_episode AS (
  SELECT
    area_code,
    utc_timestamp,
    load_mw,
    median_load_mw,
    SUM(IF(hours_since_previous_flagged_hour IS NULL OR hours_since_previous_flagged_hour > 12, 1, 0))
      OVER (PARTITION BY area_code ORDER BY utc_timestamp) AS episode_number
  FROM flagged_hours_with_gap
)

SELECT
  area_code,
  episode_number,
  MIN(utc_timestamp) AS episode_start_utc,
  MAX(utc_timestamp) AS episode_end_utc,
  TIMESTAMP_DIFF(MAX(utc_timestamp), MIN(utc_timestamp), HOUR) + 1 AS span_hours,
  COUNT(*) AS flagged_hours,
  ROUND(MAX(median_load_mw), 1) AS median_load_mw,
  ROUND(MIN(load_mw), 1) AS lowest_flagged_mw,
  ROUND(MAX(load_mw), 1) AS highest_flagged_mw
FROM flagged_hours_with_episode
GROUP BY area_code, episode_number
ORDER BY area_code, episode_start_utc;
