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
    AND suspect_load_hours.utc_timestamp IS NULL
),

period_readings AS (
  SELECT
    load_readings_local_time.area_code,
    EXTRACT(HOUR FROM load_readings_local_time.local_datetime) AS hour_of_day,
    load_readings_local_time.load_mw,
    period_label
  FROM load_readings_local_time,
  UNNEST(ARRAY_CONCAT(
    IF(EXTRACT(MONTH FROM local_datetime) IN (1, 2),
       ['winter_2015_2020'], ARRAY<STRING>[]),
    IF(EXTRACT(MONTH FROM local_datetime) IN (6, 7, 8),
       ['summer_2015_2020'], ARRAY<STRING>[]),
    IF(EXTRACT(MONTH FROM local_datetime) IN (3, 4, 5) AND EXTRACT(YEAR FROM local_datetime) <= 2019,
       ['spring_2015_2019'], ARRAY<STRING>[]),
    IF(EXTRACT(MONTH FROM local_datetime) IN (3, 4, 5) AND EXTRACT(YEAR FROM local_datetime) = 2020,
       ['spring_2020'], ARRAY<STRING>[]),
    IF(EXTRACT(YEAR FROM local_datetime) <= 2019,
       [CONCAT('year_', CAST(EXTRACT(YEAR FROM local_datetime) AS STRING))], ARRAY<STRING>[])
  )) AS period_label
),

mean_load_by_period_and_hour AS (
  SELECT
    area_code,
    period_label,
    hour_of_day,
    COUNT(*) AS hours_counted,
    AVG(load_mw) AS mean_load_mw
  FROM period_readings
  GROUP BY area_code, period_label, hour_of_day
),

ranked_hours AS (
  SELECT
    area_code,
    period_label,
    hour_of_day,
    hours_counted,
    mean_load_mw,
    ROW_NUMBER() OVER (PARTITION BY area_code, period_label ORDER BY mean_load_mw DESC) AS rank_highest,
    ROW_NUMBER() OVER (PARTITION BY area_code, period_label ORDER BY mean_load_mw ASC) AS rank_lowest
  FROM mean_load_by_period_and_hour
),

period_summary AS (
  SELECT
    area_code,
    period_label,
    SUM(hours_counted) AS valid_hours,
    MAX(IF(rank_highest = 1, hour_of_day, NULL)) AS peak_hour_local,
    SAFE_DIVIDE(
      MAX(IF(rank_highest = 1, mean_load_mw, NULL)),
      MAX(IF(rank_lowest = 1, mean_load_mw, NULL))) AS peak_to_lowest_hour_ratio
  FROM ranked_hours
  GROUP BY area_code, period_label
)

SELECT
  country_names.country_name,
  period_summary.area_code,
  MAX(IF(period_label = 'winter_2015_2020', valid_hours, NULL)) AS winter_hours,
  MAX(IF(period_label = 'winter_2015_2020', peak_hour_local, NULL)) AS winter_peak_hour,
  ROUND(MAX(IF(period_label = 'winter_2015_2020', peak_to_lowest_hour_ratio, NULL)), 2) AS winter_ratio,
  MAX(IF(period_label = 'summer_2015_2020', valid_hours, NULL)) AS summer_hours,
  MAX(IF(period_label = 'summer_2015_2020', peak_hour_local, NULL)) AS summer_peak_hour,
  ROUND(MAX(IF(period_label = 'summer_2015_2020', peak_to_lowest_hour_ratio, NULL)), 2) AS summer_ratio,
  MAX(IF(period_label = 'spring_2015_2019', valid_hours, NULL)) AS spring_2015_2019_hours,
  MAX(IF(period_label = 'spring_2015_2019', peak_hour_local, NULL)) AS spring_2015_2019_peak_hour,
  ROUND(MAX(IF(period_label = 'spring_2015_2019', peak_to_lowest_hour_ratio, NULL)), 2) AS spring_2015_2019_ratio,
  MAX(IF(period_label = 'spring_2020', valid_hours, NULL)) AS spring_2020_hours,
  MAX(IF(period_label = 'spring_2020', peak_hour_local, NULL)) AS spring_2020_peak_hour,
  ROUND(MAX(IF(period_label = 'spring_2020', peak_to_lowest_hour_ratio, NULL)), 2) AS spring_2020_ratio,
  MAX(IF(period_label = 'year_2015', peak_hour_local, NULL)) AS peak_hour_2015,
  MAX(IF(period_label = 'year_2016', peak_hour_local, NULL)) AS peak_hour_2016,
  MAX(IF(period_label = 'year_2017', peak_hour_local, NULL)) AS peak_hour_2017,
  MAX(IF(period_label = 'year_2018', peak_hour_local, NULL)) AS peak_hour_2018,
  MAX(IF(period_label = 'year_2019', peak_hour_local, NULL)) AS peak_hour_2019,
  ROUND(MIN(IF(STARTS_WITH(period_label, 'year_'), peak_to_lowest_hour_ratio, NULL)), 2) AS lowest_yearly_ratio,
  ROUND(MAX(IF(STARTS_WITH(period_label, 'year_'), peak_to_lowest_hour_ratio, NULL)), 2) AS highest_yearly_ratio
FROM period_summary
INNER JOIN `bigquery-514705.power_system.country_names` AS country_names
  ON period_summary.area_code = country_names.area_code
GROUP BY country_names.country_name, period_summary.area_code
ORDER BY country_names.country_name;
