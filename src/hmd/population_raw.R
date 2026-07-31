command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .population = "data/hmd/population.zip",
  .out = "out/hmd/population_raw.rds"
)

tmpdir <- tempfile("population")
dir.create(tmpdir)
on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

unzip(.population, files = "population/Population5/Population5.txt", exdir = tmpdir)

out <- read_table(
  file.path(tmpdir, "population/Population5/Population5.txt"),
  skip = 2,
  na = ".",
  col_types = cols(
    PopName = col_character(),
    Year = col_character(),
    Age = col_character(),
    Female = col_double(),
    Male = col_double(),
    Total = col_double()
  )
) |>
  select(
    country = PopName,
    year = Year,
    age = Age,
    Female,
    Male
  ) |>
  pivot_longer(
    cols = c(Female, Male),
    names_to = "sex",
    values_to = "count"
  ) |>
  select(country, year, sex, age, count)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
