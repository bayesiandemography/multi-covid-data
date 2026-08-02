command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(agetime)
})

cmd_assign(
  .popn_est_raw = "out/wpp/popn_est_raw.rds",
  .popn_proj_raw = "out/wpp/popn_proj_raw.rds",
  .out = "out/wpp/population.rds"
)

out <- bind_rows(
  read_rds(.popn_est_raw),
  read_rds(.popn_proj_raw)
) |>
  mutate(
    age = age_set_open_right(age, at = 100L),
    age = age_coarsen_life(age)
  ) |>
  group_by(country, year, sex, age) |>
  summarise(count = sum(count, na.rm = TRUE), .groups = "drop") |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
