command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .deaths_raw = "out/hmd/deaths_raw.rds",
  .countries = "data/hmd/countries.csv",
  .out = "out/hmd/countries.rds",
  year_required = 2019L
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
    "data/hmd/countries.csv is missing column(s): ",
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
    "data/hmd/countries.csv has no data rows; add source/target rules",
    call. = FALSE
  )
}

if (any(is.na(map$source))) {
  stop(
    "data/hmd/countries.csv has missing source values",
    call. = FALSE
  )
}

if (anyDuplicated(map$source) > 0L) {
  stop(
    "data/hmd/countries.csv has duplicate source code(s): ",
    paste(unique(map$source[duplicated(map$source)]), collapse = ", "),
    call. = FALSE
  )
}

deaths <- read_rds(.deaths_raw)

unknown_source <- setdiff(map$source, unique(deaths$country))
if (length(unknown_source) > 0L) {
  stop(
    "data/hmd/countries.csv source code(s) not in deaths_raw: ",
    paste(unknown_source, collapse = ", "),
    call. = FALSE
  )
}

# Empty target means drop; keep/rename/merge are inferred from non-null targets.
kept <- map |>
  filter(!is.na(target))

if (nrow(kept) == 0L) {
  stop(
    "data/hmd/countries.csv has no non-empty targets; nothing to keep",
    call. = FALSE
  )
}

study_targets <- deaths |>
  semi_join(kept, by = c("country" = "source")) |>
  left_join(kept, by = c("country" = "source")) |>
  group_by(target) |>
  summarise(year_last = max(year), .groups = "drop") |>
  filter(year_last >= year_required) |>
  pull(target)

if (length(study_targets) == 0L) {
  stop(
    "no countries remain after applying countries.csv and year_required=",
    year_required,
    call. = FALSE
  )
}

# Filtered source → target map for study countries (used by deaths/population/e0).
out <- kept |>
  filter(target %in% study_targets) |>
  arrange(source)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
