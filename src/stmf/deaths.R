command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .deaths_raw = "out/stmf/deaths_raw.rds",
  .countries = "out/stmf/countries.rds",
  .out = "out/stmf/deaths.rds",
  year_min = 2020L,
  year_max = 2025L
)

countries <- read_rds(.countries)

out <- read_rds(.deaths_raw) |>
  inner_join(countries, by = c("country" = "source")) |>
  filter(year_min <= year, year <= year_max) |>
  group_by(country = target, year, sex, age) |>
  summarise(count = sum(count, na.rm = TRUE), .groups = "drop") |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
