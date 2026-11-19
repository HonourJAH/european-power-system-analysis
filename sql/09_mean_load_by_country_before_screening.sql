WITH country_load_readings AS (
  SELECT
    area_code,
    utc_timestamp,
    reading AS load_mw
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type = 'load_actual_entsoe_transparency'
    AND (STRPOS(area_code, '_') = 0 OR area_code = 'GB_UKM')
    AND utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
)

SELECT
  area_code,
  COUNT(*) AS filled_hours,
  ROUND(AVG(load_mw), 1) AS mean_load_mw,
  ROUND(MIN(load_mw), 1) AS lowest_hour_mw,
  ROUND(MAX(load_mw), 1) AS highest_hour_mw,
  COUNTIF(load_mw <= 0) AS zero_or_negative_hours,
  RANK() OVER (ORDER BY AVG(load_mw) DESC) AS rank_by_mean_load
FROM country_load_readings
GROUP BY area_code
HAVING COUNT(*) >= 50000
ORDER BY mean_load_mw DESC;
