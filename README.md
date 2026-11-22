# European Electricity Demand, Wind and Solar Analysis (BigQuery SQL)

A SQL analysis in Google BigQuery of hourly electricity load, wind and solar generation, day-ahead prices and load forecasts for 32 European countries, from 2015 to September 2020. The project loads the data unchanged, profiles and validates it, screens it for errors, documents every decision, and answers five business questions.

This is project 5 of my data analytics portfolio. The first four use MySQL, Python and Excel. This one is built to learn BigQuery: its cost model, loading, reshaping wide data, time zones and checking results at scale. My degree is in Electrical and Electronics Engineering, which is why I chose electricity data.

## The question

How much electricity do European countries use, when is demand highest, how much of it is met by wind and solar, how do prices relate to both, and how reliable is the day-ahead forecast? An energy company or a grid operator needs the answers to plan around demand, weather-driven generation and price.

| Measure | Value |
| --- | --- |
| Hourly readings, per measure | 50,401 hours (31 December 2014 to 30 September 2020) |
| Columns in the source file | 300 (two timestamps and 298 measures) |
| Countries | 32 |
| Rows in the reshaped table | 13,686,403 |

## The data

- **Source:** the Open Power System Data time series package, version 2020-10-06, compiled from the ENTSO-E Transparency Platform and the transmission system operators of each country. Attribution: Open Power System Data. 2020. Data Package Time series. Version 2020-10-06. https://doi.org/10.25832/time_series/2020-10-06. (Primary data from various sources, for a complete list see URL).
- **The terms of the primary sources apply.** I could not confirm the exact licence terms for this package. The data is not stored in this repository, and only the queries, the decision log and the findings are published.
- **The data ends on 30 September 2020,** so every yearly comparison uses January to September.
- **Many measures are incomplete.** 205 of the 298 measures have a value in at least 50,000 of the 50,401 hours, and the other 93 start late, stop early or have gaps.
- **Spring 2020 includes the COVID-19 pandemic,** when demand fell. Figures for 2020 are not read as a trend.

## How the project is built

| Step | What it does | Scripts |
| --- | --- | --- |
| Load | Loads the file unchanged, in two parts, with every column as text | data/README.md |
| Profile | Counts rows, blanks, hours and measure types, and how complete each measure is | sql/01 to sql/03 |
| Reconcile | Tests whether each country total equals the sum of its sub-areas | sql/04 |
| Reshape and validate | Builds a typed table with one row for each hour and measure, and checks it against the raw table | sql/05 to sql/07 |
| Screen | Finds hours with load far outside a country's normal range, groups them into episodes and flags them | sql/08 to sql/14 |
| Names | Adds a table of country names | sql/15 and sql/16 |
| Coverage | Checks which countries have generation, price and forecast data | sql/17 to sql/21 |
| Analyse | Answers the five business questions | sql/analysis |

Quality checks:

| Check | Result |
| --- | --- |
| Filled cells in the raw table compared with rows in the reshaped table | 13,686,403 and 13,686,403 |
| Readings or timestamps that failed to convert | 0 |
| Local time derived from UTC compared with the file's local time | 0 mismatches in 50,401 hours |
| Total wind compared with onshore plus offshore wind, mean gap | 0.0 to 0.3 MW in 12 areas |
| Country load total compared with the sum of its sub-areas, mean gap as a share of the total | 0.02% or less in 7 comparisons |
| Hours flagged as suspect | 208 in 67 episodes, left out and kept in a separate table |

The decision log (docs/decision-log.md) holds 25 decisions, each with what was found, what was decided, why, and the limit of the decision.

## Business questions and main results

Each question has a full write-up with tables, interpretation and limitations in docs/findings.md. The table numbers below refer to it.

| No. | Business question | Main result |
| --- | --- | --- |
| 1 | How much electricity does each country use, and how did demand change from year to year, including 2020? | Mean load in January to September 2019 ranged from 391.5 MW in Montenegro to 55,786.3 MW in Germany. From 2019 to 2020 it fell in 27 of the 31 countries with both years, by 2.2% to 10.2%. Tables 1.1 and 1.2. |
| 2 | At what hours and on which days is demand highest, and does the daily shape change between winter and summer and between years? | In 19 countries on Central European Time, demand peaked at midday in 12 and in the evening in 7, and Sunday was the quietest day in 18. The winter peak was in the evening in 17 countries, and the summer peak at midday in 17. Tables 2.1, 2.2 and 2.5. |
| 3 | How much of demand is met by wind and solar generation, and how does the share change by year, season and country? | Over 2015 to 2020, wind and solar met 46.0% of demand in Denmark, 29.1% in Germany, 25.2% in Spain and 2.2% in Slovenia. The share in spring 2020 was higher than in earlier springs in all 15 countries with both, partly because demand fell. Tables 3.1, 3.4 and 3.5. |
| 4 | Where day-ahead prices exist, do prices rise with demand and fall when wind and solar output is high? | In the nine zones with enough data (three countries), prices tended to rise with demand in all 54 zone-years, and the adjusted correlation with wind and solar output was negative, at -0.06 or lower, in 52 of the 54. Tables 4.1 to 4.4. |
| 5 | How accurate is the day-ahead load forecast, and which countries have the largest errors? | Across 22 countries, the typical forecast error ranged from 0.00% in Norway to 9.54% in the Netherlands, and was below 2% in 12 countries. The Netherlands and Switzerland had the largest errors. Tables 5.1 and 5.5. |

What this means for an energy company or a grid operator: demand follows a regular rhythm that differs by country, wind and solar already meet a large share of demand in a few countries, prices fall when they produce a lot, and the day-ahead forecast is close in most countries and unreliable in a few. The findings also say where the data cannot answer: the size of the price effect, why a country's forecast is accurate, and what happened in the three series with unexplained one-year steps.

## What I learned about BigQuery

- **Cost is set by the data a query reads.** Naming three columns instead of all of them cut a query's estimate from 314.01 MB to 84.97 MB, a fall of 72.9%. The reshaped table holds 1.09 GB by BigQuery's count and 73.19 MB when stored, so every query selects only the columns it needs and filters on the columns the table is clustered by.
- **Loading is its own skill.** The file was over the console's 100 MB limit, so it was split in two and loaded as text, and the load was checked against the file.
- **Wide data needs reshaping.** The country is part of each column name, so the 298 measure columns were reshaped into rows with UNPIVOT before anything could be grouped by country.
- **Time zones and windows need care.** Local hours were derived with a time zone, calendar years were compared over the same months, and 2020 was kept apart from earlier springs.
- **Check every result.** A one-line summary of a column showed a single reading of 2,170,811 MW in Slovakia, and a coverage table showed that a plain country code is the total of its sub-areas, so adding them would have counted the same electricity twice.
- **Say what was decided after seeing the data.** The screening limits and the choice to rank forecast errors by the median were made after the extreme values were seen, and the log says so.

## Repository structure

    european-power-system-analysis/
    ├── data/
    │   └── README.md
    ├── docs/
    │   ├── decision-log.md
    │   └── findings.md
    ├── sql/
    │   ├── 01_profile_measure_columns_detail.sql
    │   ├── ... (setup, profiling, screening and coverage scripts, 01 to 21)
    │   └── analysis/
    │       ├── q01_electricity_demand_by_country_and_year.sql
    │       ├── q02_peak_hour_and_weekday_by_country.sql
    │       ├── q02_daily_shape_by_season_and_year.sql
    │       ├── q03_wind_and_solar_share_of_demand.sql
    │       ├── q04_price_relationship_with_load_and_generation.sql
    │       ├── q05_forecast_error_by_country_and_period.sql
    │       └── q05_forecast_error_by_hour_of_day.sql
    ├── .gitignore
    └── README.md

## Skills shown

- **BigQuery SQL:** loading, UNPIVOT, CREATE TABLE AS with clustering, temporary functions, window functions, time zones, CORR and APPROX_QUANTILES.
- **Data quality:** profiling, reconciliation of totals to their parts, screening for extreme values, and validation of every table I built.
- **Cost awareness:** reading the estimate before each run and designing queries to read less.
- **Documentation:** a decision log and plain-English findings with every figure traceable to a table.

## Limitations

- The results are associations. The data does not show why demand, generation, prices or forecast errors differ.
- The data ends on 30 September 2020, and 2020 includes the pandemic.
- Price results cover three countries, and the nine zones are three markets. The size of the price effect was not measured.
- Three series (the Netherlands, the United Kingdom and Switzerland) show one-year steps in load that I could not explain, and Norway's forecast error is close to zero for reasons I did not test.
- I could not confirm the licence terms of the primary data, and I read the ENTSO-E terms of use only through the Open Power System Data package.
- The BigQuery sandbox deletes tables after 60 days, so the scripts are the lasting record. To rebuild the tables, follow data/README.md.

## About me

Michael Onojah, Electrical and Electronics Engineering graduate (Federal University of Technology Akure, 2025), moving into entry-level data analytics.
- Skills: SQL, Excel, Power BI and Python.

- GitHub: [HonourJAH](https://github.com/HonourJAH)
- LinkedIn: [LinkedIn](linkedin.com/in/friday-onojah-9a5698219)
