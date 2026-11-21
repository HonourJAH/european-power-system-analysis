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

## Part 4: Business questions and rules

### Decision 8: Fix the five business questions and the rules before looking at any result

- **Found:** The profiling showed which measures cover the whole period, that each country has one total column, and that prices exist for 8 countries only (Decisions 5 to 7).
- **Decided:** The five questions in Table 4.1 are answered one at a time, and the rules below apply to all of them. They were fixed before any result was looked at.
- **Why:** Fixing the questions and the rules first means the choices cannot be made to fit a pattern in the results.
- **Limit:** The rules are choices, and different rules could give different results. Three things were not known when they were fixed: which countries pass the coverage rule, whether the solar and wind generation figures include small installations, and whether price zones line up with load zones for every country.

Table 4.1: The five business questions

| No. | Business question | Measures used |
| --- | --- | --- |
| 1 | How much electricity does each country use, and how did demand change from year to year, including 2020? | Actual load |
| 2 | At what hours and on which days is demand highest, and does the daily shape change between winter and summer and between years? | Actual load, local time |
| 3 | How much of demand is met by wind and solar generation, and how does the share change by year, season and country? | Actual load, solar and wind generation |
| 4 | Where day-ahead prices exist, do prices rise with demand and fall when wind and solar output is high, and does this hold in each year? | Price, load, generation |
| 5 | How accurate is the day-ahead load forecast, which countries have the largest errors, and does the error change by hour, season and year? | Load forecast, actual load |

Rules for all questions:

1. Country totals use the plain two-letter code, and GB_UKM for Great Britain (Decision 7). Sub-areas are used only where a question needs zones.
2. Years are calendar years in UTC. The first hour (2014-12-31T23:00:00Z) falls in 2014 and is left out of yearly groups. 2015 to 2019 are full years. 2020 holds January to September, so it is compared only with January to September of the earlier years.
3. The spring of 2020, when demand fell during the COVID-19 pandemic, is reported separately and is not blended into any statement about a trend.
4. A country enters a year-by-year comparison only if its measure has readings in at least 90% of that year's hours. A whole-period figure needs at least 50,000 filled hours. Countries that fail are listed in the findings.
5. Where hours are missing, figures are mean MW per hour and not totals, so a country with gaps is not understated. Every figure carries the number of hours behind it.
6. Question 2 uses local Central European time and only countries on that clock. Every other question uses UTC.
7. In question 3, the wind measure for each country is chosen when the data is seen, because wind_generation_actual may repeat the onshore and offshore columns. The choice and the reason are recorded here.
8. In question 4, a zone is used only if its price, load and generation measures each have at least 40,000 filled hours under the same zone code.
9. In question 5, the forecast error is the absolute difference between forecast and actual, divided by actual. The mean, median and 90th percentile are reported, with the share of hours with an error above 5%.
10. The findings describe associations and make no causal claims. Each question is tested within years and within countries before it is final.

## Part 5: The typed long table

### Decision 9: Build a typed long table with one row for each hour and measure

- **Found:** The raw table has one row for each hour and 298 measure columns, all stored as text, and the country is part of each column name. A query cannot group by country while the country is inside a column name.
- **Decided:** A second table, time_series_hourly_long, was built from the raw table with a SQL script (sql/05_build_long_table.sql). It has one row for each hour and measure, with the columns utc_timestamp (a timestamp), area_code, measure_type, measure_name and reading (a number). The area code and measure type are taken from the column name. Blank cells are dropped, so the table holds only filled readings. The table is clustered by measure_type and area_code. The raw table is not changed.
- **Why:** The long layout allows grouping by country, by measure type and by year in a single query. Typing the timestamps and readings here, and not in the raw layer, keeps the raw table as loaded. Dropping blanks is safe because blanks were confirmed to be NULL values only (Decision 4).
- **Limit:** The long table is much larger than the wide one when counted in logical bytes, because every row repeats the text labels (Table 5.2). Queries must select only the columns they need and filter on measure_type and area_code, and the estimate shown before each run is read every time. The table expires on 17 January 2027, so the script in the sql folder is the lasting record.

Table 5.1: The long table checked against the raw table (sql/06_validate_long_table.sql)

| Check | Expected | Result | Difference |
| --- | --- | --- | --- |
| Filled cells in the raw table compared with rows in the long table | 13,686,403 | 13,686,403 | 0 |
| Readings that failed to convert to a number | 0 | 0 | 0 |
| Timestamps that failed to convert | 0 | 0 | 0 |
| Rows missing an area code or measure type | 0 | 0 | 0 |
| Distinct measures | 298 | 298 | 0 |
| First hour (UTC) | 2014-12-31 23:00:00 | 2014-12-31 23:00:00 | |
| Last hour (UTC) | 2020-09-30 23:00:00 | 2020-09-30 23:00:00 | |

Table 5.2: Size of the long table and of the grid it came from

| Measure | Value |
| --- | --- |
| Rows in the long table | 13,686,403 |
| Cells in a full grid (298 measures by 50,401 hours) | 15,019,498 |
| Blank cells dropped | 1,333,095 |
| Share of the full grid that holds a reading | 91.1% |
| Logical size of the long table (the basis for on-demand cost) | 1.09 GB |
| Stored (physical) size of the long table | 73.19 MB |
| Logical size of the raw table, for comparison | 136.12 MB |

### Decision 10: Use the file's local time column for questions about the hour of the day

- **Found:** The file holds a local time column (cet_cest_timestamp) written with an offset from UTC. The offset is written without a colon (for example +0100), and the column is stored as text. As a check, the local time was derived from the UTC time with the Europe/Berlin time zone, and compared with the first 19 characters of the file's local time (sql/07_check_local_time.sql). All 50,401 hours match (Table 5.3).
- **Decided:** Questions about the hour of the day and the day of the week (business question 2) use the local time derived from UTC with the Europe/Berlin time zone. All other questions use UTC.
- **Why:** The hour of the day means the same clock only for countries in the same time zone, and the derived local time handles the change between winter and summer time.
- **Limit:** The check compares the date and time of day and does not test the offset part of the text. Countries outside Central European Time are not compared by local hour of the day.

Table 5.3: Local time check

| Check | Hours | Mismatches |
| --- | --- | --- |
| Local time derived from UTC compared with the file's local time | 50,401 | 0 |

## Part 6: Coverage and extreme load hours

### Decision 11: Apply the coverage rule to the 32 country load totals

- **Found:** The query sql/08_check_country_load_coverage.sql compared each country's filled actual-load hours with the hours in each calendar year from 2015 to 2020 (the 2014 hour is left out, rule 2). 26 countries have at least 50,000 filled hours and at least 90% coverage in all six years. Four countries have at least 90% coverage in every year but fall 163 to 383 hours short of 50,000 hours. Two countries have no readings in the first years (Table 6.1).
- **Decided:** Rule 4 from Decision 8 is applied as it was written. The 26 countries enter the whole-period figures and every year-by-year comparison. The four near-misses enter every year-by-year comparison and are left out of whole-period figures. Ukraine enters comparisons for 2018 to 2020, and Cyprus for 2017 and 2018.
- **Why:** The rule was fixed before any result was looked at. Changing it because four countries narrowly miss it would fit the rule to the data.
- **Limit:** I do not know why the gaps occur. Serbia's 2015 coverage (91.2%) is just above the 90% line.

Table 6.1: Countries by coverage of actual load, 2015 to 2020

| Group | Countries | Filled hours | Share of the 50,400 hours |
| --- | --- | --- | --- |
| Meets the whole-period rule and the yearly rule | 26 (AT, BE, BG, CH, CZ, DE, DK, EE, ES, FI, FR, GB_UKM, GR, HR, HU, IT, LT, LV, NL, NO, PL, PT, RO, SE, SI, SK) | 50,207 to 50,400 | 99.6% to 100.0% |
| Yearly rule only | IE | 49,837 | 98.9% |
| Yearly rule only | LU | 49,738 | 98.7% |
| Yearly rule only | ME | 49,662 | 98.5% |
| Yearly rule only | RS | 49,617 | 98.4% |
| Some years only | UA | 25,635 | 50.9% |
| Some years only | CY | 32,931 | 65.3% |

### Decision 12: Screen the load data for extreme hours

- **Found:** The mean load for each of the 26 countries (sql/09) has a lowest or highest hour that is far from the country's typical level. Slovakia has an hour of 2,170,811 MW against a mean of 3,336.8 MW, France has a peak of 158,000 MW against a mean of 53,249.7 MW, and Austria, Great Britain and Slovenia have lowest hours of 664 MW, 1,183 MW and 24.2 MW against means of 7,070.1 MW, 35,834.9 MW and 1,462.7 MW.
- **Decided:** An hour is flagged when the load is above twice, or below a quarter of, the country's median load (sql/10). Flagged hours less than 13 hours apart are grouped into one episode (sql/12). The 26 qualifying countries have 111 flagged hours (Table 6.2). All 32 countries have 189 flagged hours in 67 episodes (Table 6.3).
- **Why:** The screen finds hours that are far outside a country's normal range, so they can be examined before any hour-level statistic is computed. The effect on the whole-period means is small: the largest change is 48.4 MW for Slovakia (1.5% of its mean), and every other country changes by less than 17 MW.
- **Limit:** The twice-the-median, quarter-of-the-median and 12-hour limits were chosen after the extreme hours had been seen, so they were not fixed in advance. They are a screen for errors and do not prove that an hour is wrong. The median is approximate. The screen cuts some episodes short: the hour before Austria's third episode reads 1,840 MW (26% of the median) and was not flagged. Most flagged hours are in multi-hour episodes (Table 6.3), which suggests stretches of bad data in the source. I did not find the cause of any episode.

Table 6.2: Flagged hours in the 26 qualifying countries

| Country | Flagged hours | Above twice the median | Below a quarter of the median | Change in the mean when the flagged hours are left out (MW) |
| --- | --- | --- | --- | --- |
| CH | 36 | 27 | 9 | 3.7 |
| GB_UKM | 26 | 0 | 26 | -16.8 |
| AT | 25 | 0 | 25 | -2.9 |
| SK | 12 | 12 | 0 | 48.4 |
| NO | 5 | 5 | 0 | 1.6 |
| DK | 4 | 4 | 0 | 0.4 |
| EE | 1 | 0 | 1 | 0.0 |
| FR | 1 | 1 | 0 | 2.1 |
| SI | 1 | 0 | 1 | -0.0 |
| Other 17 countries | 0 | 0 | 0 | 0.0 |
| Total | 111 | 49 | 62 | |

Table 6.3: Episodes of flagged hours in all 32 country totals

| Country | Episodes | Flagged hours | Hours from the first to the last flagged hour of each episode |
| --- | --- | --- | --- |
| LU | 34 | 69 | 75 |
| GB_UKM | 9 | 26 | 26 |
| ME | 6 | 7 | 8 |
| DK | 4 | 4 | 4 |
| AT | 3 | 25 | 25 |
| SK | 3 | 12 | 15 |
| CH | 2 | 36 | 45 |
| NO | 2 | 5 | 5 |
| CY | 1 | 2 | 2 |
| EE | 1 | 1 | 1 |
| FR | 1 | 1 | 1 |
| SI | 1 | 1 | 1 |
| Total | 67 | 189 | 208 |

### Decision 13: Flag the suspect hours and leave them out of the analysis

- **Found:** In the 26 qualifying countries, 99 of the 111 flagged hours (89.2%) are in multi-hour episodes. Nine hours inside Switzerland's episodes, three inside Slovakia's, and six and one inside Luxembourg's and Montenegro's, lie between the first and last flagged hour of an episode without being flagged themselves (Table 6.4).
- **Decided:** A table, suspect_load_hours, holds every load hour from the first to the last flagged hour of each episode, with a column that shows whether the screen flagged the hour itself (sql/13). The raw table and the long table are not changed. Business questions 1 to 5 leave these hours out of their calculations, and each reports how many hours were left out.
- **Why:** Flagging and not deleting keeps the source data intact, as in the raw, flagged and clean layers of the first project. Leaving the hours out matters most for statistics that depend on single hours, such as peaks, daily shapes and forecast errors.
- **Limit:** The exclusion is a minimum. Bad hours just outside an episode, such as Austria's 1,840 MW hour, stay in the data, and so do any bad hours that the screen did not catch. The table expires 60 days after it was created, so sql/13 is the lasting record.

Table 6.4: The suspect hours table

| Measure | Value |
| --- | --- |
| Suspect hours | 208 |
| Flagged by the screen | 189 |
| Inside an episode and not flagged | 19 |
| Episodes | 67 |
| Countries | 12 |

## Part 7: Business question 1

### Decision 14: Answer business question 1 with yearly means for January to September

- **Found:** The query sql/analysis/q01_electricity_demand_by_country_and_year.sql gives each country's mean load for each year. Three series show a one-year step that is not matched by their neighbours: the Netherlands rises 16.2% from 2015 to 2016, Great Britain falls 7.4% from 2016 to 2017, and Switzerland rises 7.6% from 2015 to 2016 (Table 1.3 in the findings).
- **Decided:** Every year is measured over January to September, so 2020 (which ends on 30 September) is compared with the same months of the earlier years. The 208 suspect hours from Decision 13 are left out, and 161 of them fall in these months (Table 7.1). A country-year is shown only if at least 90% of the hours in that window have a valid reading. Serbia in 2015, Cyprus in every year except 2017 and 2018, and Ukraine in 2015 to 2017 do not meet it. The question is answered at yearly level, as it was asked. A monthly check of the three steps was considered and not done.
- **Why:** The question asks about yearly figures, and a monthly view of three countries is beyond it. Reporting the steps as unexplained is more honest than guessing their cause.
- **Limit:** Rule 3 of Decision 8 says that the spring of 2020 is reported separately. That was not done, so the 2020 figures include the spring months, and no statement about a trend is made from them. Rule 10 says that each question is tested within years and within countries. The test was not run for the three steps, and their cause is not known. They may be a change in what the series measures and not a change in demand, and I did not confirm either.

Table 7.1: Suspect hours left out of the January to September window

| Country | Suspect hours left out |
| --- | --- |
| LU | 73 |
| CH | 45 |
| GB_UKM | 19 |
| SK | 7 |
| ME | 5 |
| NO | 4 |
| DK | 3 |
| CY | 2 |
| EE | 1 |
| FR | 1 |
| SI | 1 |
| Other 21 countries | 0 |
| Total | 161 |

## Part 8: Business question 2

### Decision 15: Add a table of country names

- **Found:** The area codes are two-letter codes that are hard to read in a result. Adding the name to the long table would repeat the text in every row of 13.7 million and raise its logical size, which is the basis for on-demand cost.
- **Decided:** A table of 32 rows, country_names, was built from sql/15_build_country_names_table.sql. It pairs each country total code with its name, and queries join it only in their last step. GB_UKM is named United Kingdom. The check in sql/16_check_country_names_table.sql found 32 names, 32 country totals in the data, and none without a name (Table 8.1).
- **Why:** Names make every result readable without changing the large table.
- **Limit:** The names were typed by hand. GB_UKM includes Northern Ireland, because in the hours where all three columns are filled it matches the sum of GB_GBN and GB_NIR (Table 3.1). The estimate for the check query was 108.89 MB, and I could not separate the share of the join.

Table 8.1: Check of the country names table

| Check | Expected | Result |
| --- | --- | --- |
| Names in the table | 32 | 32 |
| Country totals in the data | 32 | 32 |
| Country totals without a name | 0 | 0 |

### Decision 16: Fix the rules for business question 2 before looking at any result

- **Found:** Business question 2 asks about the hour of the day and the day of the week with the highest demand, and whether the daily shape changes between winter and summer and between years. The hour of the day means the same clock only for countries in one time zone (Decision 10).
- **Decided:** The question uses the 19 countries on Central European Time that meet the coverage rule in every year of the January to September window used in business question 1: AT, BE, CH, CZ, DE, DK, ES, FR, HR, HU, IT, LU, ME, NL, NO, PL, SE, SI and SK (Table 8.2). Local time is derived from UTC with the Europe/Berlin time zone. Suspect hours are left out. The overall hour and weekday patterns use 2015 to 2019. Seasons are winter (January and February) and summer (June to August) for 2015 to 2020, and spring (March to May) is reported separately for 2020 against the earlier years. The peak hour is the local hour with the highest mean load, the lowest hour is the one with the lowest mean, and the peak-to-lowest ratio is the mean at the peak hour divided by the mean at the lowest hour. Countries are not averaged together.
- **Why:** One clock makes the hour of the day comparable, five full years avoid giving any month more weight, and keeping the spring of 2020 apart follows rule 3 of Decision 8. These choices were made before any result was looked at.
- **Limit:** The time zones were assigned from general knowledge and not from the data. Serbia is left out because of its 2015 coverage. Public holidays are not removed, and the data has no information on them. Summer 2020 may still show effects of the pandemic. Dividing the year into seasons this way leaves out September to December.

Table 8.2: Countries by time zone

| Time zone | Countries | Used in business question 2 |
| --- | --- | --- |
| Central European Time | AT, BE, CH, CZ, DE, DK, ES, FR, HR, HU, IT, LU, ME, NL, NO, PL, RS, SE, SI, SK | 19 (all but RS) |
| Eastern European Time | BG, CY, EE, FI, GR, LT, LV, RO, UA | None |
| Western European or Greenwich Time | GB_UKM, IE, PT | None |

### Decision 17: Apply the coverage rule to the periods used in business question 2

- **Found:** The seasons and years in sql/analysis/q02_daily_shape_by_season_and_year.sql have 8,543 (winter), 13,248 (summer), 11,035 (spring 2015 to 2019) and 2,207 (spring 2020) local hours in a country with no gaps (Germany). Every country and period has at least 96.5% of those hours, except Montenegro in spring 2020, which has 1,703 of 2,207 hours (77.2%) (Table 8.3).
- **Decided:** Rule 4 of Decision 8 is applied to every period. Montenegro is left out of the spring 2020 comparison and shown as n/a. It stays in every other comparison.
- **Why:** A figure built from 77% of the hours of a period cannot be compared with figures built from nearly all of them.
- **Limit:** The same reading counts in a season and in a year, so the periods overlap. Winter is January and February only, and summer 2020 may still show effects of the pandemic. I do not know why Montenegro's spring 2020 has missing hours.

Table 8.3: Coverage of the periods used in business question 2

| Period | Hours in a country with no gaps | Lowest hours counted in any country | Country | Share of the full period |
| --- | --- | --- | --- | --- |
| Winter, 2015 to 2020 | 8,543 | 8,247 | LU | 96.5% |
| Summer, 2015 to 2020 | 13,248 | 13,090 | ME | 98.8% |
| Spring, 2015 to 2019 | 11,035 | 10,929 | LU | 99.0% |
| Spring, 2020 | 2,207 | 1,703 | ME | 77.2% |
