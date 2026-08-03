command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .deaths = "out/shared/deaths.rds",
  .out = "out/datasets_final/deaths_observed.rds"
)

out <- read_rds(.deaths) |>
  filter(year >= 2020L) |>
  select(country, year, sex, age, deaths) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
