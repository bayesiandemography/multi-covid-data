command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .lifeexp_raw = "out/hmd/lifeexp_raw.rds",
  .countries = "out/hmd/countries.rds",
  .out = "out/hmd/lifeexp.rds"
)

# Life expectancy is for validation only. Merging life expectancies (e.g. East +
# West Germany) is not valid: see Lutz, Wolfgang, and Sergei Scherbov. 1992.
# "Sensitivity of Aggregate Period Life Expectancy to Different
# Averaging Procedures." Population Bulletin of the United Nations 33: 32–46.
# So keep only targets with a single source.
countries <- read_rds(.countries) |>
  add_count(target, name = "n_source") |>
  filter(n_source == 1L) |>
  select(source, target)

out <- read_rds(.lifeexp_raw) |>
  inner_join(countries, by = c("country" = "source")) |>
  transmute(country = target, year, sex, value) |>
  arrange(country, year, sex)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
