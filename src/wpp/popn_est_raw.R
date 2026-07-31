command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .population = "data/wpp/WPP2024_Population1JanuaryBySingleAgeSex_Medium_1950-2023.gz",
  year_min = 2015L,
  .out = "out/wpp/popn_est_raw.rds"
)

out <- read_csv(
  .population,
  col_select = c(ISO3_code, Time, AgeGrp, PopMale, PopFemale),
  col_types = cols(
    ISO3_code = col_character(),
    Time = col_integer(),
    AgeGrp = col_character(),
    PopMale = col_double(),
    PopFemale = col_double()
  ),
  show_col_types = FALSE
) |>
  filter(
    !is.na(ISO3_code),
    ISO3_code != "",
    Time >= year_min
  ) |>
  select(
    country = ISO3_code,
    year = Time,
    age = AgeGrp,
    Male = PopMale,
    Female = PopFemale
  ) |>
  pivot_longer(
    cols = c(Female, Male),
    names_to = "sex",
    values_to = "count"
  ) |>
  select(country, year, sex, age, count)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
