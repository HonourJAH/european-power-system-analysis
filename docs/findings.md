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
