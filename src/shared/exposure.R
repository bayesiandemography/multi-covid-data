command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .population = "out/shared/population.rds",
  .out = "out/shared/exposure.rds"
)

out <- read_rds(.population) |>
  group_by(country, sex, age) |>
  arrange(year, .by_group = TRUE) |>
  mutate(
    year_next = lead(year),
    exposure_nonscaled = if_else(
      year_next == year + 1L,
      0.5 * (population_nonscaled + lead(population_nonscaled)),
      NA_real_
    ),
    exposure_scaled = if_else(
      year_next == year + 1L,
      0.5 * (population_scaled + lead(population_scaled)),
      NA_real_
    )
  ) |>
  filter(!is.na(year_next), year_next == year + 1L) |>
  ungroup() |>
  select(
    country,
    year,
    sex,
    age,
    exposure_nonscaled,
    exposure_scaled
  ) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
