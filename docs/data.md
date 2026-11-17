# Principles used to build `data.csv`

These are the rules used to construct `out/data.csv.zip`.

## What the file is

- One archive, `out/data.csv.zip`, containing one CSV named `data.csv`.
- One row is a country, year, sex, and age. Columns, in order: `country`, `year`, `sex`, `age`, `deaths`, `exposure`, `deaths_source`, `population_source`.
- A row is kept when it has deaths, exposure, or both. The two series are joined on country, year, sex, and age.
- Sex is male or female. There is no both-sexes row.
- Deaths are rounded with R's `round()` only in this file. Earlier death files stay unrounded. Exposure is not rounded.
- Rows are ordered by country, year, sex, and the age label as text.

## Who is included

- The country list is the HMD study list. A source is kept, renamed, or merged according to `data/hmd/countries.csv`. A blank target drops that source. Merged sources are summed after they share a study code. `data/stmf/countries.csv` uses the same blank-target rule.
- Belarus (`BLR`), Russia (`RUS`), Ukraine (`UKR`), and Israel (`ISR`) are dropped by a blank target. Belarus, Russia, and Ukraine are dropped because there is no detailed, reliable death data for 2024 and 2025, including from the national statistical agencies. Israel is dropped because HMD deaths end in 2016.
- Greece and Slovenia stay. HMD deaths for both end in 2019.
- WPP is used only for countries that remain. STMF is used only for countries that pass its own map and have week 52 of the last year. NSO deaths do not add a country that is outside this list.

## Years

- The first year and the last year are Makefile parameters: `YEAR_MIN` is 1960 and `YEAR_MAX` is 2025.
- Deaths run from 1960 through 2025.
- Population is a 1 January stock and runs from 1960 through 2026, the 1 January after the last year. Only whole calendar years are kept.
- Exposure exists for year *t* only when population exists for both 1 January *t* and 1 January *t*+1, so the last exposure year is 2025.

## Ages

- HMD deaths, HMD population, and WPP population are put on one grid: age 0, 1–4, five-year groups through 95–99, and 100+. Everything from 100 up is added into 100+ before that coarsening. WPP single years are summed onto the same groups.
- For a country–year that has HMD deaths, those HMD ages are the ages in the file.
- STMF is used for a country–year with no HMD deaths. Its ages stay as published for that country and year. Unknown ages and all-age totals are dropped. A group fully covered by finer groups is dropped. A closed group that overlaps an open group is dropped, such as 95–99 when 95+ is present. What remains must start at 0, end with an open group, and have no gaps or overlaps, for each sex. The same age set is used for both sexes.
- NSO is used for a country–year with neither HMD nor STMF deaths. Its ages stay as published for that country and year.

## Deaths

- For each country and year, deaths come from the first source that has that country–year: HMD, then STMF, then NSO. A lower-priority source does not fill a missing sex or age inside a year that a higher-priority source already covers.
- STMF weeks are summed to the calendar year. Only male and female are kept. The published all-age total is not kept.
- One recorded STMF correction is applied before labelling ages: for Germany (`DEUTNP`), females, 2025, age 95, the interval is treated as open (95+) rather than 95–99.

## Population and exposure

- There is one population series. HMD is used wherever it is present.
- Where HMD is absent, the count is WPP multiplied by 1,000 and then by a scale. The scale is HMD divided by that WPP count, calculated separately for each country, sex, and age, at the latest year in which HMD is present. If WPP is missing or zero in that year, WPP is not used for that country–sex–age at all.
- Exposure in year *t* is half the sum of the scaled 1 January populations at *t* and *t*+1.
- `population_source` describes those two stocks: `hmd` if both are HMD, `wpp` if both are WPP, `mixed` if both exist and differ, and missing if either stock has no source.
- `deaths_source` is `hmd`, `stmf`, or `nso`, and is missing on a row that has exposure but no deaths.
