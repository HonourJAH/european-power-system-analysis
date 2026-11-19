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

readings_with_neighbours AS (
  SELECT
    area_code,
    utc_timestamp,
    load_mw,
    LAG(load_mw) OVER (PARTITION BY area_code ORDER BY utc_timestamp) AS previous_reading_load_mw,
    LEAD(load_mw) OVER (PARTITION BY area_code ORDER BY utc_timestamp) AS next_reading_load_mw,
    TIMESTAMP_DIFF(
      utc_timestamp,
      LAG(utc_timestamp) OVER (PARTITION BY area_code ORDER BY utc_timestamp),
      HOUR) AS hours_since_previous_reading
  FROM country_load_readings
)

SELECT
  readings_with_neighbours.area_code,
  readings_with_neighbours.utc_timestamp,
  readings_with_neighbours.load_mw,
  ROUND(country_medians.median_load_mw, 1) AS median_load_mw,
  readings_with_neighbours.previous_reading_load_mw,
  readings_with_neighbours.next_reading_load_mw,
  readings_with_neighbours.hours_since_previous_reading
FROM readings_with_neighbours
INNER JOIN country_medians
  ON readings_with_neighbours.area_code = country_medians.area_code
WHERE readings_with_neighbours.load_mw > 2 * country_medians.median_load_mw
   OR readings_with_neighbours.load_mw < 0.25 * country_medians.median_load_mw
ORDER BY readings_with_neighbours.area_code, readings_with_neighbours.utc_timestamp;
