command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .hmd_population = "out/hmd/population.rds",
  .wpp_population = "out/wpp/population.rds",
  year_min = 1970L,
  year_max = 2026L,
  .out = "out/population.rds"
)

hmd_raw <- read_rds(.hmd_population)
age_levels <- levels(hmd_raw$age)

hmd <- hmd_raw |>
  filter(grepl("^[0-9]+$", year)) |>
  mutate(
    year = as.integer(year),
    age = as.character(age)
  ) |>
  filter(year_min <= year, year <= year_max) |>
  select(country, year, sex, age, count_hmd = count)

study_countries <- unique(hmd$country)

# WPP Population1January files store counts in thousands.
wpp <- read_rds(.wpp_population) |>
  mutate(age = as.character(age)) |>
  filter(
    country %in% study_countries,
    year_min <= year,
    year <= year_max
  ) |>
  transmute(
    country,
    year,
    sex,
    age,
    count_wpp = count * 1000
  )

joined <- full_join(
  hmd,
  wpp,
  by = c("country", "year", "sex", "age")
) |>
  mutate(age = factor(age, levels = age_levels))

scale_factors <- joined |>
  filter(!is.na(count_hmd)) |>
  group_by(country, sex, age) |>
  slice_max(year, n = 1L, with_ties = FALSE) |>
  ungroup() |>
  transmute(
    country,
    sex,
    age,
    scale = if_else(
      !is.na(count_wpp) & count_wpp > 0,
      count_hmd / count_wpp,
      NA_real_
    )
  )

out <- joined |>
  left_join(scale_factors, by = c("country", "sex", "age")) |>
  mutate(
    count_wpp_scaled = if_else(!is.na(scale), count_wpp * scale, NA_real_),
    population = coalesce(count_hmd, count_wpp_scaled),
    source = case_when(
      !is.na(count_hmd) ~ "hmd",
      !is.na(count_wpp_scaled) ~ "wpp",
      TRUE ~ NA_character_
    )
  ) |>
  select(
    country,
    year,
    sex,
    age,
    count_hmd,
    count_wpp,
    population,
    source
  ) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
