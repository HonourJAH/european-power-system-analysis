WITH country_load_by_hour AS (
  SELECT
    area_code,
    utc_timestamp,
    MAX(IF(measure_type = 'load_actual_entsoe_transparency', reading, NULL)) AS actual_load_mw,
    MAX(IF(measure_type = 'load_forecast_entsoe_transparency', reading, NULL)) AS forecast_load_mw
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type IN ('load_actual_entsoe_transparency', 'load_forecast_entsoe_transparency')
    AND (STRPOS(area_code, '_') = 0 OR area_code = 'GB_UKM')
    AND utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
  GROUP BY area_code, utc_timestamp
),

hourly_errors AS (
  SELECT
    country_load_by_hour.area_code,
    EXTRACT(HOUR FROM country_load_by_hour.utc_timestamp) AS hour_utc,
    100 * ABS(country_load_by_hour.forecast_load_mw - country_load_by_hour.actual_load_mw)
        / country_load_by_hour.actual_load_mw AS error_pct
  FROM country_load_by_hour
  LEFT JOIN `bigquery-514705.power_system.suspect_load_hours` AS suspect_load_hours
    ON country_load_by_hour.area_code = suspect_load_hours.area_code
    AND country_load_by_hour.utc_timestamp = suspect_load_hours.utc_timestamp
  WHERE country_load_by_hour.actual_load_mw > 0
    AND country_load_by_hour.forecast_load_mw IS NOT NULL
    AND suspect_load_hours.utc_timestamp IS NULL
),

median_error_by_hour AS (
  SELECT
    area_code,
    hour_utc,
    COUNT(*) AS matched_hours,
    APPROX_QUANTILES(error_pct, 100)[OFFSET(50)] AS median_error_pct
  FROM hourly_errors
  GROUP BY area_code, hour_utc
),

countries_meeting_rule AS (
  SELECT area_code
  FROM median_error_by_hour
  GROUP BY area_code
  HAVING SUM(matched_hours) >= 50000
),

ranked_hours AS (
  SELECT
    median_error_by_hour.area_code,
    median_error_by_hour.hour_utc,
    median_error_by_hour.median_error_pct,
    ROW_NUMBER() OVER (PARTITION BY median_error_by_hour.area_code ORDER BY median_error_by_hour.median_error_pct DESC) AS rank_worst,
    ROW_NUMBER() OVER (PARTITION BY median_error_by_hour.area_code ORDER BY median_error_by_hour.median_error_pct ASC) AS rank_best
  FROM median_error_by_hour
  INNER JOIN countries_meeting_rule
    ON median_error_by_hour.area_code = countries_meeting_rule.area_code
)

SELECT
  country_names.country_name,
  ranked_hours.area_code,
  MAX(IF(rank_worst = 1, hour_utc, NULL)) AS worst_hour_utc,
  ROUND(MAX(IF(rank_worst = 1, median_error_pct, NULL)), 2) AS worst_hour_median_error_pct,
  MAX(IF(rank_best = 1, hour_utc, NULL)) AS best_hour_utc,
  ROUND(MAX(IF(rank_best = 1, median_error_pct, NULL)), 2) AS best_hour_median_error_pct,
  ROUND(SAFE_DIVIDE(MAX(IF(rank_worst = 1, median_error_pct, NULL)),
                    MAX(IF(rank_best = 1, median_error_pct, NULL))), 2) AS worst_to_best_ratio
FROM ranked_hours
INNER JOIN `bigquery-514705.power_system.country_names` AS country_names
  ON ranked_hours.area_code = country_names.area_code
GROUP BY country_names.country_name, ranked_hours.area_code
ORDER BY country_names.country_name;
