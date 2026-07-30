command::use_renv()

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(readr))

raw_dir <- "hmd_countries_20260615"
data_dir <- file.path("..", "data")

e0per_out <- file.path(data_dir, "e0per.csv")

dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

e0per_src <- list.files(
  raw_dir,
  pattern = "^E0per\\.txt$",
  recursive = TRUE,
  full.names = TRUE
) |>
  sort()

read_e0per <- function(e0per_src) {
  country <- basename(dirname(dirname(e0per_src)))

  read_table(
    e0per_src,
    skip = 2,
    na = ".",
    col_types = cols(
      Year = col_integer(),
      Female = col_double(),
      Male = col_double(),
      Total = col_double()
    )
  ) |>
    mutate(country = country, .before = "Year")
}

e0per <- e0per_src |>
  lapply(read_e0per) |>
  bind_rows()

write_csv(e0per, e0per_out)
