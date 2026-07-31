command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(purrr)
})

cmd_assign(
  .deaths = "data/stmf/STMFinput-2.zip",
  .out = "out/stmf/deaths_raw.rds"
)

tmpdir <- tempfile("stmf")
dir.create(tmpdir)
on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

unzip(.deaths, exdir = tmpdir)

files <- list.files(
  file.path(tmpdir, "STMFinput-2"),
  pattern = "stmf\\.csv$",
  full.names = TRUE
) |>
  sort()

age_label <- function(age, interval) {
  case_when(
    interval == "+" ~ paste0(age, "+"),
    interval == "1" ~ age,
    TRUE ~ paste0(age, "-", as.integer(age) + as.integer(interval) - 1L)
  )
}

read_stmf <- function(path) {
  read_csv(path, show_col_types = FALSE) |>
    rename_with(~ sub("^\ufeff", "", .x)) |>
    filter(Sex %in% c("m", "f"), Age != "TOT") |>
    transmute(
      country = PopCode,
      year = as.integer(Year),
      week = as.integer(Week),
      sex = if_else(Sex == "m", "Male", "Female"),
      age = age_label(Age, AgeInterval),
      count = as.numeric(Deaths)
    )
}

out <- files |>
  map(read_stmf) |>
  list_rbind() |>
  group_by(country, year, sex, age) |>
  summarise(count = sum(count, na.rm = TRUE), .groups = "drop") |>
  select(country, year, sex, age, count)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
