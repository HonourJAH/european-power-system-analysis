WITH price_zones AS (
  SELECT DISTINCT area_code
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type = 'price_day_ahead'
),

zone_hours AS (
  SELECT
    readings.area_code,
    COUNTIF(readings.measure_type = 'price_day_ahead') AS price_hours,
    COUNTIF(readings.measure_type = 'load_actual_entsoe_transparency') AS load_hours,
    COUNTIF(readings.measure_type = 'solar_generation_actual') AS solar_hours,
    COUNTIF(readings.measure_type = IF(readings.area_code IN ('DE_LU', 'DK_1', 'DK_2', 'GB_GBN'),
                                       'wind_generation_actual',
                                       'wind_onshore_generation_actual')) AS wind_hours
  FROM `bigquery-514705.power_system.time_series_hourly_long` AS readings
  INNER JOIN price_zones
    ON readings.area_code = price_zones.area_code
  WHERE readings.utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
    AND readings.measure_type IN ('price_day_ahead', 'load_actual_entsoe_transparency',
                                  'solar_generation_actual', 'wind_generation_actual',
                                  'wind_onshore_generation_actual')
  GROUP BY readings.area_code
)

SELECT
  SUBSTR(area_code, 1, 2) AS country_code,
  area_code AS price_zone,
  price_hours,
  load_hours,
  solar_hours,
  wind_hours,
  price_hours >= 40000 AND load_hours >= 40000 AND solar_hours >= 40000 AND wind_hours >= 40000 AS meets_zone_rule
FROM zone_hours
ORDER BY meets_zone_rule DESC, country_code, price_zone;
