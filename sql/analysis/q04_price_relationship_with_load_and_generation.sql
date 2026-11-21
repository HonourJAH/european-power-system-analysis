CREATE TEMP FUNCTION period_labels(utc_hour TIMESTAMP) RETURNS ARRAY<STRING> AS (
  ARRAY_CONCAT(
    ['whole_period'],
    IF(EXTRACT(MONTH FROM utc_hour) <= 9,
       [CONCAT('year_', CAST(EXTRACT(YEAR FROM utc_hour) AS STRING))], ARRAY<STRING>[])
  )
);

WITH selected_zones AS (
  SELECT area_code, wind_measure_type, time_zone
  FROM UNNEST([
    STRUCT('DK_1' AS area_code, 'wind_generation_actual' AS wind_measure_type, 'Europe/Berlin' AS time_zone),
    ('DK_2', 'wind_generation_actual', 'Europe/Berlin'),
    ('GB_GBN', 'wind_generation_actual', 'Europe/London'),
    ('IT_CNOR', 'wind_onshore_generation_actual', 'Europe/Berlin'),
    ('IT_CSUD', 'wind_onshore_generation_actual', 'Europe/Berlin'),
    ('IT_NORD', 'wind_onshore_generation_actual', 'Europe/Berlin'),
    ('IT_SARD', 'wind_onshore_generation_actual', 'Europe/Berlin'),
    ('IT_SICI', 'wind_onshore_generation_actual', 'Europe/Berlin'),
    ('IT_SUD', 'wind_onshore_generation_actual', 'Europe/Berlin')
  ])
),

hourly_readings AS (
  SELECT
    readings.area_code,
    readings.utc_timestamp,
    selected_zones.time_zone,
    MAX(IF(readings.measure_type = 'price_day_ahead', readings.reading, NULL)) AS price_eur,
    MAX(IF(readings.measure_type = 'load_actual_entsoe_transparency', readings.reading, NULL)) AS load_mw,
    MAX(IF(readings.measure_type = 'solar_generation_actual', readings.reading, NULL)) AS solar_mw,
    MAX(IF(readings.measure_type = selected_zones.wind_measure_type, readings.reading, NULL)) AS wind_mw
  FROM `bigquery-514705.power_system.time_series_hourly_long` AS readings
  INNER JOIN selected_zones
    ON readings.area_code = selected_zones.area_code
  WHERE readings.utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
    AND readings.measure_type IN ('price_day_ahead', 'load_actual_entsoe_transparency',
                                  'solar_generation_actual', 'wind_generation_actual',
                                  'wind_onshore_generation_actual')
  GROUP BY readings.area_code, readings.utc_timestamp, selected_zones.time_zone
),

matched_hours AS (
  SELECT
    area_code,
    utc_timestamp,
    EXTRACT(HOUR FROM DATETIME(utc_timestamp, time_zone)) AS hour_of_day,
    price_eur,
    load_mw,
    wind_mw + solar_mw AS wind_and_solar_mw
  FROM hourly_readings
  WHERE price_eur IS NOT NULL AND load_mw IS NOT NULL AND solar_mw IS NOT NULL AND wind_mw IS NOT NULL
),

adjusted_hours AS (
  SELECT
    area_code,
    utc_timestamp,
    price_eur,
    load_mw,
    wind_and_solar_mw,
    price_eur - AVG(price_eur) OVER (PARTITION BY area_code, hour_of_day) AS price_adjusted,
    load_mw - AVG(load_mw) OVER (PARTITION BY area_code, hour_of_day) AS load_adjusted,
    wind_and_solar_mw - AVG(wind_and_solar_mw) OVER (PARTITION BY area_code, hour_of_day) AS generation_adjusted
  FROM matched_hours
),

expected_hours AS (
  SELECT
    period_label,
    COUNT(*) AS expected_hours
  FROM UNNEST(GENERATE_TIMESTAMP_ARRAY(
    TIMESTAMP '2015-01-01 00:00:00+00',
    TIMESTAMP '2020-09-30 23:00:00+00',
    INTERVAL 1 HOUR)) AS utc_hour,
  UNNEST(period_labels(utc_hour)) AS period_label
  GROUP BY period_label
),

period_results AS (
  SELECT
    area_code,
    period_label,
    COUNT(*) AS matched_hours,
    AVG(price_eur) AS mean_price_eur,
    MIN(price_eur) AS lowest_price_eur,
    COUNTIF(price_eur <= 0) AS hours_price_zero_or_negative,
    CORR(price_eur, load_mw) AS corr_price_load,
    CORR(price_eur, wind_and_solar_mw) AS corr_price_generation,
    CORR(price_adjusted, load_adjusted) AS corr_price_load_adjusted,
    CORR(price_adjusted, generation_adjusted) AS corr_price_generation_adjusted
  FROM adjusted_hours,
  UNNEST(period_labels(utc_timestamp)) AS period_label
  GROUP BY area_code, period_label
)

SELECT
  period_results.area_code,
  period_results.period_label,
  period_results.matched_hours,
  IF(period_results.period_label = 'whole_period',
     period_results.matched_hours >= 50000,
     SAFE_DIVIDE(period_results.matched_hours, expected_hours.expected_hours) >= 0.9) AS meets_rule,
  ROUND(period_results.mean_price_eur, 1) AS mean_price_eur,
  ROUND(period_results.lowest_price_eur, 1) AS lowest_price_eur,
  period_results.hours_price_zero_or_negative,
  ROUND(period_results.corr_price_load, 2) AS corr_price_load,
  ROUND(period_results.corr_price_generation, 2) AS corr_price_generation,
  ROUND(period_results.corr_price_load_adjusted, 2) AS corr_price_load_adjusted,
  ROUND(period_results.corr_price_generation_adjusted, 2) AS corr_price_generation_adjusted
FROM period_results
INNER JOIN expected_hours
  ON period_results.period_label = expected_hours.period_label
ORDER BY period_results.area_code, period_results.period_label;
