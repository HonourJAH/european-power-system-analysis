WITH country_totals_in_data AS (
  SELECT DISTINCT area_code
  FROM `bigquery-514705.power_system.time_series_hourly_long`
  WHERE measure_type = 'load_actual_entsoe_transparency'
    AND (STRPOS(area_code, '_') = 0 OR area_code = 'GB_UKM')
)

SELECT
  (SELECT COUNT(*) FROM `bigquery-514705.power_system.country_names`) AS names_in_table,
  COUNT(*) AS country_totals_in_data,
  COUNTIF(country_names.area_code IS NULL) AS country_totals_without_a_name
FROM country_totals_in_data
LEFT JOIN `bigquery-514705.power_system.country_names` AS country_names
  ON country_totals_in_data.area_code = country_names.area_code;
