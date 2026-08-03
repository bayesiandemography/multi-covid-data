command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .exposure = "out/shared/exposure.rds",
  .out = "out/datasets_final/newdata_nonscaled.rds"
)

out <- read_rds(.exposure) |>
  filter(year >= 2020L) |>
  select(country, year, sex, age, exposure_nonscaled) |>
  rename(exposure = exposure_nonscaled) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
