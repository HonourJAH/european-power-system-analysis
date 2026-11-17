# Decision Log

This log records every finding from profiling and every decision taken, in the order they were made. Each entry states what was found, what was decided, why, and the limit of the decision.

The data is the Open Power System Data time series package (version 2020-10-06), which compiles hourly electricity load, wind and solar generation and prices for European countries. The primary data comes from the ENTSO-E Transparency Platform and the transmission system operators of each country. The work is done in Google BigQuery, using the free sandbox.

## Part 1: Source, loading and first checks

### Decision 1: Use the 60-minute single-index file and keep the data out of the repository

- **Found:** The package offers 15-minute, 30-minute and 60-minute CSV files and an Excel workbook. The 60-minute file is described on the package page as hourly resolution for load, wind, solar and prices. The licence section of the package README gives an attribution line and no licence name, and datapackage.json holds no licence field. A package page note says this version only contains data provided by transmission system operators and power exchanges through ENTSO-E Transparency.
- **Decided:** The project uses time_series_60min_singleindex.csv. The file is stored in data/raw, which Git ignores, so no data is published in the repository. The attribution line from the package is quoted in the README: "Open Power System Data. 2020. Data Package Time series. Version 2020-10-06. https://doi.org/10.25832/time_series/2020-10-06. (Primary data from various sources, for a complete list see URL)."
- **Why:** An hourly series over several years allows questions about daily, seasonal and yearly patterns. Publishing only queries and findings, with attribution, keeps the risk from unclear re-use terms low.
- **Limit:** I could not confirm the exact licence terms for the ENTSO-E data in this package. The terms of the ENTSO-E Transparency Platform and the primary data owners apply, and need to be read before publishing.

### Decision 2: Load the raw file unchanged, as text, in two parts

- **Found:** The file is 125 MB (the console upload limit for a local file is 100 MB). It has 300 columns and 50,402 lines, including the header.
- **Decided:** The file was split into two parts. Part 1 holds the header and 25,200 rows, and part 2 holds 25,201 rows with no header. Both were loaded into one table, bigquery-514705.power_system.time_series_hourly_raw, with every column set to STRING, using a schema built from the header row. Part 2 was appended to the table with the header rows to skip set to 0. The dataset location is EU.
- **Why:** Loading every column as text means nothing is converted silently on the way in. The raw layer can be traced to the source file, in the same way as the raw layers in the earlier projects.
- **Limit:** The timestamps are still text, and the readings are still text. They are typed in a later step. The sandbox expires tables after 60 days (this table expires on 15 January 2027), so the SQL scripts in the sql folder and this log are the lasting record.

Table 1.1: The loaded table, checked against the source file

| Measure | Source file | Table in BigQuery | Difference |
| --- | --- | --- | --- |
| Data rows | 50,401 | 50,401 | 0 |
| Columns | 300 | 300 | 0 |
| Columns stored as text | 300 | 300 | 0 |

### Decision 3: Accept the row count and the hourly timestamps

- **Found:** The table has 50,401 rows and 50,401 distinct values of utc_timestamp. The first hour is 2014-12-31T23:00:00Z and the last is 2020-09-30T23:00:00Z. The number of hours from the first to the last, counting both, is 50,401.
- **Decided:** No rows are removed. utc_timestamp is the time key for every check.
- **Why:** The number of distinct hours equals the number of hours in the period, so no hour is missing and no hour is repeated.
- **Limit:** The check covers the timestamp column only. It does not show that the readings in each hour are correct. The data ends on 30 September 2020, so 2020 holds nine months, and the spring of 2020 includes the period of reduced electricity demand during the COVID-19 pandemic.

Table 1.2: Time coverage

| Measure | Value |
| --- | --- |
| First hour (UTC) | 2014-12-31T23:00:00Z |
| Last hour (UTC) | 2020-09-30T23:00:00Z |
| Hours from first to last, both included | 50,401 |
| Rows | 50,401 |
| Distinct hours | 50,401 |

### Decision 4: A blank cell is a NULL value

- **Found:** In the Austrian actual load column, 1 cell is NULL, 0 cells are empty text and 50,400 cells hold a value. Across all 298 measure columns, no empty-text cell was found.
- **Decided:** Blanks are counted with IS NULL. No rule for empty text is needed.
- **Why:** One form of blank means one counting rule, and a count that handled only the other form would understate the gaps.
- **Limit:** A blank means that no value is stored. The data does not say why a value is missing.

Table 1.3: How blanks are stored

| Check | NULL cells | Empty text cells | Filled cells | Total |
| --- | --- | --- | --- | --- |
| Austria actual load (one column) | 1 | 0 | 50,400 | 50,401 |
| Empty text cells across all 298 measure columns | | 0 | | |

## Part 2: Profiling the measures

In this log, a measure means one column of readings: a country or area code together with a type of reading. The file has 298 measures and two timestamp columns.

### Decision 5: Keep every measure and report its coverage

- **Found:** 205 of the 298 measures have a value in at least 50,000 of the 50,401 hours. The other 93 start late, stop early or have gaps, and none is empty (Table 2.1).
- **Decided:** No measure is dropped. Any question that uses a measure reports how many hours it covers.
- **Why:** A country or measure that covers a third of the period cannot be compared with one that covers all of it without saying so.
- **Limit:** The profile counts filled hours. It does not show where the gaps fall: at the start, at the end or in the middle.

Table 2.1: Completeness of the 298 measures

| Completeness class | Measures | Share of the 298 |
| --- | --- | --- |
| Filled 50,000 hours or more | 205 | 68.8% |
| Filled 40,000 to 49,999 hours | 57 | 19.1% |
| Filled 20,000 to 39,999 hours | 19 | 6.4% |
| Filled 1 to 19,999 hours | 17 | 5.7% |
| Never filled | 0 | 0.0% |
| Total | 298 | 100.0% |

### Decision 6: Use the load, solar, wind and price measures for whole-period questions, and treat capacity and profile measures as partial

- **Found:** The 298 measures fall into 15 measure types (Table 2.2). Actual load has the most countries (32) and the most near-complete columns (49 of 57). Price day ahead covers 8 countries. None of the capacity or profile measures has more than 43,801 filled hours.
- **Decided:** Questions about the whole period use load, generation and price measures. Capacity and profile measures are not used for whole-period comparisons, and any use reports their coverage. Price questions are limited to the 8 countries that have price columns.
- **Why:** The capacity and profile measures cover about five of the six years at most, so they cannot support a comparison over the full period.
- **Limit:** Several types have more columns than countries, so some countries have more than one column of a type (Decision 7). The measure types wind_generation_actual and wind_offshore_generation_actual have identical counts, and I have not checked whether they hold the same values.

Table 2.2: The 15 measure types

| Measure type | Columns | Countries | Columns filled 50,000 hours or more | Fewest filled hours | Most filled hours |
| --- | --- | --- | --- | --- | --- |
| wind_onshore_generation_actual | 58 | 29 | 44 | 22 | 50,400 |
| load_actual_entsoe_transparency | 57 | 32 | 49 | 17,524 | 50,400 |
| load_forecast_entsoe_transparency | 57 | 32 | 45 | 16,656 | 50,400 |
| solar_generation_actual | 39 | 22 | 30 | 10 | 50,393 |
| price_day_ahead | 32 | 8 | 21 | 17,515 | 50,386 |
| wind_offshore_generation_actual | 12 | 6 | 8 | 2,892 | 50,400 |
| wind_generation_actual | 12 | 6 | 8 | 2,892 | 50,400 |
| wind_onshore_capacity | 7 | 5 | 0 | 43,799 | 43,801 |
| solar_capacity | 6 | 4 | 0 | 40,297 | 43,801 |
| wind_capacity | 5 | 4 | 0 | 43,799 | 43,801 |
| wind_offshore_capacity | 5 | 4 | 0 | 43,799 | 43,801 |
| solar_profile | 2 | 2 | 0 | 43,696 | 43,752 |
| wind_profile | 2 | 2 | 0 | 43,725 | 43,760 |
| wind_onshore_profile | 2 | 2 | 0 | 43,727 | 43,760 |
| wind_offshore_profile | 2 | 2 | 0 | 43,725 | 43,760 |
| Total | 298 | | 205 | | |

## Part 3: One value for each country

### Decision 7: Use the plain two-letter code as the country total

- **Found:** The actual load measure has 57 columns for 32 countries. 31 countries have a plain two-letter code, and 26 columns are sub-areas: Germany (DE_50hertz, DE_LU, DE_amprion, DE_tennet, DE_transnetbw), Denmark (DK_1, DK_2), Ireland (IE_sem), Italy (six zones), Norway (NO_1 to NO_5) and Sweden (SE_1 to SE_4). Great Britain has no plain code, only GB_GBN, GB_NIR and GB_UKM. The price measure has 32 columns for 8 countries, and only Austria has a plain code. In the hours where every column is filled, each plain code matches the sum of its sub-areas to within a few megawatts on average (Table 3.1).
- **Decided:** For country comparisons, use the plain two-letter code, and GB_UKM for Great Britain, which gives 32 countries. Sub-areas are not added to the country totals, and are used only for questions about zones. DE_LU is a zone that combines Germany and Luxembourg, so it is not used as a country.
- **Why:** The plain code already contains its sub-areas, so adding them would count the same electricity twice.
- **Limit:** The largest single-hour gaps are much bigger than the average gaps (for example 11,908 MW for Sweden). I did not examine how many hours these are, or whether the error is in the total or in a sub-area. DE_LU has 16,887 hours in which all its columns are filled, against about 50,400 for the others. I did not test Ireland, where IE_sem may cover a different area from IE.

Table 3.1: Plain country code compared with the sum of its sub-areas (actual load, hours where every column is filled)

| Comparison | Hours all filled | Mean gap (MW) | Mean plain value (MW) | Mean gap as a share of the plain value | Largest gap (MW) |
| --- | --- | --- | --- | --- | --- |
| DE vs its four control areas | 50,400 | 0.6 | 55,492.5 | 0.001% | 3,179.0 |
| DE_LU vs DE plus LU | 16,887 | 10.1 | 55,334.1 | 0.02% | 871.0 |
| DK vs DK_1 plus DK_2 | 50,398 | 0.1 | 3,766.0 | 0.003% | 1,714.1 |
| NO vs NO_1 to NO_5 | 50,214 | 0.5 | 15,066.1 | 0.003% | 6,465.0 |
| SE vs SE_1 to SE_4 | 50,303 | 1.5 | 15,519.7 | 0.01% | 11,908.0 |
| IT vs its six zones | 50,398 | 0.7 | 32,888.7 | 0.002% | 909.0 |
| GB_UKM vs GB_GBN plus GB_NIR | 50,176 | 1.4 | 35,835.7 | 0.004% | 1,995.0 |

## Open items

- Read the current ENTSO-E terms and the licence of the primary data before publishing.
- Count the hours in which a sub-area total and the plain code differ by a large amount, and decide whether they need to be excluded.
- Compare wind_generation_actual with wind_offshore_generation_actual.
- Type the timestamps and readings in a clean layer, and reshape the table to one row for each hour and measure.
