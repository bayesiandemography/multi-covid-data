command::use_renv()

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(readr))

raw_dir <- "hmd_countries_20260615"
data_dir <- file.path("..", "data")

exposures_out <- file.path(data_dir, "exposures.csv")

dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

exposures_src <- list.files(
  raw_dir,
  pattern = "^Exposures_5x1\\.txt$",
  recursive = TRUE,
  full.names = TRUE
) |>
  sort()

read_exposures <- function(exposures_src) {
  country <- basename(dirname(dirname(exposures_src)))

  read_table(
    exposures_src,
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

exposures <- exposures_src |>
  lapply(read_exposures) |>
  bind_rows()

write_csv(exposures, exposures_out)
