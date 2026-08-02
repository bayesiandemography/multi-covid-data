command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(purrr)
})

cmd_assign(
  .countries = "data/stmf/countries.csv",
  .deaths = "data/stmf/STMFinput-2.zip",
  .out = "out/stmf/countries.rds",
  year_required = 2025L,
  week_required = 52L
)

map <- read_csv(
  .countries,
  col_types = cols(
    source = col_character(),
    target = col_character()
  )
)

required_cols <- c("source", "target")
missing_cols <- setdiff(required_cols, names(map))
if (length(missing_cols) > 0L) {
  stop(
    "data/stmf/countries.csv is missing column(s): ",
    paste(missing_cols, collapse = ", "),
    call. = FALSE
  )
}

map <- map |>
  select(all_of(required_cols)) |>
  mutate(
    across(everything(), \(x) na_if(trimws(as.character(x)), ""))
  )

if (nrow(map) == 0L) {
  stop(
    "data/stmf/countries.csv has no data rows; add source/target rules",
    call. = FALSE
  )
}

if (any(is.na(map$source))) {
  stop(
    "data/stmf/countries.csv has missing source values",
    call. = FALSE
  )
}

if (anyDuplicated(map$source) > 0L) {
  stop(
    "data/stmf/countries.csv has duplicate source code(s): ",
    paste(unique(map$source[duplicated(map$source)]), collapse = ", "),
    call. = FALSE
  )
}

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

read_weeks <- function(path) {
  # Columns: PopCode, Area, Year, Week, ... (BOM on PopCode).
  # Select by position to avoid parsing Deaths and other unused fields.
  raw <- read_csv(
    path,
    col_select = c(1L, 3L, 4L),
    show_col_types = FALSE,
    progress = FALSE
  )
  names(raw) <- c("country", "year", "week")
  transmute(
    raw,
    country = as.character(country),
    year = as.integer(year),
    week = as.integer(week)
  )
}

weeks <- files |>
  map(read_weeks) |>
  list_rbind()

missing_from_zip <- setdiff(map$source, unique(weeks$country))
if (length(missing_from_zip) > 0L) {
  stop(
    "data/stmf/countries.csv source code(s) not in STMF zip: ",
    paste(missing_from_zip, collapse = ", "),
    call. = FALSE
  )
}

covered_sources <- weeks |>
  filter(year == year_required, !is.na(week)) |>
  group_by(country) |>
  summarise(week_last = max(week), .groups = "drop") |>
  filter(week_last >= week_required) |>
  pull(country)

# Empty target means drop; keep/rename/merge are inferred from non-null targets.
kept <- map |>
  filter(!is.na(target), source %in% covered_sources)

if (nrow(kept) == 0L) {
  stop(
    "no countries remain after applying countries.csv and year_required=",
    year_required,
    " week_required=",
    week_required,
    call. = FALSE
  )
}

out <- kept |>
  arrange(source)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
