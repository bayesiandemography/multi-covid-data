command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .e0_per = "data/precovid/e0_per.zip",
  .out = "out/precovid/e0_per_raw.rds"
)

tmpdir <- tempfile("e0_per")
dir.create(tmpdir)
on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

unzip(.e0_per, files = "e0_per/E0per/E0per.txt", exdir = tmpdir)

out <- read_table(
  file.path(tmpdir, "e0_per/E0per/E0per.txt"),
  skip = 2,
  na = ".",
  col_types = cols(
    PopName = col_character(),
    Year = col_integer(),
    Female = col_double(),
    Male = col_double(),
    Total = col_double()
  )
) |>
  select(
    country = PopName,
    year = Year,
    Female,
    Male
  ) |>
  pivot_longer(
    cols = c(Female, Male),
    names_to = "sex",
    values_to = "value"
  ) |>
  select(country, year, sex, value)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
