command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .population = "out/intermediate/population.rds",
  .out = "out/intermediate/exposure.rds"
)

out <- read_rds(.population) |>
  group_by(country, sex, age) |>
  arrange(year, .by_group = TRUE) |>
  mutate(
    year_next = lead(year),
    source_next = lead(source),
    population_next = lead(population),
    exposure = if_else(
      year_next == year + 1L,
      0.5 * (population + population_next),
      NA_real_
    ),
    population_source = case_when(
      source == "hmd" & source_next == "hmd" ~ "hmd",
      source == "wpp" & source_next == "wpp" ~ "wpp",
      !is.na(source) & !is.na(source_next) & source != source_next ~ "mixed",
      TRUE ~ NA_character_
    )
  ) |>
  filter(!is.na(year_next), year_next == year + 1L) |>
  ungroup() |>
  select(
    country,
    year,
    sex,
    age,
    exposure,
    population_source
  ) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
