WITH central_european_countries AS (
  SELECT area_code
  FROM UNNEST(['AT', 'BE', 'CH', 'CZ', 'DE', 'DK', 'ES', 'FR', 'HR', 'HU',
               'IT', 'LU', 'ME', 'NL', 'NO', 'PL', 'SE', 'SI', 'SK']) AS area_code
),

load_readings_local_time AS (
  SELECT
    readings.area_code,
    DATETIME(readings.utc_timestamp, 'Europe/Berlin') AS local_datetime,
    readings.reading AS load_mw
  FROM `bigquery-514705.power_system.time_series_hourly_long` AS readings
  INNER JOIN central_european_countries
    ON readings.area_code = central_european_countries.area_code
  LEFT JOIN `bigquery-514705.power_system.suspect_load_hours` AS suspect_load_hours
    ON readings.area_code = suspect_load_hours.area_code
    AND readings.utc_timestamp = suspect_load_hours.utc_timestamp
  WHERE readings.measure_type = 'load_actual_entsoe_transparency'
    AND readings.utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
    AND readings.utc_timestamp < TIMESTAMP '2020-01-01 00:00:00+00'
    AND suspect_load_hours.utc_timestamp IS NULL
),

valid_hours_by_country AS (
  SELECT
    area_code,
    COUNT(*) AS valid_hours
  FROM load_readings_local_time
  GROUP BY area_code
),

mean_load_by_hour_of_day AS (
  SELECT
    area_code,
    EXTRACT(HOUR FROM local_datetime) AS hour_of_day,
    AVG(load_mw) AS mean_load_mw
  FROM load_readings_local_time
  GROUP BY area_code, hour_of_day
),

ranked_hours AS (
  SELECT
    area_code,
    hour_of_day,
    mean_load_mw,
    ROW_NUMBER() OVER (PARTITION BY area_code ORDER BY mean_load_mw DESC) AS rank_highest,
    ROW_NUMBER() OVER (PARTITION BY area_code ORDER BY mean_load_mw ASC) AS rank_lowest
  FROM mean_load_by_hour_of_day
),

hour_summary AS (
  SELECT
    area_code,
    MAX(IF(rank_highest = 1, hour_of_day, NULL)) AS peak_hour_local,
    MAX(IF(rank_highest = 1, mean_load_mw, NULL)) AS peak_hour_mean_mw,
    MAX(IF(rank_lowest = 1, hour_of_day, NULL)) AS lowest_hour_local,
    MAX(IF(rank_lowest = 1, mean_load_mw, NULL)) AS lowest_hour_mean_mw
  FROM ranked_hours
  GROUP BY area_code
),

mean_load_by_weekday AS (
  SELECT
    area_code,
    FORMAT_DATE('%A', DATE(local_datetime)) AS weekday_name,
    AVG(load_mw) AS mean_load_mw
  FROM load_readings_local_time
  GROUP BY area_code, weekday_name
),

ranked_weekdays AS (
  SELECT
    area_code,
    weekday_name,
    mean_load_mw,
    ROW_NUMBER() OVER (PARTITION BY area_code ORDER BY mean_load_mw DESC) AS rank_busiest,
    ROW_NUMBER() OVER (PARTITION BY area_code ORDER BY mean_load_mw ASC) AS rank_quietest
  FROM mean_load_by_weekday
),

weekday_summary AS (
  SELECT
    area_code,
    MAX(IF(rank_busiest = 1, weekday_name, NULL)) AS busiest_weekday,
    MAX(IF(rank_busiest = 1, mean_load_mw, NULL)) AS busiest_weekday_mean_mw,
    MAX(IF(rank_quietest = 1, weekday_name, NULL)) AS quietest_weekday,
    MAX(IF(rank_quietest = 1, mean_load_mw, NULL)) AS quietest_weekday_mean_mw
  FROM ranked_weekdays
  GROUP BY area_code
)

SELECT
  country_names.country_name,
  hour_summary.area_code,
  valid_hours_by_country.valid_hours,
  hour_summary.peak_hour_local,
  ROUND(hour_summary.peak_hour_mean_mw, 1) AS peak_hour_mean_mw,
  hour_summary.lowest_hour_local,
  ROUND(hour_summary.lowest_hour_mean_mw, 1) AS lowest_hour_mean_mw,
  ROUND(SAFE_DIVIDE(hour_summary.peak_hour_mean_mw, hour_summary.lowest_hour_mean_mw), 2) AS peak_to_lowest_hour_ratio,
  weekday_summary.busiest_weekday,
  ROUND(weekday_summary.busiest_weekday_mean_mw, 1) AS busiest_weekday_mean_mw,
  weekday_summary.quietest_weekday,
  ROUND(weekday_summary.quietest_weekday_mean_mw, 1) AS quietest_weekday_mean_mw,
  ROUND(100 * SAFE_DIVIDE(weekday_summary.quietest_weekday_mean_mw, weekday_summary.busiest_weekday_mean_mw) - 100, 1) AS quietest_vs_busiest_weekday_pct
FROM hour_summary
INNER JOIN weekday_summary
  ON hour_summary.area_code = weekday_summary.area_code
INNER JOIN valid_hours_by_country
  ON hour_summary.area_code = valid_hours_by_country.area_code
INNER JOIN `bigquery-514705.power_system.country_names` AS country_names
  ON hour_summary.area_code = country_names.area_code
ORDER BY country_names.country_name;
