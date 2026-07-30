command::use_renv()

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(command))

cmd_assign()

raw_dir <- "hmd_countries_20260615"
data_dir <- file.path("..", "data")

deaths_out <- file.path(data_dir, "deaths.csv")

dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

deaths_src <- list.files(
  raw_dir,
  pattern = "^Deaths_5x1\\.txt$",
  recursive = TRUE,
  full.names = TRUE
) |>
  sort()

read_deaths <- function(deaths_src) {
  country <- basename(dirname(dirname(deaths_src)))

  read_table(
    deaths_src,
    skip = 2,
    na = ".",
    col_types = cols(
      Year = col_integer(),
      Age = col_character(),
      Female = col_double(),
      Male = col_double(),
      Total = col_double()
    )
  ) |>
    mutate(country = country, .before = "Year")
}

deaths <- deaths_src |>
  lapply(read_deaths) |>
  bind_rows()

write_csv(deaths, deaths_out)
