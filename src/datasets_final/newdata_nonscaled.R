command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .exposure = "out/shared/exposure.rds",
  .out = "out/datasets_final/newdata_nonscaled.csv"
)

out <- read_rds(.exposure) |>
  filter(year >= 2020L) |>
  select(country, year, sex, age, exposure_nonscaled) |>
  mutate(age = as.character(age)) |>
  rename(exposure = exposure_nonscaled) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_csv(out, file = .out)
