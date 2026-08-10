command::use_renv()

suppressPackageStartupMessages({
  library(agetime)
  library(command)
  library(dplyr)
  library(purrr)
  library(readr)
})

cmd_assign(
  .hmd_deaths = "out/hmd/deaths.rds",
  .stmf_deaths = "out/stmf/deaths.rds",
  year_min = 1970L,
  year_max = 2025L,
  .out = "out/figures/vals_deaths.rds"
)

hmd <- read_rds(.hmd_deaths) |>
  filter(!is.na(year), year_min <= year, year <= year_max) |>
  mutate(age = as.character(age)) |>
  select(country, year, sex, age, count_hmd = count)

stmf <- read_rds(.stmf_deaths) |>
  filter(year_min <= year, year <= year_max) |>
  mutate(age = as.character(age)) |>
  select(country, year, sex, age, count_stmf = count)

# Coarsen HMD life-table ages into each country's STMF age bands.
# When STMF includes both fine and aggregated ages, the same HMD counts
# are mapped into every containing band.
hmd_to_stmf <- function(country_i) {
  stmf_ages <- stmf |>
    filter(country == country_i) |>
    pull(age) |>
    unique()
  hmd_ages <- hmd |>
    filter(country == country_i) |>
    pull(age) |>
    unique()
  if (length(hmd_ages) == 0L || length(stmf_ages) == 0L) {
    return(NULL)
  }

  mapping <- age_mapping(
    labels_x = hmd_ages,
    labels_y = stmf_ages,
    relation = "is-contained-in",
    interpret_fail = "silent"
  ) |>
    filter(!is.na(x), !is.na(y))

  if (nrow(mapping) == 0L) {
    return(NULL)
  }

  hmd |>
    filter(country == country_i) |>
    inner_join(mapping, by = c("age" = "x"), relationship = "many-to-many") |>
    group_by(country, year, sex, age = y) |>
    summarise(count_hmd = sum(count_hmd, na.rm = TRUE), .groups = "drop")
}

hmd_matched <- unique(stmf$country) |>
  map(hmd_to_stmf) |>
  list_rbind()

out <- full_join(
  hmd_matched,
  stmf,
  by = c("country", "year", "sex", "age")
) |>
  mutate(age = age_set_order(age, interpret_fail = "silent")) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
