WITH x AS (
  SELECT
    SAFE_CAST(DE_load_actual_entsoe_transparency AS FLOAT64) AS ger,
    SAFE_CAST(DE_50hertz_load_actual_entsoe_transparency AS FLOAT64) AS ger_50hertz,
    SAFE_CAST(DE_amprion_load_actual_entsoe_transparency AS FLOAT64) AS ger_amprion,
    SAFE_CAST(DE_tennet_load_actual_entsoe_transparency AS FLOAT64) AS ger_tennet,
    SAFE_CAST(DE_transnetbw_load_actual_entsoe_transparency AS FLOAT64) AS ger_transnetbw,
    SAFE_CAST(DE_LU_load_actual_entsoe_transparency AS FLOAT64) AS ger_lux,
    SAFE_CAST(LU_load_actual_entsoe_transparency AS FLOAT64) AS lux,
    SAFE_CAST(DK_load_actual_entsoe_transparency AS FLOAT64) AS den,
    SAFE_CAST(DK_1_load_actual_entsoe_transparency AS FLOAT64) AS den_1,
    SAFE_CAST(DK_2_load_actual_entsoe_transparency AS FLOAT64) AS den_2,
    SAFE_CAST(NO_load_actual_entsoe_transparency AS FLOAT64) AS nor,
    SAFE_CAST(NO_1_load_actual_entsoe_transparency AS FLOAT64) AS nor_1,
    SAFE_CAST(NO_2_load_actual_entsoe_transparency AS FLOAT64) AS nor_2,
    SAFE_CAST(NO_3_load_actual_entsoe_transparency AS FLOAT64) AS nor_3,
    SAFE_CAST(NO_4_load_actual_entsoe_transparency AS FLOAT64) AS nor_4,
    SAFE_CAST(NO_5_load_actual_entsoe_transparency AS FLOAT64) AS nor_5,
    SAFE_CAST(SE_load_actual_entsoe_transparency AS FLOAT64) AS swe,
    SAFE_CAST(SE_1_load_actual_entsoe_transparency AS FLOAT64) AS swe_1,
    SAFE_CAST(SE_2_load_actual_entsoe_transparency AS FLOAT64) AS swe_2,
    SAFE_CAST(SE_3_load_actual_entsoe_transparency AS FLOAT64) AS swe_3,
    SAFE_CAST(SE_4_load_actual_entsoe_transparency AS FLOAT64) AS swe_4,
    SAFE_CAST(IT_load_actual_entsoe_transparency AS FLOAT64) AS ita,
    SAFE_CAST(IT_CNOR_load_actual_entsoe_transparency AS FLOAT64) AS ita_cnor,
    SAFE_CAST(IT_CSUD_load_actual_entsoe_transparency AS FLOAT64) AS ita_csud,
    SAFE_CAST(IT_NORD_load_actual_entsoe_transparency AS FLOAT64) AS ita_nord,
    SAFE_CAST(IT_SARD_load_actual_entsoe_transparency AS FLOAT64) AS ita_sard,
    SAFE_CAST(IT_SICI_load_actual_entsoe_transparency AS FLOAT64) AS ita_sici,
    SAFE_CAST(IT_SUD_load_actual_entsoe_transparency AS FLOAT64) AS ita_sud,
    SAFE_CAST(GB_UKM_load_actual_entsoe_transparency AS FLOAT64) AS gb_total,
    SAFE_CAST(GB_GBN_load_actual_entsoe_transparency AS FLOAT64) AS gb_gbn,
    SAFE_CAST(GB_NIR_load_actual_entsoe_transparency AS FLOAT64) AS gb_nir
  FROM `bigquery-514705.power_system.time_series_hourly_raw`
)
SELECT 'DE vs its four control areas' AS comparison,
  COUNT(*) AS hours_all_filled,
  ROUND(AVG(ABS(ger - (ger_50hertz + ger_amprion + ger_tennet + ger_transnetbw))), 1) AS mean_abs_diff_mw,
  ROUND(MAX(ABS(ger - (ger_50hertz + ger_amprion + ger_tennet + ger_transnetbw))), 1) AS max_abs_diff_mw,
  ROUND(AVG(ger), 1) AS mean_plain_mw
FROM x WHERE ger IS NOT NULL AND ger_50hertz IS NOT NULL AND ger_amprion IS NOT NULL AND ger_tennet IS NOT NULL AND ger_transnetbw IS NOT NULL
UNION ALL
SELECT 'DE_LU vs DE plus LU',
  COUNT(*),
  ROUND(AVG(ABS(ger_lux - (ger + lux))), 1),
  ROUND(MAX(ABS(ger_lux - (ger + lux))), 1),
  ROUND(AVG(ger_lux), 1)
FROM x WHERE ger_lux IS NOT NULL AND ger IS NOT NULL AND lux IS NOT NULL
UNION ALL
SELECT 'DK vs DK_1 plus DK_2',
  COUNT(*),
  ROUND(AVG(ABS(den - (den_1 + den_2))), 1),
  ROUND(MAX(ABS(den - (den_1 + den_2))), 1),
  ROUND(AVG(den), 1)
FROM x WHERE den IS NOT NULL AND den_1 IS NOT NULL AND den_2 IS NOT NULL
UNION ALL
SELECT 'NO vs NO_1 to NO_5',
  COUNT(*),
  ROUND(AVG(ABS(nor - (nor_1 + nor_2 + nor_3 + nor_4 + nor_5))), 1),
  ROUND(MAX(ABS(nor - (nor_1 + nor_2 + nor_3 + nor_4 + nor_5))), 1),
  ROUND(AVG(nor), 1)
FROM x WHERE nor IS NOT NULL AND nor_1 IS NOT NULL AND nor_2 IS NOT NULL AND nor_3 IS NOT NULL AND nor_4 IS NOT NULL AND nor_5 IS NOT NULL
UNION ALL
SELECT 'SE vs SE_1 to SE_4',
  COUNT(*),
  ROUND(AVG(ABS(swe - (swe_1 + swe_2 + swe_3 + swe_4))), 1),
  ROUND(MAX(ABS(swe - (swe_1 + swe_2 + swe_3 + swe_4))), 1),
  ROUND(AVG(swe), 1)
FROM x WHERE swe IS NOT NULL AND swe_1 IS NOT NULL AND swe_2 IS NOT NULL AND swe_3 IS NOT NULL AND swe_4 IS NOT NULL
UNION ALL
SELECT 'IT vs its six zones',
  COUNT(*),
  ROUND(AVG(ABS(ita - (ita_cnor + ita_csud + ita_nord + ita_sard + ita_sici + ita_sud))), 1),
  ROUND(MAX(ABS(ita - (ita_cnor + ita_csud + ita_nord + ita_sard + ita_sici + ita_sud))), 1),
  ROUND(AVG(ita), 1)
FROM x WHERE ita IS NOT NULL AND ita_cnor IS NOT NULL AND ita_csud IS NOT NULL AND ita_nord IS NOT NULL AND ita_sard IS NOT NULL AND ita_sici IS NOT NULL AND ita_sud IS NOT NULL
UNION ALL
SELECT 'GB_UKM vs GB_GBN plus GB_NIR',
  COUNT(*),
  ROUND(AVG(ABS(gb_total - (gb_gbn + gb_nir))), 1),
  ROUND(MAX(ABS(gb_total - (gb_gbn + gb_nir))), 1),
  ROUND(AVG(gb_total), 1)
FROM x WHERE gb_total IS NOT NULL AND gb_gbn IS NOT NULL AND gb_nir IS NOT NULL;
