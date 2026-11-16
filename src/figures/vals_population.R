command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .population = "out/population.rds",
  .out = "out/figures/vals_population.rds"
)

out <- read_rds(.population) |>
  select(
    country,
    year,
    sex,
    age,
    count_hmd,
    count_wpp
  ) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
