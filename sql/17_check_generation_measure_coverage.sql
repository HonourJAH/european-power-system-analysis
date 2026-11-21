WITH hours_by_area AS (
  SELECT
    area_code,
    COUNTIF(measure_type = 'solar_generation_actual') AS solar_hours,
    COUNTIF(measure_type = 'wind_onshore_generation_actual') AS wind_onshore_hours,
    COUNTIF(measure_type = 'wind_offshore_generation_actual') AS wind_offshore_hours,
    COUNTIF(measure_type = 'wind_generation_actual') AS wind_total_hours
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type IN ('solar_generation_actual', 'wind_onshore_generation_actual',
                         'wind_offshore_generation_actual', 'wind_generation_actual')
    AND utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
  GROUP BY area_code
)

SELECT
  area_code,
  solar_hours,
  wind_onshore_hours,
  wind_offshore_hours,
  wind_total_hours,
  1 AS sort_order
FROM hours_by_area

UNION ALL

SELECT
  '== areas with readings ==',
  COUNTIF(solar_hours > 0),
  COUNTIF(wind_onshore_hours > 0),
  COUNTIF(wind_offshore_hours > 0),
  COUNTIF(wind_total_hours > 0),
  0
FROM hours_by_area

ORDER BY sort_order, area_code;
