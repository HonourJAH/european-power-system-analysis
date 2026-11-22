# Data

This project uses the Open Power System Data time series package, version 2020-10-06. The primary data comes from the ENTSO-E Transparency Platform and the transmission system operators of each country. The terms of those sources apply.

The data is not stored in this repository.

Attribution: Open Power System Data. 2020. Data Package Time series. Version 2020-10-06. https://doi.org/10.25832/time_series/2020-10-06. (Primary data from various sources, for a complete list see URL).

## About the file used

| Measure | Value |
| --- | --- |
| File | time_series_60min_singleindex.csv |
| Rows (one per hour) | 50,401 |
| Columns | 300 (two timestamps and 298 measures) |
| First hour (UTC) | 2014-12-31T23:00:00Z |
| Last hour (UTC) | 2020-09-30T23:00:00Z |
| Countries | 32 |

## How to get the data and load it

1. Download the Time series data package from the Open Power System Data website and save time_series_60min_singleindex.csv in a new folder named data/raw in this project. Do not open and save it in Excel.
2. The file is over the 100 MB limit for uploading a local file in the BigQuery console, so split it into two parts. From the project folder, in Git Bash:

        mkdir -p data/raw/parts
        head -n 25201 data/raw/time_series_60min_singleindex.csv > data/raw/parts/part_1.csv
        tail -n +25202 data/raw/time_series_60min_singleindex.csv > data/raw/parts/part_2.csv

3. Build a schema that loads every column as text, so nothing converts silently:

        head -n 1 data/raw/time_series_60min_singleindex.csv | tr -d '\r' | tr ',' '\n' | awk 'BEGIN{printf "["} NR>1{printf ","} {printf "{\"name\":\"%s\",\"type\":\"STRING\",\"mode\":\"NULLABLE\"}", $0} END{print "]"}' > data/raw/parts/schema_all_string.json

4. In the BigQuery sandbox, create a dataset named power_system in the EU location.
5. Create a table named time_series_hourly_raw from part_1.csv, with the schema pasted in as text and one header row to skip.
6. Load part_2.csv into the same table with the write preference set to append and no header rows to skip.
7. Run the scripts in the sql folder in order, as described in the main README.

## Checks after loading

| Check | Expected |
| --- | --- |
| Rows in time_series_hourly_raw | 50,401 |
| Distinct hours | 50,401 |
| Columns, all stored as text | 300 |

## Using your own project

The scripts name the project bigquery-514705. To use your own, run this from the project folder:

        sed -i 's/bigquery-514705/YOUR_PROJECT_ID/g' sql/*.sql sql/analysis/*.sql

The BigQuery sandbox deletes tables after 60 days, so the scripts rebuild every table.
