command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .deaths = "data/precovid/deaths.zip",
  .out = "out/deaths.csv"
)

tmpdir <- tempfile("deaths")
dir.create(tmpdir)
on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

unzip(.deaths, files = "deaths/Deaths_5x1/Deaths_5x1.txt", exdir = tmpdir)

deaths <- read_table(
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
  rename(country = PopName)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_csv(deaths, .out)
