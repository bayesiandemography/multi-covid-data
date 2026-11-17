OFFICIAL DEATHS DATA FOR COUNTRY-YEARS MISSING FROM data/deaths_observed.zip
============================================================================

Downloaded: 2026-08-27 (Pacific/Auckland)

PURPOSE AND SCOPE
-----------------
The existing data/deaths_observed.zip was checked country by country. Six
countries/territories did not extend through 2025 and are used to fill those
years. Israel's file is kept here as the series that was checked and then
excluded: from 2017 onwards it has one deaths series with age detail and one
with sex detail, and no series with both.

  Canada       last existing year 2023; missing 2024-2025
  Hong Kong    last existing year 2024; missing 2025
  Ireland      last existing year 2022; missing 2023-2025
  Israel       checked 2026-11-17; not used (no age-by-sex series)
  Japan        last existing year 2024; missing 2025
  South Korea  last existing year 2024; missing 2025
  Taiwan       last existing year 2024; missing 2025

This directory contains raw files downloaded from official national statistics
or health-agency websites for those missing years. The downloads have not been
cleaned, filtered, extracted, converted, renamed, or reorganised. Percent-encoded
names and timestamped CSO names are the filenames supplied by the servers.

Occurrence-based data were preferred. Ireland 2024-2025 is the important
exception: the available current age-by-sex table is explicitly registration-
based. Taiwan's publication page does not explicitly distinguish occurrence
from registration, so its date basis is recorded conservatively below.


CANADA
------
Raw file:
  13100768-eng.zip

Agency and dataset:
  Statistics Canada, table 13-10-0768-01,
  "Provisional weekly death counts, by age group and sex".

Missing years supplied:
  2024 and 2025. The raw table currently runs from week ending 2010-01-09
  through 2026-05-02 and contains all 52 weekly reference dates in 2025.

Date basis:
  Occurrence. The geography field for the national series is "Canada, place
  of occurrence".

Breakdowns:
  Sex: both sexes, males, females.
  Age: all ages, 0-44, 45-64, 65-84, 85 and over.
  Frequency: weekly.

Status/cautions:
  Provisional; counts may be revised as provincial and territorial vital-
  statistics submissions become more complete. Age groups are much wider
  than five-year bands.

Official table page:
  https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1310076801

Raw download URL:
  https://www150.statcan.gc.ca/n1/en/tbl/csv/13100768-eng.zip

DOI:
  https://doi.org/10.25318/1310076801-eng


HONG KONG
---------
Raw file:
  get.php

Agency and dataset:
  Census and Statistics Department, table 115-01022,
  "Deaths by sex and age group". get.php is the unmodified JSON response from
  the department's official GET API; the endpoint itself supplies that generic
  filename.

Missing year supplied:
  2025. The response also contains 2022-2024.

Date basis:
  Occurrence. The table note says figures are counted by occurrence time,
  meaning deaths actually taking place in the reference period.

Breakdowns:
  Sex: total, male, female.
  Age: under 1; 1-4; five-year groups from 5-9 through 80-84; 85 and over;
  unknown; total.
  Frequency: annual.

Status/cautions:
  The 2025 figures are provisional. The official release date shown on the
  table is 2026-02-12. Totals may include deaths of unknown sex and therefore
  need not equal male plus female.

Official table/API documentation page:
  https://www.censtatd.gov.hk/en/web_table.html?id=115-01022

Raw API URL used:
  https://www.censtatd.gov.hk/api/get.php?id=115-01022&lang=en&param=N4KABGBEDGBukC4yghSBlAogDUWA2uKmgLKQA0RxkAYpFWALqXUCCA4pnocWgIwBaCg34CALMN5QArAICck3pD4AGAXwkslfWXwVbqAJjWHNIqIdmH95yAGY1ds1Puy7Nl2LVjnSsbLEPJWk1aV9qaVlpIOoANjVY8NRIWNlYmOSAdjVMpLRM2UyMtAAONRK8qBLpAH0AQwA7ABMagHtYAFMAJ0VqAFUGgGsG1oB3BvpiRiIAXy1IAGd4JBRkgBFMVgAVAAluWwAlOtGagAdumomGaYg5okhzroBLVqa8VbQFgBc6rq+8SDGQyGSZgO5oJ5vJDKHQCFSqYGKSAAG0aAHMAR0rjMgA


IRELAND
-------
Raw files:
  VSA29.20260827020459.csv
  VSA07.20260827020411.csv

Agency and datasets:
  Central Statistics Office (CSO), Ireland.

  VSA29: "Deaths Occurring by cause of death, sex and age group".
  This raw cube supplies the preferred occurrence-based data for 2023.

  VSA07: "Deaths Registered classified by area of residence, sex and age-group
  of deceased" in the CSO's Vital Statistics Yearly Summary 2025.
  This raw cube supplies the available age-by-sex fallback for 2024 and 2025.

Missing years supplied:
  2023 from VSA29; 2024 and 2025 from VSA07.

Date basis:
  VSA29: occurrence.
  VSA07 for 2024-2025: registration, not occurrence. This distinction matters
  because late registrations may be assigned to a later year than the death.

Breakdowns:
  Both files contain both sexes, male, and female and five-year age groups
  (plus infant/open-ended/total groups). VSA29 also contains cause of death.
  VSA07 also contains area of residence.

Status/cautions:
  VSA29 runs through 2023. VSA07 runs through 2025, but the CSO's 2025 release
  explicitly describes it as deaths registered. Use VSA07 for 2024-2025 only
  if registration-based timing is acceptable.

Official occurrence-data page (VSA29 and related occurrence tables):
  https://www.cso.ie/en/releasesandpublications/ep/p-vsar/vitalstatisticsannualreport2023/data/

Official 2025 registration-data page (VSA07):
  https://www.cso.ie/en/releasesandpublications/ep/p-vsys/vitalstatisticsyearlysummary2025/data/

Raw VSA29 download URL:
  https://ws.cso.ie/public/api.restful/PxStat.Data.Cube_API.ReadDataset/VSA29/CSV/1.0/en

Raw VSA07 download URL:
  https://ws.cso.ie/public/api.restful/PxStat.Data.Cube_API.ReadDataset/VSA07/CSV/1.0/en


ISRAEL
------
Raw file:
  p-1.xlsx

Agency and dataset:
  Central Bureau of Statistics,
  "פטירות של תושבי ישראל, לפי יום פטירה, מין, קבוצת אוכלוסייה וגיל"
  (Deaths of Israeli residents, by day of death, sex, population group
  and age). p-1.xlsx is the filename supplied by the server. The file on
  the site also contains years outside 2017-2025; it was saved unmodified.

Years in the file:
  The workbook covers 2000 onwards. The 2026 sheet stops on 2026-10-25.
  Not used in the data file. From 2017 onwards there is one series with
  age detail and one with sex detail, and no series with both.

Date basis:
  Occurrence, by day of death. Counts are deaths of Israeli residents in
  Israel and exclude residents who died abroad.

Breakdowns:
  Frequency: daily.
  All-age counts by sex (total, male, female) for the total population,
  for Jews and Others, and for Arabs.
  Age, both sexes together: 0-19, five-year groups from 20-24 through
  85-89, and 90 and over. Age is not published by sex.

Status/cautions:
  Downloaded 2026-11-17. The workbook notes say it was updated to
  2026-11-11, that 2025-2026 are not final, and that totals include
  unknown values of sex, population group, and age. The parts therefore
  need not sum to the total.

Official page linking the file:
  https://www.cbs.gov.il/he/Pages/%D7%9E%D7%9C%D7%97%D7%9E%D7%AA-%D7%97%D7%A8%D7%91%D7%95%D7%AA-%D7%91%D7%A8%D7%96%D7%9C%E2%80%93%D7%91%D7%99%D7%97%D7%93-%D7%A0%D7%A0%D7%A6%D7%97.aspx

Raw download URL:
  https://www.cbs.gov.il/he/publications/LochutTlushim/2020/p-1.xlsx


JAPAN
-----
Raw file:
  R7toukeihyou.xlsx

Agency and dataset:
  Ministry of Health, Labour and Welfare,
  "令和7(2025)年人口動態統計月報年計（概数）" statistical tables
  (2025 Vital Statistics Monthly Report annual total, provisional figures).

Missing year supplied:
  2025.

Date basis:
  Occurrence. The survey overview states that this annual report covers events
  occurring in Japan among Japanese people during 2025 and excludes events
  occurring in earlier years from the monthly-report annual total.

Breakdowns:
  Table 7 provides death counts and rates by sex and age, with separate sheets
  for total, male, and female. Age is under 1, 1-4, predominantly five-year
  bands, then 95-99 and 100 and over.

Status/cautions:
  Provisional annual total (概数), not the later final annual statistics.
  The population covered by this particular report is Japanese people with
  events occurring in Japan.

Official publication page:
  https://www.mhlw.go.jp/toukei/saikin/hw/jinkou/geppo/nengai25/index.html

Survey overview (scope and occurrence basis):
  https://www.mhlw.go.jp/toukei/saikin/hw/jinkou/geppo/nengai25/dl/tyousa.pdf

Raw XLSX download URL:
  https://www.mhlw.go.jp/toukei/saikin/hw/jinkou/geppo/nengai25/xls/R7toukeihyou.xlsx


SOUTH KOREA
-----------
Raw file:
  2025%EB%85%84+%EC%B6%9C%EC%83%9D.%EC%82%AC%EB%A7%9D%ED%86%B5%EA%B3%84%28%EC%9E%A0%EC%A0%95%29.pdf

Decoded Korean filename for reference:
  2025년+출생.사망통계(잠정).pdf

Agency and dataset:
  Ministry of Data and Statistics (official Korean statistics agency),
  "2025 Birth and Death Statistics (Preliminary)".

Missing year supplied:
  2025.

Date basis:
  Occurrence. The PDF states that it aggregates by event date, not report-
  receipt date. It covers 2025 deaths reported from January 2025 through
  January 2026 and includes an estimate of later reports.

Breakdowns:
  Sex: total, male, female.
  Age: 0, 1-9, then ten-year groups through 70-79, 80-89, and 90 and over.
  These are wider than five-year bands.

Status/cautions:
  Preliminary. The PDF says final birth statistics were due in August 2026 and
  final cause-of-death statistics in September 2026; the preliminary and final
  numbers may differ.

Official release page:
  https://www.mods.go.kr/board.es?act=view&bid=204&list_no=443686&mid=a10301020300

Raw PDF download URL:
  https://www.mods.go.kr/boardDownload.es?bid=204&list_no=443686&seq=1


TAIWAN
------
Raw file:
  114%e5%b9%b4%e5%b9%b4%e9%bd%a1%e5%88%a5%e7%b5%b1%e8%a8%881150622.xlsx

Decoded Chinese filename for reference:
  114年年齡別統計1150622.xlsx

Agency and dataset:
  Ministry of Health and Welfare, Department of Statistics,
  "114年年齡別統計" (ROC year 114 / 2025 age-specific cause-of-death
  statistics), published 2026-06-22.

Missing year supplied:
  2025.

Date basis:
  Annual 2025 cause-of-death reference-year data. The publication/download page
  does not explicitly distinguish date of occurrence from date of registration,
  so this file is not labelled here as confirmed occurrence-based.

Breakdowns:
  Sex: total, male, female.
  Age: broad age ranges in the principal tables (including infant, 1-14,
  15-24, 25-44, 45-64, and 65 and over), with additional child/adolescent
  groupings in later sheets. Cause-of-death detail is included. The main age
  bands are wider than five-year bands.

Official 2025 cause-of-death publication page:
  https://dep.mohw.gov.tw/DOS/lp-5069-113-xCat-y114.html

Raw XLSX download URL:
  https://www.mohw.gov.tw/dl-100891-77c9547c-499b-4024-a869-2954d0da38ab.html


READ-ONLY VALIDATION PERFORMED
------------------------------
The files themselves were not changed. Checks performed after downloading:

  - ZIP integrity test for the Statistics Canada archive: passed. It contains
    13100768.csv and 13100768_MetaData.csv.
  - XLSX files opened successfully in read-only mode and their expected sheets,
    year, age and sex headings were present.
  - Ireland CSV headers and year/sex/age fields were read successfully; VSA29
    reaches 2023 and VSA07 reaches 2025.
  - Hong Kong JSON reports API status "Success" and contains 2022-2025, male,
    female and total, and the expected five-year age groups.
  - The Korean PDF opened successfully (51 pages); its occurrence-basis note and
    sex-by-age death tables were readable.


FILE SIZES AND SHA-256 CHECKSUMS
-------------------------------
114%e5%b9%b4%e5%b9%b4%e9%bd%a1%e5%88%a5%e7%b5%b1%e8%a8%881150622.xlsx
  171905 bytes
  b4cd71966eb4fce2d2d8fcd4735a8eec8d8d3f49a6cdf998e4d0c4a5c42a580b

13100768-eng.zip
  2046961 bytes
  e21f4a5d7c9272e540f3a2cf52e3ddb4b76a8188d3a313ac7774e3c7fce22de8

2025%EB%85%84+%EC%B6%9C%EC%83%9D.%EC%82%AC%EB%A7%9D%ED%86%B5%EA%B3%84%28%EC%9E%A0%EC%A0%95%29.pdf
  3829978 bytes
  b9a612133cf81273cca32568959c145795ed6ce485944e02cd66276d47e3bcbb

R7toukeihyou.xlsx
  148385 bytes
  fff1e38a7d1101ba769040b92094cf55d5e49fa0d90b0d9097cc8359df07a71b

VSA07.20260827020411.csv
  18596661 bytes
  13be8aae3b16664e75186fcd271a2c0df1cb37e50e1356aef843beaf37f13b04

VSA29.20260827020459.csv
  76464421 bytes
  9346a09492381c118ac14141981d4166d20d488080fe59662bed1ad60b986e98

get.php
  79494 bytes
  aadd97a1a2f153df79d0c4b66d39241813d0b03ce42d585786ca2d916d42665e

p-1.xlsx
  1450583 bytes
  bdfdfdedcd510db146c7c770345b6d0d69a4a29014408ed143d2355b1974055a
