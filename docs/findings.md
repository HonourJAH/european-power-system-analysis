# Findings

This report answers five business questions about European electricity data, one at a time. The data is the Open Power System Data time series package (version 2020-10-06), compiled from the ENTSO-E Transparency Platform and the transmission system operators of each country. It holds hourly readings from 2014-12-31 23:00 UTC to 2020-09-30 23:00 UTC for 32 countries. The analysis is done in Google BigQuery, and every query is in the sql folder.

Attribution: Open Power System Data. 2020. Data Package Time series. Version 2020-10-06. https://doi.org/10.25832/time_series/2020-10-06. (Primary data from various sources, for a complete list see URL).

How to read the tables:

- Load means the electricity demand of a country in an hour, in megawatts (MW). A mean load is the average of the hourly readings, so a country with missing hours is not understated.
- A country is shown for a year only if at least 90% of the hours in the January to September window of that year have a valid reading. Other cells show "n/a".
- A difference between countries or years is an association. The data does not show why demand changed.
- Every figure in the text appears in a numbered table in the same section.

## Business question 1: How much electricity does each country use, and how did demand change from year to year, including 2020?

### Findings

Every year is measured over January to September, because the data ends on 30 September 2020. Hours that look like errors are left out (Decision 13). Table 1.1 gives the mean load for each country and year, in MW.

Table 1.1: Mean load by country and year, January to September (MW)

| Country | 2015 | 2016 | 2017 | 2018 | 2019 | 2020 | Change 2019 against 2015 | Change 2020 against 2019 | Years shown |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AT | 6,646.9 | 6,989.3 | 7,127.1 | 7,154.7 | 7,113.1 | 6,708.3 | +7.0% | -5.7% | 6 |
| BE | 10,036.4 | 9,744.3 | 9,849.3 | 9,934.3 | 9,611.1 | 9,076.5 | -4.2% | -5.6% | 6 |
| BG | 4,254.6 | 4,114.6 | 4,367.9 | 4,221.3 | 4,252.2 | 4,072.2 | -0.1% | -4.2% | 6 |
| CH | 6,274.4 | 6,748.5 | 6,663.6 | 6,653.4 | 6,501.2 | 6,833.8 | +3.6% | +5.1% | 6 |
| CY | n/a | n/a | 534.0 | 525.1 | n/a | n/a | n/a | n/a | 2 |
| CZ | 7,164.8 | 7,246.1 | 7,453.9 | 7,525.6 | 7,481.6 | 7,134.3 | +4.4% | -4.6% | 6 |
| DE | 54,213.3 | 54,771.6 | 55,674.2 | 56,575.3 | 55,786.3 | 53,047.9 | +2.9% | -4.9% | 6 |
| DK | 3,712.3 | 3,639.8 | 3,613.4 | 3,789.9 | 3,753.7 | 3,814.3 | +1.1% | +1.6% | 6 |
| EE | 882.1 | 901.2 | 921.8 | 941.3 | 917.1 | 878.9 | +4.0% | -4.2% | 6 |
| ES | 28,671.6 | 28,664.8 | 28,898.7 | 29,295.6 | 28,722.9 | 26,943.8 | +0.2% | -6.2% | 6 |
| FI | 9,088.4 | 9,295.9 | 9,340.1 | 9,577.5 | 9,382.4 | 8,701.9 | +3.2% | -7.3% | 6 |
| FR | 52,944.1 | 52,529.4 | 52,783.0 | 52,628.3 | 52,257.2 | 48,640.8 | -1.3% | -6.9% | 6 |
| GB_UKM | 37,768.2 | 37,891.9 | 35,093.9 | 35,489.5 | 34,324.6 | 31,750.2 | -9.1% | -7.5% | 6 |
| GR | 5,915.9 | 5,786.8 | 5,948.9 | 5,892.7 | 6,073.6 | 5,662.3 | +2.7% | -6.8% | 6 |
| HR | 1,940.6 | 1,900.3 | 2,034.5 | 2,085.0 | 2,063.1 | 1,900.5 | +6.3% | -7.9% | 6 |
| HU | 4,714.5 | 4,704.7 | 4,872.6 | 4,917.5 | 4,946.2 | 4,769.4 | +4.9% | -3.6% | 6 |
| IE | 2,992.1 | 3,044.2 | 3,105.3 | 3,254.0 | 3,260.5 | 3,265.2 | +9.0% | +0.1% | 6 |
| IT | 33,188.5 | 32,154.0 | 33,262.6 | 34,099.0 | 34,086.2 | 30,861.6 | +2.7% | -9.5% | 6 |
| LT | 1,180.2 | 1,243.4 | 1,310.2 | 1,362.7 | 1,374.2 | 1,317.4 | +16.4% | -4.1% | 6 |
| LU | 480.9 | 485.0 | 489.5 | 467.3 | 458.0 | 411.5 | -4.8% | -10.2% | 6 |
| LV | 793.2 | 803.8 | 807.8 | 825.5 | 816.5 | 789.2 | +2.9% | -3.3% | 6 |
| ME | 390.6 | 362.0 | 384.2 | 386.5 | 391.5 | 366.9 | +0.2% | -6.3% | 6 |
| NL | 10,993.7 | 12,776.6 | 12,770.1 | 12,905.8 | 12,814.9 | 12,126.1 | +16.6% | -5.4% | 6 |
| NO | 14,283.2 | 14,542.9 | 14,550.5 | 14,984.5 | 14,517.4 | 14,639.7 | +1.6% | +0.8% | 6 |
| PL | 18,212.9 | 18,396.2 | 18,957.9 | 19,341.6 | 19,148.6 | 18,372.3 | +5.1% | -4.1% | 6 |
| PT | 5,619.9 | 5,616.9 | 5,649.4 | 5,820.8 | 5,699.8 | 5,478.8 | +1.4% | -3.9% | 6 |
| RO | 6,512.0 | 6,487.2 | 6,758.7 | 6,863.9 | 6,824.9 | 6,457.5 | +4.8% | -5.4% | 6 |
| RS | n/a | 4,225.2 | 4,419.3 | 4,332.9 | 4,409.9 | 4,312.0 | n/a | -2.2% | 5 |
| SE | 15,016.6 | 15,230.5 | 15,354.2 | 15,355.0 | 15,117.8 | 14,709.6 | +0.7% | -2.7% | 6 |
| SI | 1,390.4 | 1,427.5 | 1,485.5 | 1,519.8 | 1,499.4 | 1,375.2 | +7.8% | -8.3% | 6 |
| SK | 3,180.5 | 3,211.5 | 3,343.0 | 3,338.8 | 3,296.4 | 3,116.1 | +3.6% | -5.5% | 6 |
| UA | n/a | n/a | n/a | 17,110.6 | 17,005.8 | 15,495.5 | n/a | -8.9% | 3 |

Table 1.2: Change in mean load from January to September 2019 to January to September 2020

| Group | Countries |
| --- | --- |
| Countries with a figure for both years | 31 |
| Countries where 2020 was lower | 27 |
| Countries where 2020 was higher | 4 (CH +5.1%, DK +1.6%, NO +0.8%, IE +0.1%) |
| Largest falls | LU -10.2%, IT -9.5%, UA -8.9%, SI -8.3%, HR -7.9% |
| Smallest falls | RS -2.2%, SE -2.7%, LV -3.3%, HU -3.6% |

Table 1.3: Three series with a one-year step

| Country | Years | Mean before (MW) | Mean after (MW) | Change | Mean in the following years (MW) |
| --- | --- | --- | --- | --- | --- |
| NL | 2015 to 2016 | 10,993.7 | 12,776.6 | +16.2% | 12,770.1 (2017), 12,905.8 (2018), 12,814.9 (2019) |
| GB_UKM | 2016 to 2017 | 37,891.9 | 35,093.9 | -7.4% | 35,489.5 (2018), 34,324.6 (2019) |
| CH | 2015 to 2016 | 6,274.4 | 6,748.5 | +7.6% | 6,663.6 (2017), 6,653.4 (2018), 6,501.2 (2019) |

Table 1.4: Suspect hours left out of the January to September window

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

- In 2019, the five countries with the highest mean load were Germany (55,786.3 MW), France (52,257.2 MW), United Kingdom (34,324.6 MW), Italy (34,086.2 MW) and Spain (28,722.9 MW). The lowest among countries with a 2019 figure were Montenegro (391.5 MW), Luxembourg (458.0 MW) and Latvia (816.5 MW) (Table 1.1).
- From 2015 to 2019, mean load rose in 24 of the 29 countries with both figures, by up to 16.6% in the Netherlands and 16.4% in Lithuania. It fell in United Kingdom (-9.1%), Luxembourg (-4.8%), Belgium (-4.2%), France (-1.3%) and Bulgaria (-0.1%). Demand did not move in one direction across Europe (Table 1.1).
- From January to September 2019 to the same months of 2020, mean load fell in 27 of the 31 countries with both figures, by between 2.2% and 10.2%. It rose in Switzerland (+5.1%), Denmark (+1.6%), Norway (+0.8%) and Ireland (+0.1%) (Tables 1.1 and 1.2).
- Three series show a one-year step that their neighbours do not show: the Netherlands rose 16.2% from 2015 to 2016 and then stayed near 12,800 MW, the United Kingdom fell 7.4% from 2016 to 2017 and then stayed lower, and Switzerland rose 7.6% from 2015 to 2016 and then drifted back (Table 1.3). In the Netherlands (+16.6%) and the United Kingdom (-9.1%) the step accounts for most of the 2015 to 2019 change, and in Switzerland the mean was 3.6% above 2015 by 2019. The data does not say whether these steps reflect demand or a change in what the series measures.
- Cyprus has figures for two years only (2017 and 2018), Ukraine for three (2018 to 2020), and Serbia for five (2016 to 2020), because the other years do not meet the coverage rule (Table 1.1).
- 161 suspect hours were left out of the window, 73 of them in Luxembourg and 45 in Switzerland. They change no country's mean by more than 49 MW (Table 1.4 and Decision 12).

### What this means

Demand differs greatly in size, from about 390 MW in Montenegro to about 55,800 MW in Germany, and a country's size accounts for most of the differences between countries. Year to year, most countries moved by a few percent, without a common direction before 2020. In the first nine months of 2020, nearly all countries used less electricity than in the same months of 2019, which is consistent with the reduced economic activity in spring 2020, though this question does not test that.

For a reader who uses the figures, the Netherlands, United Kingdom and Switzerland need care before their year-to-year changes are used as measures of demand.

### Limitations

- These are associations. The data does not show why demand changed.
- The 2020 figures include the spring months of 2020, when electricity demand fell in Europe during the COVID-19 pandemic. They were not reported separately, and no statement about a trend is made from them (Decision 14).
- The three one-year steps were not examined, so I do not know whether they reflect demand or a change in what the series measures.
- The mean load depends on a country's size. The data has no population or economic information, so the figures cannot be read per person.
- Some countries have fewer years, as listed above, and 161 suspect hours were left out. Bad hours that the screen did not catch may remain (Decision 13).
- The data ends on 30 September 2020, so every comparison uses January to September only.
- The primary data comes from the ENTSO-E Transparency Platform and each country's transmission system operator, and their terms apply (Decision 1).
