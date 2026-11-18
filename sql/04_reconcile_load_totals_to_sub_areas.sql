WITH load_by_hour AS (
  SELECT
    SAFE_CAST(DE_load_actual_entsoe_transparency AS FLOAT64) AS germany_total_mw,
    SAFE_CAST(DE_50hertz_load_actual_entsoe_transparency AS FLOAT64) AS germany_50hertz_area_mw,
    SAFE_CAST(DE_amprion_load_actual_entsoe_transparency AS FLOAT64) AS germany_amprion_area_mw,
    SAFE_CAST(DE_tennet_load_actual_entsoe_transparency AS FLOAT64) AS germany_tennet_area_mw,
    SAFE_CAST(DE_transnetbw_load_actual_entsoe_transparency AS FLOAT64) AS germany_transnetbw_area_mw,
    SAFE_CAST(DE_LU_load_actual_entsoe_transparency AS FLOAT64) AS germany_luxembourg_zone_mw,
    SAFE_CAST(LU_load_actual_entsoe_transparency AS FLOAT64) AS luxembourg_total_mw,
    SAFE_CAST(DK_load_actual_entsoe_transparency AS FLOAT64) AS denmark_total_mw,
    SAFE_CAST(DK_1_load_actual_entsoe_transparency AS FLOAT64) AS denmark_zone_1_mw,
    SAFE_CAST(DK_2_load_actual_entsoe_transparency AS FLOAT64) AS denmark_zone_2_mw,
    SAFE_CAST(NO_load_actual_entsoe_transparency AS FLOAT64) AS norway_total_mw,
    SAFE_CAST(NO_1_load_actual_entsoe_transparency AS FLOAT64) AS norway_zone_1_mw,
    SAFE_CAST(NO_2_load_actual_entsoe_transparency AS FLOAT64) AS norway_zone_2_mw,
    SAFE_CAST(NO_3_load_actual_entsoe_transparency AS FLOAT64) AS norway_zone_3_mw,
    SAFE_CAST(NO_4_load_actual_entsoe_transparency AS FLOAT64) AS norway_zone_4_mw,
    SAFE_CAST(NO_5_load_actual_entsoe_transparency AS FLOAT64) AS norway_zone_5_mw,
    SAFE_CAST(SE_load_actual_entsoe_transparency AS FLOAT64) AS sweden_total_mw,
    SAFE_CAST(SE_1_load_actual_entsoe_transparency AS FLOAT64) AS sweden_zone_1_mw,
    SAFE_CAST(SE_2_load_actual_entsoe_transparency AS FLOAT64) AS sweden_zone_2_mw,
    SAFE_CAST(SE_3_load_actual_entsoe_transparency AS FLOAT64) AS sweden_zone_3_mw,
    SAFE_CAST(SE_4_load_actual_entsoe_transparency AS FLOAT64) AS sweden_zone_4_mw,
    SAFE_CAST(IT_load_actual_entsoe_transparency AS FLOAT64) AS italy_total_mw,
    SAFE_CAST(IT_CNOR_load_actual_entsoe_transparency AS FLOAT64) AS italy_cnor_zone_mw,
    SAFE_CAST(IT_CSUD_load_actual_entsoe_transparency AS FLOAT64) AS italy_csud_zone_mw,
    SAFE_CAST(IT_NORD_load_actual_entsoe_transparency AS FLOAT64) AS italy_nord_zone_mw,
    SAFE_CAST(IT_SARD_load_actual_entsoe_transparency AS FLOAT64) AS italy_sard_zone_mw,
    SAFE_CAST(IT_SICI_load_actual_entsoe_transparency AS FLOAT64) AS italy_sici_zone_mw,
    SAFE_CAST(IT_SUD_load_actual_entsoe_transparency AS FLOAT64) AS italy_sud_zone_mw,
    SAFE_CAST(GB_UKM_load_actual_entsoe_transparency AS FLOAT64) AS great_britain_ukm_total_mw,
    SAFE_CAST(GB_GBN_load_actual_entsoe_transparency AS FLOAT64) AS great_britain_gbn_area_mw,
    SAFE_CAST(GB_NIR_load_actual_entsoe_transparency AS FLOAT64) AS great_britain_nir_area_mw
  FROM `bigquery-514705.power_system.time_series_hourly_raw`
)

SELECT
  'DE vs its four control areas' AS comparison,
  COUNT(*) AS hours_all_filled,
  ROUND(AVG(ABS(germany_total_mw - (germany_50hertz_area_mw + germany_amprion_area_mw + germany_tennet_area_mw + germany_transnetbw_area_mw))), 1) AS mean_abs_diff_mw,
  ROUND(MAX(ABS(germany_total_mw - (germany_50hertz_area_mw + germany_amprion_area_mw + germany_tennet_area_mw + germany_transnetbw_area_mw))), 1) AS max_abs_diff_mw,
  ROUND(AVG(germany_total_mw), 1) AS mean_plain_mw
FROM load_by_hour
WHERE germany_total_mw IS NOT NULL AND germany_50hertz_area_mw IS NOT NULL AND germany_amprion_area_mw IS NOT NULL
  AND germany_tennet_area_mw IS NOT NULL AND germany_transnetbw_area_mw IS NOT NULL

UNION ALL

SELECT
  'DE_LU vs DE plus LU',
  COUNT(*),
  ROUND(AVG(ABS(germany_luxembourg_zone_mw - (germany_total_mw + luxembourg_total_mw))), 1),
  ROUND(MAX(ABS(germany_luxembourg_zone_mw - (germany_total_mw + luxembourg_total_mw))), 1),
  ROUND(AVG(germany_luxembourg_zone_mw), 1)
FROM load_by_hour
WHERE germany_luxembourg_zone_mw IS NOT NULL AND germany_total_mw IS NOT NULL AND luxembourg_total_mw IS NOT NULL

UNION ALL

SELECT
  'DK vs DK_1 plus DK_2',
  COUNT(*),
  ROUND(AVG(ABS(denmark_total_mw - (denmark_zone_1_mw + denmark_zone_2_mw))), 1),
  ROUND(MAX(ABS(denmark_total_mw - (denmark_zone_1_mw + denmark_zone_2_mw))), 1),
  ROUND(AVG(denmark_total_mw), 1)
FROM load_by_hour
WHERE denmark_total_mw IS NOT NULL AND denmark_zone_1_mw IS NOT NULL AND denmark_zone_2_mw IS NOT NULL

UNION ALL

SELECT
  'NO vs NO_1 to NO_5',
  COUNT(*),
  ROUND(AVG(ABS(norway_total_mw - (norway_zone_1_mw + norway_zone_2_mw + norway_zone_3_mw + norway_zone_4_mw + norway_zone_5_mw))), 1),
  ROUND(MAX(ABS(norway_total_mw - (norway_zone_1_mw + norway_zone_2_mw + norway_zone_3_mw + norway_zone_4_mw + norway_zone_5_mw))), 1),
  ROUND(AVG(norway_total_mw), 1)
FROM load_by_hour
WHERE norway_total_mw IS NOT NULL AND norway_zone_1_mw IS NOT NULL AND norway_zone_2_mw IS NOT NULL
  AND norway_zone_3_mw IS NOT NULL AND norway_zone_4_mw IS NOT NULL AND norway_zone_5_mw IS NOT NULL

UNION ALL

SELECT
  'SE vs SE_1 to SE_4',
  COUNT(*),
  ROUND(AVG(ABS(sweden_total_mw - (sweden_zone_1_mw + sweden_zone_2_mw + sweden_zone_3_mw + sweden_zone_4_mw))), 1),
  ROUND(MAX(ABS(sweden_total_mw - (sweden_zone_1_mw + sweden_zone_2_mw + sweden_zone_3_mw + sweden_zone_4_mw))), 1),
  ROUND(AVG(sweden_total_mw), 1)
FROM load_by_hour
WHERE sweden_total_mw IS NOT NULL AND sweden_zone_1_mw IS NOT NULL AND sweden_zone_2_mw IS NOT NULL
  AND sweden_zone_3_mw IS NOT NULL AND sweden_zone_4_mw IS NOT NULL

UNION ALL

SELECT
  'IT vs its six zones',
  COUNT(*),
  ROUND(AVG(ABS(italy_total_mw - (italy_cnor_zone_mw + italy_csud_zone_mw + italy_nord_zone_mw + italy_sard_zone_mw + italy_sici_zone_mw + italy_sud_zone_mw))), 1),
  ROUND(MAX(ABS(italy_total_mw - (italy_cnor_zone_mw + italy_csud_zone_mw + italy_nord_zone_mw + italy_sard_zone_mw + italy_sici_zone_mw + italy_sud_zone_mw))), 1),
  ROUND(AVG(italy_total_mw), 1)
FROM load_by_hour
WHERE italy_total_mw IS NOT NULL AND italy_cnor_zone_mw IS NOT NULL AND italy_csud_zone_mw IS NOT NULL
  AND italy_nord_zone_mw IS NOT NULL AND italy_sard_zone_mw IS NOT NULL AND italy_sici_zone_mw IS NOT NULL
  AND italy_sud_zone_mw IS NOT NULL

UNION ALL

SELECT
  'GB_UKM vs GB_GBN plus GB_NIR',
  COUNT(*),
  ROUND(AVG(ABS(great_britain_ukm_total_mw - (great_britain_gbn_area_mw + great_britain_nir_area_mw))), 1),
  ROUND(MAX(ABS(great_britain_ukm_total_mw - (great_britain_gbn_area_mw + great_britain_nir_area_mw))), 1),
  ROUND(AVG(great_britain_ukm_total_mw), 1)
FROM load_by_hour
WHERE great_britain_ukm_total_mw IS NOT NULL AND great_britain_gbn_area_mw IS NOT NULL AND great_britain_nir_area_mw IS NOT NULL;
