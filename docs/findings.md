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

## Business question 2: At what hours and on which days is demand highest, and does the daily shape change between winter and summer and between years?

### Findings

This question uses the 19 countries on Central European Time that meet the coverage rule (Decision 16), so that the hour of the day means the same clock in every country. Hours are local time. The overall pattern uses 2015 to 2019. Winter is January and February, summer is June to August, and spring is March to May, with spring 2020 reported separately. Hours that look like errors are left out (Decision 13). All figures are mean loads in MW, not totals. The peak-to-lowest ratio is the mean load at the peak hour divided by the mean load at the lowest hour.

Table 2.1: Peak hour, lowest hour and weekday pattern by country, 2015 to 2019

| Country | Hours counted | Peak hour | Lowest hour | Peak-to-lowest ratio | Busiest weekday | Quietest weekday | Quietest weekday against busiest |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Austria | 43,799 | 11:00 | 03:00 | 1.50 | Wednesday | Sunday | -21.3% |
| Belgium | 43,824 | 11:00 | 03:00 | 1.32 | Wednesday | Sunday | -14.5% |
| Croatia | 43,823 | 20:00 | 03:00 | 1.62 | Wednesday | Sunday | -12.8% |
| Czechia | 43,716 | 12:00 | 03:00 | 1.34 | Wednesday | Sunday | -16.9% |
| Denmark | 43,820 | 17:00 | 03:00 | 1.56 | Wednesday | Sunday | -15.7% |
| France | 43,794 | 12:00 | 04:00 | 1.32 | Thursday | Sunday | -14.7% |
| Germany | 43,824 | 11:00 | 02:00 | 1.47 | Wednesday | Sunday | -23.1% |
| Hungary | 43,824 | 19:00 | 03:00 | 1.38 | Thursday | Sunday | -14.7% |
| Italy | 43,823 | 19:00 | 03:00 | 1.61 | Wednesday | Sunday | -27.1% |
| Luxembourg | 43,130 | 12:00 | 04:00 | 1.35 | Thursday | Sunday | -21.4% |
| Montenegro | 43,592 | 20:00 | 04:00 | 1.62 | Thursday | Saturday | -3.0% |
| Netherlands | 43,824 | 17:00 | 03:00 | 1.47 | Wednesday | Sunday | -17.5% |
| Norway | 43,706 | 10:00 | 03:00 | 1.21 | Tuesday | Sunday | -7.6% |
| Poland | 43,823 | 12:00 | 03:00 | 1.38 | Wednesday | Sunday | -20.0% |
| Slovakia | 43,790 | 11:00 | 03:00 | 1.31 | Wednesday | Sunday | -12.7% |
| Slovenia | 43,822 | 19:00 | 03:00 | 1.43 | Thursday | Sunday | -18.2% |
| Spain | 43,806 | 13:00 | 04:00 | 1.42 | Wednesday | Sunday | -17.4% |
| Sweden | 43,728 | 10:00 | 03:00 | 1.29 | Wednesday | Sunday | -10.8% |
| Switzerland | 43,778 | 12:00 | 01:00 | 1.22 | Wednesday | Sunday | -11.9% |

Table 2.2: Peak hour and peak-to-lowest ratio in winter and summer, 2015 to 2020

| Country | Winter hours | Winter peak hour | Winter ratio | Summer hours | Summer peak hour | Summer ratio |
| --- | --- | --- | --- | --- | --- | --- |
| Austria | 8,543 | 18:00 | 1.45 | 13,248 | 11:00 | 1.56 |
| Belgium | 8,543 | 18:00 | 1.32 | 13,248 | 11:00 | 1.34 |
| Croatia | 8,542 | 19:00 | 1.68 | 13,248 | 12:00 | 1.61 |
| Czechia | 8,542 | 12:00 | 1.30 | 13,248 | 11:00 | 1.41 |
| Denmark | 8,540 | 17:00 | 1.61 | 13,248 | 11:00 | 1.56 |
| France | 8,523 | 19:00 | 1.26 | 13,237 | 12:00 | 1.43 |
| Germany | 8,543 | 18:00 | 1.41 | 13,248 | 11:00 | 1.53 |
| Hungary | 8,543 | 18:00 | 1.42 | 13,248 | 12:00 | 1.39 |
| Italy | 8,542 | 18:00 | 1.78 | 13,248 | 11:00 | 1.50 |
| Luxembourg | 8,247 | 19:00 | 1.37 | 13,220 | 12:00 | 1.36 |
| Montenegro | 8,542 | 18:00 | 1.60 | 13,090 | 20:00 | 1.65 |
| Netherlands | 8,543 | 17:00 | 1.55 | 13,248 | 17:00 | 1.34 |
| Norway | 8,446 | 17:00 | 1.20 | 13,232 | 10:00 | 1.23 |
| Poland | 8,542 | 17:00 | 1.41 | 13,248 | 12:00 | 1.43 |
| Slovakia | 8,541 | 11:00 | 1.30 | 13,232 | 12:00 | 1.34 |
| Slovenia | 8,484 | 18:00 | 1.48 | 13,248 | 12:00 | 1.39 |
| Spain | 8,531 | 20:00 | 1.51 | 13,248 | 13:00 | 1.43 |
| Sweden | 8,542 | 17:00 | 1.29 | 13,248 | 11:00 | 1.35 |
| Switzerland | 8,542 | 19:00 | 1.18 | 13,203 | 12:00 | 1.27 |

Table 2.3: Peak hour and peak-to-lowest ratio in spring 2015 to 2019 and in spring 2020

| Country | Spring 2015 to 2019 hours | Peak hour | Ratio | Spring 2020 hours | Peak hour | Ratio |
| --- | --- | --- | --- | --- | --- | --- |
| Austria | 11,035 | 11:00 | 1.49 | 2,207 | 11:00 | 1.47 |
| Belgium | 11,035 | 11:00 | 1.31 | 2,207 | 11:00 | 1.26 |
| Croatia | 11,035 | 20:00 | 1.64 | 2,207 | 20:00 | 1.59 |
| Czechia | 11,035 | 12:00 | 1.32 | 2,207 | 11:00 | 1.35 |
| Denmark | 11,034 | 10:00 | 1.52 | 2,207 | 18:00 | 1.44 |
| France | 11,035 | 12:00 | 1.29 | 2,204 | 12:00 | 1.29 |
| Germany | 11,035 | 11:00 | 1.47 | 2,207 | 11:00 | 1.45 |
| Hungary | 11,035 | 20:00 | 1.37 | 2,207 | 20:00 | 1.36 |
| Italy | 11,035 | 20:00 | 1.59 | 2,207 | 20:00 | 1.59 |
| Luxembourg | 10,929 | 12:00 | 1.32 | 2,207 | 19:00 | 1.29 |
| Montenegro | 11,035 | 20:00 | 1.61 | 1,703 | n/a | n/a |
| Netherlands | 11,035 | 17:00 | 1.41 | 2,207 | 19:00 | 1.28 |
| Norway | 11,031 | 08:00 | 1.20 | 2,207 | 09:00 | 1.16 |
| Poland | 11,035 | 12:00 | 1.37 | 2,207 | 20:00 | 1.34 |
| Slovakia | 11,028 | 11:00 | 1.29 | 2,207 | 11:00 | 1.33 |
| Slovenia | 11,034 | 20:00 | 1.43 | 2,207 | 20:00 | 1.44 |
| Spain | 11,029 | 21:00 | 1.41 | 2,207 | 13:00 | 1.43 |
| Sweden | 11,007 | 09:00 | 1.25 | 2,207 | 08:00 | 1.20 |
| Switzerland | 11,035 | 12:00 | 1.22 | 2,207 | 12:00 | 1.23 |

Table 2.4: Peak hour in each year, and the lowest and highest yearly peak-to-lowest ratio

| Country | 2015 | 2016 | 2017 | 2018 | 2019 | Lowest yearly ratio | Highest yearly ratio |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Austria | 11:00 | 11:00 | 11:00 | 11:00 | 11:00 | 1.48 | 1.51 |
| Belgium | 11:00 | 11:00 | 11:00 | 11:00 | 11:00 | 1.31 | 1.34 |
| Croatia | 20:00 | 20:00 | 20:00 | 20:00 | 20:00 | 1.59 | 1.65 |
| Czechia | 11:00 | 12:00 | 12:00 | 12:00 | 12:00 | 1.34 | 1.35 |
| Denmark | 17:00 | 17:00 | 17:00 | 17:00 | 17:00 | 1.52 | 1.60 |
| France | 12:00 | 12:00 | 12:00 | 12:00 | 12:00 | 1.31 | 1.32 |
| Germany | 11:00 | 11:00 | 11:00 | 11:00 | 11:00 | 1.45 | 1.49 |
| Hungary | 12:00 | 12:00 | 12:00 | 19:00 | 19:00 | 1.37 | 1.41 |
| Italy | 19:00 | 19:00 | 19:00 | 19:00 | 19:00 | 1.60 | 1.62 |
| Luxembourg | 11:00 | 11:00 | 12:00 | 13:00 | 12:00 | 1.33 | 1.44 |
| Montenegro | 20:00 | 20:00 | 20:00 | 20:00 | 20:00 | 1.60 | 1.67 |
| Netherlands | 17:00 | 17:00 | 17:00 | 17:00 | 17:00 | 1.36 | 1.62 |
| Norway | 10:00 | 10:00 | 10:00 | 10:00 | 10:00 | 1.20 | 1.22 |
| Poland | 19:00 | 13:00 | 12:00 | 12:00 | 12:00 | 1.37 | 1.39 |
| Slovakia | 11:00 | 11:00 | 11:00 | 11:00 | 11:00 | 1.30 | 1.32 |
| Slovenia | 19:00 | 19:00 | 19:00 | 19:00 | 19:00 | 1.39 | 1.46 |
| Spain | 21:00 | 21:00 | 13:00 | 13:00 | 13:00 | 1.41 | 1.43 |
| Sweden | 10:00 | 10:00 | 10:00 | 10:00 | 10:00 | 1.27 | 1.30 |
| Switzerland | 12:00 | 12:00 | 12:00 | 12:00 | 12:00 | 1.20 | 1.28 |

Table 2.5: How many countries show each pattern (tallied from Tables 2.1 to 2.4)

| Pattern | Countries |
| --- | --- |
| Overall peak hour at midday (10:00 to 13:00) | 12 of 19 |
| Overall peak hour in the evening (17:00 to 20:00) | 7 of 19 |
| Lowest hour at 03:00 | 13 of 19 |
| Lowest hour at 04:00 | 4 of 19 |
| Lowest hour at 01:00 or 02:00 | 2 of 19 |
| Busiest weekday is Wednesday | 13 of 19 |
| Busiest weekday is Thursday | 5 of 19 |
| Busiest weekday is Tuesday | 1 of 19 |
| Quietest weekday is Sunday | 18 of 19 |
| Quietest weekday is Saturday | 1 of 19 |
| Winter peak hour in the evening (17:00 to 20:00) | 17 of 19 |
| Summer peak hour at midday (10:00 to 13:00) | 17 of 19 |
| Summer ratio higher than winter ratio | 11 of 19 |
| Winter ratio higher than summer ratio | 8 of 19 |
| Spring 2020 peak hour different from spring 2015 to 2019 | 8 of 18 |
| Spring 2020 peak hour the same | 10 of 18 |
| Spring 2020 ratio lower | 11 of 18 |
| Spring 2020 ratio the same | 2 of 18 |
| Spring 2020 ratio higher | 5 of 18 |
| Peak hour the same in every year 2015 to 2019 | 14 of 19 |
| Peak hour changed during 2015 to 2019 | 5 of 19 |

- Over 2015 to 2019, demand peaked at midday (10:00 to 13:00) in 12 of the 19 countries and in the evening (17:00 to 20:00) in 7. The lowest hour was 03:00 in 13 countries and 04:00 in 4 (Tables 2.1 and 2.5).
- Wednesday was the busiest weekday in 13 countries, Thursday in 5 and Tuesday in Norway. Sunday was the quietest in 18 countries and Saturday in Montenegro (Tables 2.1 and 2.5).
- The Sunday dip is largest in Italy (27.1% below the busiest day), Germany (23.1%), Luxembourg (21.4%) and Austria (21.3%), and smallest in Montenegro (3.0%) and Norway (7.6%) (Table 2.1).
- The day-to-night swing is widest in Croatia and Montenegro (ratio 1.62) and Italy (1.61), and narrowest in Norway (1.21) and Switzerland (1.22) (Table 2.1).
- The daily peak moves with the season. In winter it falls in the evening (17:00 to 20:00) in 17 of the 19 countries, and in summer at midday (10:00 to 13:00) in 17 of the 19. The exceptions in winter are Czechia (12:00) and Slovakia (11:00), and in summer Montenegro (20:00) and the Netherlands (17:00) (Tables 2.2 and 2.5).
- The day-to-night swing has no common direction between seasons. It was larger in summer than in winter in 11 countries and larger in winter in 8. The biggest differences are Italy (1.78 in winter against 1.50 in summer), the Netherlands (1.55 against 1.34) and France (1.26 against 1.43) (Tables 2.2 and 2.5).
- Spring 2020 compared with spring 2015 to 2019, in the 18 countries with enough hours (Montenegro is left out, because only 1,703 of 2,207 hours have a reading, which is 77.2%): the peak hour was different in 8 countries and the same in 10, and the ratio was lower in 11, the same in 2 and higher in 5 (Tables 2.3 and 2.5). The largest changes were Denmark, where the peak moved from 10:00 to 18:00, Poland (12:00 to 20:00), Spain (21:00 to 13:00) and the Netherlands (ratio 1.41 to 1.28).
- From 2015 to 2019 the peak hour stayed the same in 14 countries and changed in 5: Czechia, Hungary, Luxembourg, Poland and Spain. Spain's peak moved from 21:00 in 2015 and 2016 to 13:00 from 2017, Hungary's from 12:00 to 19:00 in 2018, and Poland's from 19:00 in 2015 to 12:00 from 2017 (Tables 2.4 and 2.5).
- The yearly day-to-night ratio was steady within most countries (a range of 0.05 or less in 13 countries). It varied most in the Netherlands (1.36 to 1.62), Luxembourg (1.33 to 1.44), and Denmark, Switzerland and Slovenia (a range of 0.07 to 0.08) (Table 2.4).

### What this means

Demand follows a regular daily and weekly rhythm in these countries. It is lowest in the small hours and on Sundays, it peaks at midday in summer and in the evening in winter, and the Sunday dip is largest in the big industrial economies (Italy, Germany) and smallest in Norway and Montenegro. The seasonal and weekday patterns are stable, but the size of the day-to-night swing is not consistent from one country to the next or between seasons.

Two things need care. In five countries the peak hour changed during 2015 to 2019 (Czechia, Hungary, Luxembourg, Poland and Spain), and in the Netherlands the yearly ratio varied widely. The data does not say whether these reflect a change in demand or a change in what the series measures. The Netherlands also showed an unexplained step in business question 1.

### Limitations

- These are associations. The data shows when demand is highest, not why. Working hours, climate, heating and lighting habits are possible reasons, but this question does not test them.
- The 19 countries were chosen because they share Central European Time. The time zones were assigned from general knowledge and not from the data (Decision 16). Serbia is left out because of its 2015 coverage. Countries in other time zones are not compared.
- Winter is January and February only, and spring and summer cover three months each, so September to December is not part of any season. Summer 2020 may still show effects of the pandemic. Montenegro's spring 2020 is left out because of missing hours (Decision 17).
- The same reading counts in a season and in a year, so the periods overlap (Decision 17).
- Public holidays are not removed, because the data does not mark them. They may lower the figure of some weekdays.
- Peaks and lows are averages across many days. A single day can look quite different.
- 208 suspect hours were left out, and bad hours that the screen did not catch may remain (Decision 13).
- The data in the source comes from the ENTSO-E Transparency Platform and each country's transmission system operator, and their terms apply (Decision 1).

## Business question 3: How much of demand is met by wind and solar generation, and how does the share change by year, season and country?

### Findings

The share of a period is the mean wind generation plus the mean solar generation, divided by the mean load, over the hours in which all three are filled (Decision 20). Wind is the total wind column for Belgium, Germany, Denmark, the United Kingdom and the Netherlands, and the onshore wind column for every other country, because the total wind column already contains onshore and offshore wind (Decision 18). Hours that look like errors in the load data are left out (Decision 13). Years are January to September. A period is shown only if at least 90% of its hours are matched, and the whole period needs at least 50,000 matched hours (Decision 19). Other cells show "n/a". A share describes average generation against average demand and does not show that the electricity was used when it was produced.

Table 3.1: Whole-period share of demand met by wind and solar, 2015 to 2020

| Country | Matched hours | Wind | Solar | Wind and solar combined |
| --- | --- | --- | --- | --- |
| Denmark | 50,385 | 43.3% | 2.8% | 46.0% |
| Germany | 50,295 | 20.8% | 8.2% | 29.1% |
| Spain | 50,373 | 19.6% | 5.7% | 25.2% |
| United Kingdom | 50,103 | 13.2% | 3.3% | 16.6% |
| Greece | 50,323 | 9.4% | 7.2% | 16.6% |
| Romania | 50,254 | 11.3% | 2.3% | 13.6% |
| Austria | 50,314 | 10.3% | 1.9% | 12.2% |
| Estonia | 50,308 | 8.2% | 0.1% | 8.3% |
| France | 50,349 | 5.5% | 2.1% | 7.6% |
| Bulgaria | 50,322 | 3.6% | 3.6% | 7.2% |
| Czechia | 50,258 | 0.9% | 3.5% | 4.4% |
| Slovenia | 50,313 | 0.0% | 2.2% | 2.2% |
| Belgium | 46,453 | n/a | n/a | n/a |
| Lithuania | 49,472 | n/a | n/a | n/a |
| Switzerland | 49,560 | n/a | n/a | n/a |
| Italy | 41,648 | n/a | n/a | n/a |
| Netherlands | 43,386 | n/a | n/a | n/a |

Table 3.2: Combined share by year, January to September

| Country | 2015 | 2016 | 2017 | 2018 | 2019 | 2020 |
| --- | --- | --- | --- | --- | --- | --- |
| Austria | 10.3% | 9.9% | 12.1% | 11.8% | 14.9% | 14.9% |
| Belgium | 9.5% | 9.6% | 9.7% | 11.6% | 14.0% | 19.6% |
| Bulgaria | 7.9% | 7.5% | 7.5% | 6.9% | 7.3% | 8.5% |
| Czechia | 5.2% | 4.7% | 4.7% | 5.0% | 5.0% | 5.2% |
| Denmark | 42.9% | 36.8% | 44.5% | 43.1% | 50.5% | 53.6% |
| Estonia | 7.8% | 6.0% | 8.0% | 7.1% | 8.4% | 11.5% |
| France | 5.7% | 6.2% | 6.7% | 7.7% | 9.3% | 11.8% |
| Germany | 23.1% | 23.6% | 26.8% | 29.7% | 34.0% | 38.6% |
| Greece | 14.2% | 15.0% | 15.2% | 16.3% | 18.5% | 23.0% |
| Italy | n/a | 13.2% | 13.3% | 12.4% | 13.8% | 15.5% |
| Lithuania | 6.7% | 7.9% | 9.8% | 9.9% | 12.0% | 13.3% |
| Netherlands | n/a | 8.5% | 10.5% | 12.0% | n/a | 6.9% |
| Romania | 14.1% | 12.7% | 14.7% | 12.4% | 13.3% | 15.0% |
| Slovenia | 2.7% | 2.9% | 2.6% | 2.2% | 2.2% | 2.6% |
| Spain | 25.4% | 26.1% | 23.9% | 24.0% | 25.8% | 29.9% |
| Switzerland | 0.5% | 0.8% | 1.0% | 0.8% | 1.0% | n/a |
| United Kingdom | 11.6% | 12.8% | 16.0% | 17.2% | 18.9% | 24.4% |

Table 3.3: Combined share by season

| Country | Winter, 2015 to 2020 | Summer, 2015 to 2020 | Spring, 2015 to 2019 | Spring, 2020 |
| --- | --- | --- | --- | --- |
| Austria | 11.6% | 10.9% | 13.9% | 17.5% |
| Belgium | 10.7% | n/a | 11.2% | 21.5% |
| Bulgaria | 5.8% | 8.4% | 8.0% | 9.5% |
| Czechia | 2.4% | 6.4% | 5.4% | 6.4% |
| Denmark | 49.3% | 41.1% | 45.1% | 54.0% |
| Estonia | 8.9% | 7.4% | 7.1% | 11.6% |
| France | 6.8% | 8.1% | 7.5% | 12.8% |
| Germany | 29.4% | 27.8% | 29.7% | 41.5% |
| Greece | 14.2% | 17.1% | 17.2% | 25.0% |
| Italy | n/a | n/a | n/a | 18.5% |
| Lithuania | 11.2% | 8.5% | 10.0% | 14.5% |
| Netherlands | n/a | 7.7% | n/a | 6.5% |
| Romania | 14.4% | 11.4% | 14.8% | 19.3% |
| Slovenia | 1.0% | 3.5% | 2.7% | 3.0% |
| Spain | 26.5% | 23.2% | 28.6% | 33.3% |
| Switzerland | 0.6% | 2.2% | 0.9% | 5.8% |
| United Kingdom | 15.9% | 16.6% | 15.3% | 24.3% |

Table 3.4: Changes in the combined share, in percentage points

| Country | 2019 against 2015 | Jan to Sep 2020 against 2019 | Spring 2020 against spring 2015 to 2019 |
| --- | --- | --- | --- |
| Austria | +4.6 | 0.0 | +3.6 |
| Belgium | +4.5 | +5.6 | +10.3 |
| Bulgaria | -0.6 | +1.2 | +1.5 |
| Czechia | -0.2 | +0.2 | +1.0 |
| Denmark | +7.6 | +3.1 | +8.9 |
| Estonia | +0.6 | +3.1 | +4.5 |
| France | +3.6 | +2.5 | +5.3 |
| Germany | +10.9 | +4.6 | +11.8 |
| Greece | +4.3 | +4.5 | +7.8 |
| Italy | n/a | +1.7 | n/a |
| Lithuania | +5.3 | +1.3 | +4.5 |
| Netherlands | n/a | n/a | n/a |
| Romania | -0.8 | +1.7 | +4.5 |
| Slovenia | -0.5 | +0.4 | +0.3 |
| Spain | +0.4 | +4.1 | +4.7 |
| Switzerland | +0.5 | n/a | +4.9 |
| United Kingdom | +7.3 | +5.5 | +9.0 |

Table 3.5: How many countries show each pattern (tallied from Tables 3.1 to 3.4)

| Pattern | Countries |
| --- | --- |
| Meet the whole-period rule | 12 of 17 |
| Wind share larger than solar share | 9 of 12 |
| Solar share larger than wind share | 2 of 12 |
| Wind and solar shares equal | 1 of 12 |
| Share in 2019 higher than in 2015 | 11 of 15 |
| Share in 2019 lower than in 2015 | 4 of 15 |
| Share in January to September 2020 higher than in 2019 | 14 of 15 |
| Share in January to September 2020 equal to 2019 | 1 of 15 |
| Spring 2020 higher than spring 2015 to 2019 | 15 of 15 |
| Winter share higher than summer share | 7 of 14 |
| Summer share higher than winter share | 7 of 14 |

- Over 2015 to 2020, wind and solar together met 46.0% of demand in Denmark, 29.1% in Germany and 25.2% in Spain, and 2.2% in Slovenia, 4.4% in Czechia and 7.2% in Bulgaria (Table 3.1).
- Wind provided the larger share in 9 of the 12 countries, and solar in 2 (Czechia and Slovenia). In Denmark wind alone was 43.3% (Tables 3.1 and 3.5).
- Between 2015 and 2019 the share rose in 11 of the 15 countries with both years, by up to 10.9 percentage points in Germany, 7.6 in Denmark and 7.3 in the United Kingdom. It fell slightly in Bulgaria, Czechia, Romania and Slovenia (Tables 3.2, 3.4 and 3.5).
- In January to September 2020 the share was higher than in 2019 in 14 of the 15 countries with both years, and the same in Austria. The largest rises were in Belgium (+5.6 points), the United Kingdom (+5.5), Germany (+4.6) and Greece (+4.5) (Tables 3.4 and 3.5).
- Spring 2020 had a higher share than spring 2015 to 2019 in all 15 countries with both, by up to 11.8 points in Germany, 10.3 in Belgium and 9.0 in the United Kingdom (Tables 3.4 and 3.5).
- The seasonal pattern differs by country. Of the 14 countries with a winter and a summer share, 7 had a higher share in winter and 7 in summer. Denmark was 8.2 points higher in winter (49.3% against 41.1%), and Czechia was 4.0 points higher in summer (6.4% against 2.4%) (Tables 3.3 and 3.5).
- Switzerland and the Netherlands show patterns that I could not explain. Switzerland's spring 2020 share (5.8%) is far above its spring 2015 to 2019 share (0.9%), and the Netherlands' 2020 share (6.9%) is below its 2018 share (12.0%) while most countries rose (Tables 3.2 and 3.3).
- Five countries have no whole-period share (Belgium, Lithuania, Switzerland, Italy and the Netherlands) because they have fewer than 50,000 matched hours, and 15 more are left out because they report no solar or too few wind or solar readings (Decision 19). Table 3.1 lists the first five.

### What this means

Wind and solar meet a large share of demand in a few countries, led by Denmark, and a small share in most. In most countries the share rose between 2015 and 2019, and rose further in 2020. The seasons do not give a common picture: the share is higher in winter in some countries and in summer in others.

The 2020 rise needs care. The share is generation divided by demand, and demand fell in 2020 (business question 1), so the share rises when demand falls even if generation does not move. The figures show that the share rose, and do not show that generation grew.

### Limitations

- These are associations. The data does not show why a country's share is higher or lower.
- The share compares average generation with average demand. It does not show that wind and solar electricity was used when it was produced, because imports, exports and storage are not in the data.
- The 2020 and spring 2020 shares are affected by the fall in demand during the pandemic.
- Wind uses the total column for five countries and the onshore column for the others. A country with offshore wind but no offshore column would be understated, and I do not know which (Decision 18).
- A blank reading is taken to mean that no value was stored, not that generation was zero. A country that reports no solar may still have solar generation, and 15 countries are left out for this reason or because of low coverage (Decision 19).
- The generation readings were not screened for extreme hours, and Slovenia's wind readings are close to zero.
- Seasons cover 2015 to 2020, so a country with no readings in an early year shows n/a for them.
- Switzerland and the Netherlands show patterns that I could not explain.
- The data ends on 30 September 2020, so every year uses January to September only.
- The primary data comes from the ENTSO-E Transparency Platform and each country's transmission system operator, and their terms apply (Decision 1).

## Business question 4: Where day-ahead prices exist, do prices rise with demand and fall when wind and solar output is high, and does this hold in each year?

### Findings

Day-ahead prices exist for 32 price zones in 8 countries, and nine zones in three countries have price, load, solar and wind readings in at least 40,000 hours: DK_1 and DK_2 (Denmark), GB_GBN (the United Kingdom) and six Italian zones (Decision 22). The other 23 zones fail on at least one measure and are not used. Italy's six zones are parts of one national market, so the nine zones are three markets.

For each zone, the relationship is measured as a correlation, which runs from -1 to +1. A positive value means that the two series tend to be high together, and a negative value means that one tends to be high when the other is low. Load is in MW, and generation is wind plus solar in MW. Only hours in which price, load, solar and wind are all filled are used. Each correlation is shown raw and adjusted. The adjusted value removes the zone's mean for each local hour of the day from both series, so that a daily cycle that both follow is not counted as a relationship (Decision 21). Years are January to September, and every period meets the coverage rule.

Table 4.1: Whole-period relationships, 2015 to 2020

| Zone | Matched hours | Price with load, raw | Price with load, adjusted | Price with wind and solar, raw | Price with wind and solar, adjusted | Hours at or below zero | Share of hours |
| --- | --- | --- | --- | --- | --- | --- | --- |
| DK_1 | 50,377 | 0.38 | 0.27 | -0.33 | -0.37 | 558 | 1.1% |
| DK_2 | 50,373 | 0.38 | 0.23 | -0.27 | -0.32 | 362 | 0.7% |
| GB_GBN | 50,247 | 0.38 | 0.22 | -0.10 | -0.19 | 138 | 0.3% |
| IT_CNOR | 50,245 | 0.58 | 0.56 | -0.10 | -0.24 | 23 | 0.0% |
| IT_CSUD | 50,251 | 0.48 | 0.46 | -0.23 | -0.32 | 24 | 0.0% |
| IT_NORD | 50,224 | 0.60 | 0.55 | -0.07 | -0.26 | 5 | 0.0% |
| IT_SARD | 50,251 | 0.54 | 0.44 | -0.21 | -0.22 | 194 | 0.4% |
| IT_SICI | 50,105 | 0.53 | 0.41 | -0.33 | -0.34 | 128 | 0.3% |
| IT_SUD | 50,251 | 0.53 | 0.49 | -0.32 | -0.33 | 48 | 0.1% |
| Total | | | | | | 1,480 | |

Table 4.2: Price with load by zone and year (raw / adjusted)

| Zone | 2015 | 2016 | 2017 | 2018 | 2019 | 2020 |
| --- | --- | --- | --- | --- | --- | --- |
| DK_1 | 0.58 / 0.47 | 0.41 / 0.23 | 0.49 / 0.37 | 0.23 / -0.01 | 0.46 / 0.42 | 0.25 / 0.19 |
| DK_2 | 0.60 / 0.49 | 0.31 / 0.10 | 0.51 / 0.33 | 0.18 / -0.13 | 0.53 / 0.48 | 0.26 / 0.09 |
| GB_GBN | 0.50 / 0.13 | 0.22 / 0.04 | 0.60 / 0.48 | 0.34 / -0.02 | 0.65 / 0.63 | 0.53 / 0.38 |
| IT_CNOR | 0.58 / 0.59 | 0.51 / 0.45 | 0.63 / 0.61 | 0.50 / 0.43 | 0.60 / 0.55 | 0.64 / 0.69 |
| IT_CSUD | 0.54 / 0.61 | 0.49 / 0.48 | 0.57 / 0.57 | 0.40 / 0.34 | 0.49 / 0.49 | 0.62 / 0.72 |
| IT_NORD | 0.67 / 0.63 | 0.66 / 0.57 | 0.58 / 0.53 | 0.55 / 0.46 | 0.64 / 0.58 | 0.71 / 0.71 |
| IT_SARD | 0.63 / 0.60 | 0.50 / 0.35 | 0.57 / 0.45 | 0.55 / 0.46 | 0.45 / 0.29 | 0.66 / 0.62 |
| IT_SICI | 0.46 / 0.32 | 0.48 / 0.40 | 0.57 / 0.47 | 0.60 / 0.48 | 0.54 / 0.36 | 0.65 / 0.67 |
| IT_SUD | 0.57 / 0.56 | 0.48 / 0.38 | 0.56 / 0.47 | 0.57 / 0.56 | 0.43 / 0.36 | 0.60 / 0.61 |

Table 4.3: Price with wind and solar generation by zone and year (raw / adjusted)

| Zone | 2015 | 2016 | 2017 | 2018 | 2019 | 2020 |
| --- | --- | --- | --- | --- | --- | --- |
| DK_1 | -0.35 / -0.43 | -0.45 / -0.51 | -0.45 / -0.51 | -0.36 / -0.42 | -0.41 / -0.46 | -0.49 / -0.53 |
| DK_2 | -0.27 / -0.35 | -0.23 / -0.29 | -0.34 / -0.44 | -0.27 / -0.35 | -0.33 / -0.40 | -0.45 / -0.52 |
| GB_GBN | -0.07 / -0.31 | -0.07 / -0.14 | -0.14 / -0.33 | -0.06 / -0.18 | -0.16 / -0.30 | -0.20 / -0.35 |
| IT_CNOR | -0.15 / -0.17 | -0.13 / -0.13 | -0.08 / -0.29 | 0.02 / 0.00 | -0.15 / -0.38 | -0.20 / -0.38 |
| IT_CSUD | -0.30 / -0.36 | -0.31 / -0.40 | -0.18 / -0.31 | -0.15 / -0.19 | -0.22 / -0.26 | -0.32 / -0.43 |
| IT_NORD | 0.06 / -0.06 | 0.01 / -0.25 | -0.08 / -0.32 | 0.05 / -0.00 | -0.11 / -0.40 | -0.15 / -0.37 |
| IT_SARD | -0.25 / -0.25 | -0.27 / -0.26 | -0.16 / -0.18 | -0.27 / -0.28 | -0.23 / -0.20 | -0.18 / -0.14 |
| IT_SICI | -0.39 / -0.43 | -0.44 / -0.41 | -0.42 / -0.40 | -0.41 / -0.46 | -0.34 / -0.34 | -0.31 / -0.29 |
| IT_SUD | -0.41 / -0.44 | -0.44 / -0.41 | -0.34 / -0.37 | -0.31 / -0.32 | -0.36 / -0.32 | -0.34 / -0.35 |

Table 4.4: How many of the 54 zone-years and 9 zones show each pattern (tallied from Tables 4.1 to 4.3)

| Pattern | Count |
| --- | --- |
| Whole period, price with load positive, raw and adjusted | 9 of 9 zones |
| Whole period, price with wind and solar negative, raw and adjusted | 9 of 9 zones |
| Whole period, adjusted price with wind and solar more negative than raw | 9 of 9 zones |
| Whole period, adjusted price with load lower than raw | 9 of 9 zones |
| Price with load positive, raw, by zone-year | 54 of 54 |
| Price with load positive, adjusted, by zone-year | 51 of 54 |
| Price with load zero or negative, adjusted, by zone-year | 3 of 54 (DK_1, DK_2 and GB_GBN, all in 2018) |
| Price with wind and solar negative, raw, by zone-year | 50 of 54 |
| Price with wind and solar positive, raw, by zone-year | 4 of 54 (IT_CNOR in 2018, IT_NORD in 2015, 2016 and 2018) |
| Price with wind and solar at -0.06 or lower, adjusted, by zone-year | 52 of 54 |
| Price with wind and solar about zero, adjusted, by zone-year | 2 of 54 (IT_CNOR and IT_NORD in 2018) |

- In every zone, prices tended to be higher when demand was higher. The whole-period correlation between price and load was between 0.38 and 0.60 raw, and between 0.22 and 0.56 after the daily cycle is removed. It was positive in all 54 zone-years when raw (Tables 4.1, 4.2 and 4.4).
- Part of this comes from the daily cycle. For Denmark and the United Kingdom, removing it lowers the whole-period correlation from 0.38 to between 0.22 and 0.27. For Italy, it changes little (for example 0.58 to 0.56 in IT_CNOR) (Table 4.1).
- After the daily cycle is removed, the price-and-load relationship disappears in three zone-years, all in 2018: DK_1 (-0.01), DK_2 (-0.13) and GB_GBN (-0.02). In GB_GBN in 2016 it is also very small (0.04) (Tables 4.2 and 4.4).
- In every zone, prices tended to be lower when wind and solar output was high. The whole-period correlation was between -0.07 and -0.33 raw and between -0.19 and -0.37 adjusted (Table 4.1).
- This relationship is clearer after the daily cycle is removed, because solar output peaks at midday, when prices are also high. The adjusted value is more negative than the raw value in all nine zones. For IT_NORD it goes from -0.07 to -0.26, and for GB_GBN from -0.10 to -0.19 (Tables 4.1 and 4.4).
- The relationship held in each year. Adjusted, it was -0.06 or lower in 52 of the 54 zone-years, and about zero in IT_CNOR and IT_NORD in 2018 (Tables 4.3 and 4.4).
- The relationship is strongest in Denmark, where the adjusted correlation was between -0.29 and -0.53 in every year, and weakest in GB_GBN in 2016 (-0.14) and IT_SARD in 2020 (-0.14) (Table 4.3).
- Prices of zero or below occurred in 1,480 zone-hours, mostly in Denmark: 558 hours in DK_1 (1.1% of its hours) and 362 in DK_2 (0.7%). The lowest price in each Italian zone was zero, so none went below zero (Table 4.1).

### What this means

Across these nine zones, the data shows two consistent patterns. Prices tend to rise with demand, and prices tend to fall when wind and solar output is high. Both hold in every zone over the whole period, and both held in nearly every year. The relationships are moderate and not strong, and the strength differs by market: demand matters more in Italy, and wind and solar output matters more in Denmark.

The price-and-load link is the weaker of the two in Denmark and the United Kingdom, where part of it comes from the daily cycle that both follow, and in 2018 it disappears in all three zones. The data does not say why.

For a reader who uses these findings, the practical point is that high wind and solar output goes with lower prices in every market tested, and that the data shows direction and consistency and not the size of the effect on the price.

### Limitations

- These are associations. A correlation shows how closely two series move together, not that one causes the other.
- A day-ahead price is set the day before from forecasts, so its relationship with actual load and generation is indirect.
- The size of the effect on the price was not measured. A planned comparison of mean prices across groups of hours was not run (Decision 23), and mean prices are not reported because the currency of the Danish, British and Italian columns was not confirmed.
- Only three countries are covered, and the nine zones are three markets. Italy's six zones are parts of one national market, so they are not independent.
- The 23 other zones are not used, because they lack load, solar or enough price readings (Decision 22).
- Fuel prices, carbon prices and weather are not in the data, and each of them could account for part of the relationships.
- The load, price and generation readings of the zones were not screened for extreme hours.
- Years are January to September, and 2020 includes the spring of the pandemic, when demand fell.
- The primary data comes from the ENTSO-E Transparency Platform and each country's transmission system operator, and their terms apply (Decision 1).

## Business question 5: How accurate is the day-ahead load forecast, which countries have the largest errors, and does the error change by hour, season and year?

### Findings

The day-ahead forecast is the load forecast that each country's transmission operator publishes for the next day. The error for an hour is the absolute difference between the forecast and the actual load, divided by the actual load. The median error is the typical error, and the 90th percentile shows how large the worse hours are. Countries are ranked by the median error, because a few extreme hours move a median much less than a mean. Hours that look like errors in the actual load are left out (Decision 13). The 22 countries that meet the coverage rule have at least 50,000 matched hours (Decision 24). The other countries are shown only for the years and seasons in which at least 90% of the hours are matched, and the cell shows "n/a" where they are not. Hours of the day are in UTC. Years are January to September.

Table 5.1: Forecast error by country, 2015 to 2020, ranked by the median error

| Rank | Country | Matched hours | Median error | Mean error | Mean error without extreme hours | 90th percentile | Share of hours above 5% | Hours with a forecast more than double or less than half of the actual load |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Norway (see the note below) | 50,257 | 0.00% | 0.58% | 0.58% | 1.49% | 2.7% | 0 |
| 2 | Denmark | 50,394 | 0.71% | 1.05% | 1.05% | 2.26% | 1.3% | 2 |
| 3 | Spain | 50,378 | 0.81% | 1.10% | 1.10% | 2.34% | 0.9% | 0 |
| 4 | Romania | 50,275 | 1.15% | 1.45% | 1.45% | 3.04% | 1.7% | 0 |
| 5 | France | 50,356 | 1.47% | 1.75% | 1.75% | 3.54% | 2.4% | 0 |
| 6 | Finland | 50,316 | 1.58% | 1.96% | 1.96% | 4.04% | 5.0% | 0 |
| 7 | Croatia | 50,374 | 1.61% | 2.11% | 2.11% | 4.39% | 6.9% | 0 |
| 8 | Italy | 50,374 | 1.63% | 2.07% | 2.07% | 4.35% | 6.8% | 0 |
| 9 | Poland | 50,351 | 1.63% | 2.14% | 2.14% | 4.69% | 8.5% | 0 |
| 10 | Czechia | 50,243 | 1.79% | 2.18% | 2.18% | 4.52% | 7.1% | 0 |
| 11 | Latvia | 50,172 | 1.87% | 2.32% | 2.31% | 4.78% | 8.7% | 2 |
| 12 | Slovakia | 50,358 | 1.90% | 2.37% | 2.36% | 4.94% | 9.7% | 1 |
| 13 | Belgium | 50,376 | 2.02% | 2.52% | 2.52% | 5.27% | 11.5% | 0 |
| 14 | Sweden | 50,183 | 2.03% | 2.52% | 2.51% | 5.23% | 11.5% | 3 |
| 15 | Portugal | 50,362 | 2.03% | 2.80% | 2.80% | 6.26% | 16.1% | 0 |
| 16 | Greece | 50,363 | 2.35% | 3.17% | 3.17% | 6.92% | 19.8% | 0 |
| 17 | Slovenia | 50,339 | 2.35% | 3.18% | 3.18% | 6.87% | 19.5% | 2 |
| 18 | Germany | 50,376 | 2.49% | 3.05% | 3.05% | 6.27% | 17.8% | 0 |
| 19 | Hungary | 50,353 | 3.78% | 3.98% | 3.98% | 6.94% | 29.4% | 0 |
| 20 | Austria | 50,375 | 3.94% | 5.03% | 4.94% | 10.00% | 39.1% | 27 |
| 21 | Switzerland | 50,281 | 7.40% | 9.22% | 9.09% | 18.37% | 64.6% | 53 |
| 22 | Netherlands | 50,400 | 9.54% | 11.38% | 11.38% | 23.34% | 71.2% | 3 |

Norway's forecast error is close to zero in most years, far below any other country (Table 5.2). A forecast made a day ahead is not expected to be that exact, and I did not test whether Norway's forecast is independent of its actual load. Norway is shown in its place, and is not described as the most accurate.

Table 5.2: Median forecast error by year, January to September

| Country | 2015 | 2016 | 2017 | 2018 | 2019 | 2020 | Range, highest minus lowest |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Austria | 4.31% | 3.61% | 4.57% | 4.42% | 3.29% | 3.35% | 1.28 |
| Belgium | 1.78% | 1.81% | 1.72% | 1.80% | 2.06% | 2.99% | 1.27 |
| Bulgaria | n/a | 2.12% | 2.28% | 1.98% | 2.10% | 2.39% | n/a |
| Croatia | 1.44% | 1.75% | 1.55% | 1.73% | 1.63% | 1.54% | 0.31 |
| Cyprus | n/a | n/a | 6.99% | n/a | n/a | n/a | n/a |
| Czechia | 1.42% | 2.06% | 2.35% | 1.79% | 2.27% | 1.53% | 0.93 |
| Denmark | 0.65% | 0.65% | 0.67% | 0.77% | 0.75% | 0.86% | 0.21 |
| Estonia | 13.86% | 9.08% | 4.40% | 4.41% | 6.30% | 7.13% | 9.46 |
| Finland | 1.35% | 1.30% | 1.52% | 1.80% | 1.48% | 1.65% | 0.50 |
| France | 1.41% | 1.46% | 1.54% | 1.46% | 1.45% | 1.54% | 0.13 |
| Germany | 2.19% | 3.11% | 2.07% | 2.39% | 3.11% | 2.23% | 1.04 |
| Greece | 2.35% | 2.59% | 2.85% | 1.98% | 1.97% | 2.80% | 0.88 |
| Hungary | 3.81% | 3.83% | 3.75% | 3.69% | 3.79% | 4.15% | 0.46 |
| Ireland | 5.18% | 4.33% | 4.22% | 3.31% | 4.83% | 6.59% | 3.28 |
| Italy | 1.45% | 1.75% | 1.56% | 1.51% | 1.73% | 1.83% | 0.38 |
| Latvia | 2.55% | 1.83% | 1.66% | 1.75% | 1.61% | 1.77% | 0.94 |
| Lithuania | 2.64% | 2.83% | 1.96% | 1.83% | 1.33% | 1.58% | 1.50 |
| Luxembourg | 4.86% | 2.66% | 3.73% | 10.08% | 7.60% | 5.60% | 7.42 |
| Montenegro | 2.12% | 3.52% | 2.98% | 3.88% | 3.36% | 4.05% | 1.93 |
| Netherlands | 19.71% | 6.58% | 6.68% | 6.22% | 15.51% | 11.23% | 13.49 |
| Norway | 0.00% | 0.00% | 0.00% | 0.00% | 0.01% | 0.73% | 0.73 |
| Poland | 1.40% | 1.50% | 1.58% | 1.59% | 1.96% | 2.00% | 0.60 |
| Portugal | 1.85% | 1.83% | 1.76% | 2.51% | 2.50% | 2.02% | 0.75 |
| Romania | 1.24% | 1.27% | 1.16% | 1.16% | 1.04% | 1.22% | 0.23 |
| Serbia | n/a | 2.82% | 2.40% | 2.16% | 2.11% | 2.35% | n/a |
| Slovakia | 1.95% | 1.79% | 1.89% | 1.75% | 1.93% | 2.04% | 0.29 |
| Slovenia | 3.86% | 2.42% | 2.21% | 1.93% | 2.20% | 2.23% | 1.93 |
| Spain | 1.01% | 0.84% | 0.81% | 0.71% | 0.70% | 0.89% | 0.31 |
| Sweden | 2.17% | 2.22% | 2.06% | 2.14% | 1.93% | 1.96% | 0.29 |
| Switzerland | 9.21% | 4.48% | 7.50% | 8.43% | 10.24% | 5.66% | 5.76 |
| Ukraine | n/a | n/a | n/a | 2.45% | 2.99% | 4.56% | n/a |
| United Kingdom | 4.12% | 5.94% | 6.24% | 6.12% | 6.74% | 7.17% | 3.05 |

Table 5.3: Median forecast error by season

| Country | Winter, 2015 to 2020 | Summer, 2015 to 2020 | Spring, 2015 to 2019 | Spring, 2020 |
| --- | --- | --- | --- | --- |
| Austria | 4.15% | 3.91% | 3.83% | 3.89% |
| Belgium | 2.06% | 2.00% | 1.76% | 3.91% |
| Bulgaria | n/a | 1.83% | n/a | 2.88% |
| Croatia | 1.62% | 1.67% | 1.60% | 1.83% |
| Cyprus | n/a | n/a | n/a | n/a |
| Czechia | 1.55% | 2.28% | 1.83% | 2.04% |
| Denmark | 0.68% | 0.71% | 0.75% | 0.96% |
| Estonia | 8.55% | 6.82% | 7.69% | 8.09% |
| Finland | 1.40% | 1.41% | 1.59% | 1.83% |
| France | 1.45% | 1.46% | 1.51% | 1.73% |
| Germany | 2.64% | 2.13% | 2.93% | 3.29% |
| Greece | 2.44% | 2.37% | 2.38% | 3.67% |
| Hungary | 2.95% | 4.35% | 4.00% | 3.55% |
| Ireland | 5.72% | 4.23% | 3.72% | 14.45% |
| Italy | 1.54% | 1.74% | 1.55% | 2.05% |
| Latvia | 1.77% | 1.82% | 1.98% | 1.70% |
| Lithuania | 1.71% | 2.03% | 1.98% | 1.76% |
| Luxembourg | 5.51% | 4.59% | 5.60% | 4.19% |
| Montenegro | 2.87% | 2.81% | 4.39% | n/a |
| Netherlands | 7.83% | 11.39% | 9.62% | 11.08% |
| Norway | 0.00% | 0.00% | 0.00% | 0.72% |
| Poland | 1.66% | 1.69% | 1.52% | 2.20% |
| Portugal | 2.22% | 1.82% | 2.19% | 2.40% |
| Romania | 1.05% | 1.25% | 1.23% | 1.39% |
| Serbia | 2.12% | 2.15% | 2.65% | 2.49% |
| Slovakia | 1.94% | 1.88% | 1.87% | 2.07% |
| Slovenia | 2.37% | 2.53% | 2.43% | 2.31% |
| Spain | 0.79% | 0.83% | 0.79% | 1.18% |
| Sweden | 1.74% | 2.29% | 2.14% | 2.08% |
| Switzerland | 6.92% | 7.73% | 7.31% | 7.36% |
| Ukraine | n/a | n/a | n/a | 4.52% |
| United Kingdom | 5.13% | 6.34% | 6.01% | 8.31% |

Table 5.4: Hour of the day (UTC) with the highest and lowest median forecast error, 22 countries

| Country | Worst hour | Median error at the worst hour | Best hour | Median error at the best hour | Worst-to-best ratio |
| --- | --- | --- | --- | --- | --- |
| Austria | 15:00 | 4.51% | 19:00 | 3.20% | 1.41 |
| Belgium | 12:00 | 2.26% | 08:00 | 1.76% | 1.28 |
| Croatia | 14:00 | 1.96% | 07:00 | 1.37% | 1.43 |
| Czechia | 14:00 | 1.98% | 06:00 | 1.58% | 1.25 |
| Denmark | 21:00 | 1.62% | 13:00 | 0.51% | 3.16 |
| Finland | 16:00 | 1.79% | 22:00 | 1.25% | 1.43 |
| France | 22:00 | 2.25% | 08:00 | 1.00% | 2.24 |
| Germany | 06:00 | 2.65% | 18:00 | 2.36% | 1.12 |
| Greece | 14:00 | 3.10% | 00:00 | 1.78% | 1.74 |
| Hungary | 03:00 | 5.06% | 18:00 | 3.33% | 1.52 |
| Italy | 20:00 | 2.24% | 02:00 | 1.15% | 1.95 |
| Latvia | 21:00 | 2.09% | 05:00 | 1.55% | 1.35 |
| Netherlands | 23:00 | 11.59% | 17:00 | 7.62% | 1.52 |
| Norway | 21:00 | 0.44% | 06:00 | 0.00% | n/a |
| Poland | 04:00 | 5.32% | 23:00 | 1.03% | 5.16 |
| Portugal | 15:00 | 2.40% | 09:00 | 1.71% | 1.41 |
| Romania | 12:00 | 1.37% | 22:00 | 1.01% | 1.35 |
| Slovakia | 04:00 | 4.20% | 01:00 | 1.37% | 3.07 |
| Slovenia | 11:00 | 2.99% | 04:00 | 1.95% | 1.53 |
| Spain | 16:00 | 1.11% | 23:00 | 0.63% | 1.77 |
| Sweden | 21:00 | 2.56% | 08:00 | 1.76% | 1.45 |
| Switzerland | 16:00 | 8.41% | 10:00 | 6.10% | 1.38 |

Table 5.5: Countries showing each pattern (tallied from Tables 5.1 to 5.4, 22 countries)

| Pattern | Countries |
| --- | --- |
| Median error below 2% | 12 of 22 |
| Median error from 2% to below 3% | 6 of 22 |
| Median error from 3% to below 5% | 2 of 22 |
| Median error of 5% or more | 2 of 22 |
| Share of hours with an error above 5% is 10% or less | 12 of 22 |
| Yearly median varies by 1.0 point or less | 16 of 22 |
| Yearly median varies by more than 1.0 and up to 2.0 points | 4 of 22 |
| Yearly median varies by more than 2.0 points | 2 of 22 |
| Median error higher in summer than in winter | 15 of 22 |
| Median error higher in winter than in summer | 6 of 22 |
| Median error the same in winter and summer | 1 of 22 |
| Median error higher in spring 2020 than in spring 2015 to 2019 | 18 of 22 |
| Median error lower in spring 2020 than in spring 2015 to 2019 | 4 of 22 |
| Worst hour of the day in the afternoon (11:00 to 16:00) | 11 of 22 |
| Worst hour of the day in the evening (20:00 to 23:00) | 7 of 22 |
| Worst hour of the day in the early morning (03:00 to 06:00) | 4 of 22 |
| Worst-to-best ratio below 1.5 | 11 of 22 |
| Worst-to-best ratio from 1.5 to 2.0 | 6 of 22 |
| Worst-to-best ratio above 2.0 | 4 of 22 |
| Worst-to-best ratio not meaningful (Norway) | 1 of 22 |

Table 5.6: Countries that do not meet the whole-period rule, with hours in which the forecast is more than double or less than half of the actual load

| Country | Matched hours | Hours with an extreme forecast | Share of matched hours |
| --- | --- | --- | --- |
| Luxembourg | 48,651 | 1,209 | 2.5% |
| Montenegro | 49,463 | 326 | 0.7% |
| Estonia | 49,871 | 150 | 0.3% |
| Serbia | 49,374 | 50 | 0.1% |
| United Kingdom | 49,336 | 13 | 0.0% |
| Lithuania | 49,590 | 9 | 0.0% |
| Ireland | 49,375 | 0 | 0.0% |
| Bulgaria | 46,643 | 0 | 0.0% |
| Ukraine | 25,305 | 0 | 0.0% |
| Cyprus | 11,151 | 0 | 0.0% |

- Over 2015 to 2020, the typical forecast error ranged from 0.00% in Norway to 9.54% in the Netherlands across the 22 countries that meet the coverage rule. In 12 countries the median error was below 2%, in 6 it was from 2% to below 3%, in 2 it was from 3% to below 5% (Hungary 3.78% and Austria 3.94%), and in 2 it was above 7% (Switzerland 7.40% and the Netherlands 9.54%) (Tables 5.1 and 5.5).
- The Netherlands and Switzerland had the largest errors on every measure. Their 90th percentile errors were 23.34% and 18.37%, and 71.2% and 64.6% of their hours had an error above 5%. In 12 countries no more than 10% of hours had an error above 5% (Tables 5.1 and 5.5).
- Among the countries with typical errors, Denmark (0.71%), Spain (0.81%) and Romania (1.15%) had the smallest median errors. Norway's error was close to zero (a median of 0.00% in 2015 to 2018, and 0.73% in 2020), far below any other country, and it is shown in its place and not described as the most accurate (Tables 5.1 and 5.2).
- The hours in which the forecast was more than double or less than half of the actual load have almost no effect on the ranked countries. Leaving them out changes a mean error by at most 0.13 percentage points (Switzerland, from 9.22% to 9.09%) and 0.09 in Austria (Table 5.1).
- Luxembourg has the most such hours (1,209, which is 2.5% of its matched hours), followed by Montenegro (326) and Estonia (150). These three countries and the others in Table 5.6 do not meet the whole-period rule, so they are not ranked (Table 5.6).
- The size of the forecast error depends on the hour of the day. In 11 of the 22 countries, the error at the worst hour was less than 1.5 times the error at the best hour, in 6 it was between 1.5 and 2 times, and in 4 it was more than twice (Denmark 3.16, France 2.24, Poland 5.16 and Slovakia 3.07). The worst hour fell in the afternoon (11:00 to 16:00) in 11 countries, in the evening (20:00 to 23:00) in 7, and in the early morning (03:00 to 06:00) in 4 (Tables 5.4 and 5.5).
- The error changes little between winter and summer in most countries. It was higher in summer in 15 of the 22 countries and higher in winter in 6, and in 8 countries the two medians differ by 0.05 points or less (Croatia, Denmark, Finland, France, Latvia, Norway, Poland and Spain). The largest differences are in the Netherlands (7.83% in winter against 11.39% in summer), Hungary (2.95% against 4.35%) and Czechia (1.55% against 2.28%) (Tables 5.3 and 5.5).
- In spring 2020 the median error was higher than in spring 2015 to 2019 in 18 of the 22 countries and lower in 4 (Hungary, Latvia, Slovenia and Sweden). The largest rises were in Belgium (1.76% to 3.91%), the Netherlands (9.62% to 11.08%) and Greece (2.38% to 3.67%) (Tables 5.3 and 5.5).
- From year to year the typical error was steady in most countries. The yearly median varied by 1.0 point or less in 16 of the 22 countries, by more than 1.0 and up to 2.0 points in 4 (Austria, Belgium, Germany and Slovenia), and by more than 2.0 points in 2: the Netherlands (6.22% to 19.71%) and Switzerland (4.48% to 10.24%) (Tables 5.2 and 5.5).
- Among the countries that do not meet the whole-period rule, Estonia's yearly median fell from 13.86% in 2015 to 4.40% in 2017 and rose to 7.13% in 2020, Luxembourg's ranged from 2.66% to 10.08%, and the United Kingdom's rose every year from 4.12% in 2015 to 7.17% in 2020 except for a small fall in 2018 (Table 5.2).

### What this means

In most countries the day-ahead load forecast is close to what happened: the typical error is below 3%, and it changes little from year to year or between winter and summer. The size of the error does depend on the time of day, with the worst hour usually in the afternoon or the evening, and in four countries the worst hour has more than double the error of the best hour.

A few countries stand apart. The Netherlands and Switzerland have errors several times larger than the rest, and their errors vary a lot from year to year. Norway's error is so close to zero that the forecast may not be an independent forecast. Spring 2020 was harder to forecast than earlier springs in 18 of the 22 countries, which is consistent with the changes in demand during the pandemic, though this question does not test that.

For a reader who uses these figures, the practical point is that forecast quality differs between countries and hours. A user who relies on the forecast would plan larger reserves in the Netherlands and Switzerland than elsewhere, and would treat the Norwegian figures with caution.

### Limitations

- These are associations. The data does not show why a country's forecast is more or less accurate.
- The error is a share of the actual load, so it does not show the size of an error in MW. A 5% error in a large country is a much larger amount of electricity than in a small one.
- I did not test whether Norway's forecast is independent of its actual load, and I do not know whether the forecast and the actual load measure the same thing in every year for the Netherlands and Switzerland. Business question 1 also found a one-year step in the actual load of these two countries.
- The hours in which the forecast is more than double or less than half of the actual load were not examined one by one. They may be forecast errors or actual readings that the screen of Decision 12 missed, and they stay in the error figures.
- Hours of the day are in UTC, which is one to two hours behind local time in these countries, and the offset changes with summer time.
- Winter is January and February only, summer is June to August, and spring is March to May, so September to December is not part of any season. Spring 2020 includes the pandemic.
- The 22 ranked countries meet the whole-period rule. The other countries are shown only for the years and seasons in which at least 90% of the hours are matched (Decision 24).
- Suspect hours of the actual load were left out (Decision 13), and bad hours that the screen did not catch may remain.
- The data has no information on how each forecast was made, and it ends on 30 September 2020.
- The primary data comes from the ENTSO-E Transparency Platform and each country's transmission system operator, and their terms apply (Decision 1).
