command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .population = "out/shared/population.rds",
  .out = "out/figures/vals_population.rds"
)

out <- read_rds(.population) |>
  select(
    country,
    year,
    sex,
    age,
    count_hmd,
    count_wpp,
    count_wpp_scaled,
    population_nonscaled,
    population_scaled,
    source_nonscaled,
    source_scaled
  ) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
