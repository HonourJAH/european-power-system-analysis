SELECT
  COUNT(*) AS suspect_hours,
  COUNTIF(flagged_by_screen) AS flagged_by_screen_hours,
  COUNTIF(NOT flagged_by_screen) AS inside_episode_not_flagged_hours,
  COUNT(DISTINCT CONCAT(area_code, '-', CAST(episode_number AS STRING))) AS episodes,
  COUNT(DISTINCT area_code) AS countries
FROM `bigquery-514705.power_system.suspect_load_hours`;
