SELECT
  COUNT(*) AS hours,
  COUNTIF(
    FORMAT_DATETIME('%Y-%m-%dT%H:%M:%S',
      DATETIME(SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%SZ', utc_timestamp), 'Europe/Berlin'))
    != SUBSTR(cet_cest_timestamp, 1, 19)
  ) AS local_time_mismatches
FROM `bigquery-514705.power_system.time_series_hourly_raw`;
