WITH wind_by_hour AS (
  SELECT
    area_code,
    utc_timestamp,
    MAX(IF(measure_type = 'wind_generation_actual', reading, NULL)) AS wind_total_mw,
    MAX(IF(measure_type = 'wind_onshore_generation_actual', reading, NULL)) AS wind_onshore_mw,
    MAX(IF(measure_type = 'wind_offshore_generation_actual', reading, NULL)) AS wind_offshore_mw
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type IN ('wind_generation_actual', 'wind_onshore_generation_actual',
                         'wind_offshore_generation_actual')
    AND utc_timestamp >= TIMESTAMP '2015-01-01 00:00:00+00'
  GROUP BY area_code, utc_timestamp
)

SELECT
  area_code,
  COUNTIF(wind_total_mw IS NOT NULL) AS hours_with_wind_total,
  COUNTIF(wind_total_mw IS NOT NULL AND wind_onshore_mw IS NOT NULL AND wind_offshore_mw IS NOT NULL) AS hours_with_total_and_both_parts,
  ROUND(AVG(IF(wind_total_mw IS NOT NULL AND wind_onshore_mw IS NOT NULL AND wind_offshore_mw IS NOT NULL,
               ABS(wind_total_mw - (wind_onshore_mw + wind_offshore_mw)), NULL)), 1) AS mean_gap_total_vs_parts_mw,
  ROUND(MAX(IF(wind_total_mw IS NOT NULL AND wind_onshore_mw IS NOT NULL AND wind_offshore_mw IS NOT NULL,
               ABS(wind_total_mw - (wind_onshore_mw + wind_offshore_mw)), NULL)), 1) AS max_gap_total_vs_parts_mw,
  ROUND(AVG(IF(wind_total_mw IS NOT NULL AND wind_offshore_mw IS NOT NULL,
               ABS(wind_total_mw - wind_offshore_mw), NULL)), 1) AS mean_gap_total_vs_offshore_mw,
  ROUND(AVG(IF(wind_total_mw IS NOT NULL AND wind_onshore_mw IS NOT NULL,
               ABS(wind_total_mw - wind_onshore_mw), NULL)), 1) AS mean_gap_total_vs_onshore_mw,
  ROUND(AVG(wind_total_mw), 1) AS mean_wind_total_mw
FROM wind_by_hour
GROUP BY area_code
HAVING COUNTIF(wind_total_mw IS NOT NULL) > 0
ORDER BY area_code;
