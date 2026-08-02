command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(agetime)
})

cmd_assign(
  .deaths_raw = "out/hmd/deaths_raw.rds",
  .countries = "out/hmd/countries.rds",
  .out = "out/hmd/deaths.rds"
)

countries <- read_rds(.countries)

out <- read_rds(.deaths_raw) |>
  inner_join(countries, by = c("country" = "source")) |>
  mutate(
    age = age_set_open_right(age, at = 100L),
    age = as.ordered(age_coarsen_life(age))
  ) |>
  group_by(country = target, year, sex, age) |>
  summarise(count = sum(count, na.rm = TRUE), .groups = "drop") |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
