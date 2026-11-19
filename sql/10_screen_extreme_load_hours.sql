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

flagged_readings AS (
  SELECT
    country_load_readings.area_code,
    country_load_readings.load_mw,
    country_medians.median_load_mw,
    country_load_readings.load_mw > 2 * country_medians.median_load_mw AS above_twice_median,
    country_load_readings.load_mw < 0.25 * country_medians.median_load_mw AS below_quarter_median
  FROM country_load_readings
  INNER JOIN country_medians
    ON country_load_readings.area_code = country_medians.area_code
)

SELECT
  area_code,
  COUNT(*) AS filled_hours,
  ROUND(MAX(median_load_mw), 1) AS median_load_mw,
  COUNTIF(above_twice_median) AS hours_above_twice_median,
  COUNTIF(below_quarter_median) AS hours_below_quarter_median,
  COUNTIF(above_twice_median OR below_quarter_median) AS flagged_hours,
  ROUND(AVG(load_mw), 1) AS mean_all_hours_mw,
  ROUND(AVG(IF(NOT above_twice_median AND NOT below_quarter_median, load_mw, NULL)), 1) AS mean_without_flagged_hours_mw,
  ROUND(AVG(load_mw)
        - AVG(IF(NOT above_twice_median AND NOT below_quarter_median, load_mw, NULL)), 1) AS mean_change_mw
FROM flagged_readings
GROUP BY area_code
HAVING COUNT(*) >= 50000
ORDER BY flagged_hours DESC, area_code;
