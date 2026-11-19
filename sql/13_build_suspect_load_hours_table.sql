CREATE OR REPLACE TABLE `bigquery-514705.power_system.suspect_load_hours`
CLUSTER BY area_code
AS
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
    country_load_readings.load_mw
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
    SUM(IF(hours_since_previous_flagged_hour IS NULL OR hours_since_previous_flagged_hour > 12, 1, 0))
      OVER (PARTITION BY area_code ORDER BY utc_timestamp) AS episode_number
  FROM flagged_hours_with_gap
),

episode_spans AS (
  SELECT
    area_code,
    episode_number,
    MIN(utc_timestamp) AS episode_start_utc,
    MAX(utc_timestamp) AS episode_end_utc
  FROM flagged_hours_with_episode
  GROUP BY area_code, episode_number
)

SELECT
  country_load_readings.area_code,
  country_load_readings.utc_timestamp,
  country_load_readings.load_mw,
  episode_spans.episode_number,
  flagged_hours.utc_timestamp IS NOT NULL AS flagged_by_screen
FROM country_load_readings
INNER JOIN episode_spans
  ON country_load_readings.area_code = episode_spans.area_code
  AND country_load_readings.utc_timestamp BETWEEN episode_spans.episode_start_utc AND episode_spans.episode_end_utc
LEFT JOIN flagged_hours
  ON country_load_readings.area_code = flagged_hours.area_code
  AND country_load_readings.utc_timestamp = flagged_hours.utc_timestamp;
