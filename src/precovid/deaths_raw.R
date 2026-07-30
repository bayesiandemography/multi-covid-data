command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .deaths = "data/precovid/deaths.zip",
  .out = "out/precovid/deaths_raw.rds"
)

tmpdir <- tempfile("deaths")
dir.create(tmpdir)
on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

unzip(.deaths, files = "deaths/Deaths_5x1/Deaths_5x1.txt", exdir = tmpdir)

out <- read_table(
  file.path(tmpdir, "deaths/Deaths_5x1/Deaths_5x1.txt"),
  skip = 2,
  na = ".",
  col_types = cols(
    PopName = col_character(),
    Year = col_integer(),
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
