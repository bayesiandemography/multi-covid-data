command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .deaths = "out/shared/deaths.rds",
  .exposure = "out/shared/exposure.rds",
  .out = "out/datasets_final/data_fit.rds"
)

out <- read_rds(.deaths) |>
  filter(year < 2020L) |>
  select(country, year, sex, age, deaths) |>
  inner_join(
    read_rds(.exposure) |>
      select(country, year, sex, age, exposure_nonscaled),
    by = c("country", "year", "sex", "age")
  ) |>
  mutate(deaths = round(deaths)) |>
  rename(exposure = exposure_nonscaled) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
