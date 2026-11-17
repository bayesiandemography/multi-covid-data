command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .canada = "out/nso/canada.rds",
  .hong_kong = "out/nso/hong_kong.rds",
  .ireland = "out/nso/ireland.rds",
  .japan = "out/nso/japan.rds",
  .korea = "out/nso/korea.rds",
  .taiwan = "out/nso/taiwan.rds",
  .countries = "out/hmd/countries.rds",
  year_min = 1960L,
  year_max = 2025L,
  .out = "out/nso/deaths.rds"
)

# Published labels, in published order, mapped onto the file's age text.
# Totals and unknown ages are omitted before this map, so a missing label
# is an unexpected group rather than a total.
recode_age <- function(age, labels) {
  age <- as.character(age)
  unknown <- setdiff(unique(age), names(labels))
  if (length(unknown) > 0L) {
    stop(
      "Unrecognised age label(s): ",
      paste(unknown, collapse = ", "),
      call. = FALSE
    )
  }
  unname(labels[age])
}

sexes <- c("Male", "Female")

keep_sex_age <- function(data, age_labels) {
  data |>
    filter(sex %in% sexes) |>
    mutate(
      age = recode_age(age, age_labels),
      age = factor(age, levels = unique(unname(age_labels)))
    )
}

canada_ages <- c(
  "0 to 44 years" = "0-44",
  "45 to 64 years" = "45-64",
  "65 to 84 years" = "65-84",
  "85 years and over" = "85+"
)

canada <- read_rds(.canada) |>
  filter(
    geo == "Canada, place of occurrence",
    sex %in% sexes,
    age %in% names(canada_ages),
    year_min <= year,
    year <= year_max
  ) |>
  keep_sex_age(canada_ages) |>
  group_by(country, year, sex, age) |>
  summarise(count = sum(count), .groups = "drop")

hong_kong_ages <- c(
  "< 1" = "0",
  "1 - 4" = "1-4",
  "5 - 9" = "5-9",
  "10 - 14" = "10-14",
  "15 - 19" = "15-19",
  "20 - 24" = "20-24",
  "25 - 29" = "25-29",
  "30 - 34" = "30-34",
  "35 - 39" = "35-39",
  "40 - 44" = "40-44",
  "45 - 49" = "45-49",
  "50 - 54" = "50-54",
  "55 - 59" = "55-59",
  "60 - 64" = "60-64",
  "65 - 69" = "65-69",
  "70 - 74" = "70-74",
  "75 - 79" = "75-79",
  "80 - 84" = "80-84",
  "≥85" = "85+"
)

hong_kong <- read_rds(.hong_kong) |>
  filter(
    sex %in% sexes,
    age %in% names(hong_kong_ages),
    year_min <= year,
    year <= year_max
  ) |>
  keep_sex_age(hong_kong_ages) |>
  select(country, year, sex, age, count)

ireland_ages <- c(
  "Under 1 year" = "0",
  "1 - 4 years" = "1-4",
  "5 - 9 years" = "5-9",
  "10 - 14 years" = "10-14",
  "15 - 19 years" = "15-19",
  "20 - 24 years" = "20-24",
  "25 - 29 years" = "25-29",
  "30 - 34 years" = "30-34",
  "35 - 39 years" = "35-39",
  "40 - 44 years" = "40-44",
  "45 - 49 years" = "45-49",
  "50 - 54 years" = "50-54",
  "55 - 59 years" = "55-59",
  "60 - 64 years" = "60-64",
  "65 - 69 years" = "65-69",
  "70 - 74 years" = "70-74",
  "75 - 79 years" = "75-79",
  "80 - 84 years" = "80-84",
  "85 years and over" = "85+"
)

ireland_raw <- read_rds(.ireland)
# VSA29 is deaths occurring. VSA07 supplies a year only when VSA29 has none.
ireland_occurrence <- ireland_raw |>
  filter(table == "VSA29", cause == "All deaths", sex %in% sexes)

ireland <- ireland_raw |>
  filter(
    table == "VSA07",
    area == "State",
    sex %in% sexes,
    !(year %in% unique(ireland_occurrence$year))
  ) |>
  bind_rows(ireland_occurrence) |>
  filter(
    age %in% names(ireland_ages),
    year_min <= year,
    year <= year_max
  ) |>
  keep_sex_age(ireland_ages) |>
  select(country, year, sex, age, count)

japan_ages <- c(
  "0歳" = "0",
  "1～4" = "1-4",
  "5～9" = "5-9",
  "10～14" = "10-14",
  "15～19" = "15-19",
  "20～24" = "20-24",
  "25～29" = "25-29",
  "30～34" = "30-34",
  "35～39" = "35-39",
  "40～44" = "40-44",
  "45～49" = "45-49",
  "50～54" = "50-54",
  "55～59" = "55-59",
  "60～64" = "60-64",
  "65～69" = "65-69",
  "70～74" = "70-74",
  "75～79" = "75-79",
  "80～84" = "80-84",
  "85～89" = "85-89",
  "90～94" = "90-94",
  "95～99" = "95-99",
  "100歳以上" = "100+"
)

japan <- read_rds(.japan) |>
  filter(
    sex %in% sexes,
    age %in% names(japan_ages),
    year_min <= year,
    year <= year_max
  ) |>
  keep_sex_age(japan_ages) |>
  select(country, year, sex, age, count)

korea_ages <- c(
  "0" = "0",
  "1-9" = "1-9",
  "10-19" = "10-19",
  "20-29" = "20-29",
  "30-39" = "30-39",
  "40-49" = "40-49",
  "50-59" = "50-59",
  "60-69" = "60-69",
  "70-79" = "70-79",
  "80+" = "80+"
)

korea <- read_rds(.korea) |>
  filter(
    sex %in% sexes,
    age %in% names(korea_ages),
    year_min <= year,
    year <= year_max
  ) |>
  keep_sex_age(korea_ages) |>
  select(country, year, sex, age, count)

# 表2(1) counts every infant death. 表2 omits births under 22 weeks or 500g.
# 表3–表7 continue that all-cause split. Later sheets repeat overlapping
# child ages, and 表1 is the all-age total.
taiwan_sheets <- c(
  "表2(1)" = "0",
  "表3" = "1-14",
  "表4" = "15-24",
  "表5" = "25-44",
  "表6" = "45-64",
  "表7" = "65+"
)

taiwan <- read_rds(.taiwan) |>
  filter(sex %in% sexes, sheet %in% names(taiwan_sheets)) |>
  mutate(age = unname(taiwan_sheets[sheet])) |>
  filter(year_min <= year, year <= year_max) |>
  mutate(age = factor(age, levels = unname(taiwan_sheets))) |>
  select(country, year, sex, age, count)

study <- read_rds(.countries) |>
  distinct(country = target)

out <- bind_rows(canada, hong_kong, ireland, japan, korea, taiwan) |>
  inner_join(study, by = "country") |>
  mutate(age = as.character(age)) |>
  arrange(country, year, sex, age)

if (anyNA(out$count)) {
  stop("NSO deaths include a missing count", call. = FALSE)
}

if (anyDuplicated(out[c("country", "year", "sex", "age")]) > 0L) {
  stop("NSO deaths have duplicate country-year-sex-age rows", call. = FALSE)
}

if (nrow(out) == 0L) {
  stop("NSO deaths are empty after the study-country and year filters", call. = FALSE)
}

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
