command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(readxl)
})

cmd_assign(
  .deaths = "data/nso/p-1.xlsx",
  .out = "out/nso/israel.rds"
)

# Daily deaths of Israeli residents occurring in Israel.
# Sex and population group are published for all ages. Age is published
# for both sexes together. Totals include unknown sex, population group,
# and age, so the parts need not sum to the total. 2025 is not final.
years <- 2017:2025

age_labels <- c(
  "0-19", "20-24", "25-29", "30-34", "35-39", "40-44",
  "45-49", "50-54", "55-59", "60-64", "65-69", "70-74",
  "75-79", "80-84", "85-89", "90+"
)

# Sheet columns after the date: all-age total, Jews and Others, and Arabs,
# each as total / male / female, then the both-sex age groups.
sex_cols <- data.frame(
  col = 2:10,
  population_group = rep(c("Total", "Jews and Others", "Arabs"), each = 3L),
  sex = rep(c("Total", "Male", "Female"), 3L)
)

read_year <- function(year) {
  raw <- read_excel(
    .deaths,
    sheet = as.character(year),
    col_names = FALSE,
    .name_repair = "unique_quiet"
  )
  age_row <- which(as.character(raw[[11]]) == "0-19")
  if (length(age_row) != 1L) {
    stop("Age header not found for ", year, call. = FALSE)
  }
  found_ages <- as.character(unlist(raw[age_row, 11:26]))
  if (!identical(found_ages, age_labels)) {
    stop("Unexpected age labels for ", year, call. = FALSE)
  }
  sex_header <- as.character(unlist(raw[age_row + 1L, c(3, 4, 6, 7, 9, 10)]))
  if (!identical(sex_header, rep(c("Male", "Female"), 3L))) {
    stop("Unexpected sex header for ", year, call. = FALSE)
  }

  body <- raw[(age_row + 2L):nrow(raw), , drop = FALSE]
  serial <- suppressWarnings(as.numeric(body[[1]]))
  body <- body[!is.na(serial), , drop = FALSE]
  serial <- serial[!is.na(serial)]
  date <- as.Date(serial, origin = "1899-12-30")
  if (any(as.integer(format(date, "%Y")) != year)) {
    stop("Date outside ", year, call. = FALSE)
  }
  n_days <- as.integer(as.Date(paste0(year, "-12-31")) - as.Date(paste0(year, "-01-01"))) + 1L
  if (length(date) != n_days) {
    stop("Expected ", n_days, " days for ", year, ", found ", length(date), call. = FALSE)
  }

  counts <- lapply(body[2:26], function(x) suppressWarnings(as.numeric(x)))
  if (any(vapply(counts, anyNA, logical(1)))) {
    stop("Missing death count for ", year, call. = FALSE)
  }

  sex_rows <- lapply(seq_len(nrow(sex_cols)), function(i) {
    tibble(
      date = date,
      population_group = sex_cols$population_group[[i]],
      sex = sex_cols$sex[[i]],
      age = "Total",
      count = counts[[sex_cols$col[[i]] - 1L]]
    )
  }) |>
    bind_rows()

  age_rows <- lapply(seq_along(age_labels), function(i) {
    tibble(
      date = date,
      population_group = "Total",
      sex = "Total",
      age = age_labels[[i]],
      count = counts[[9L + i]]
    )
  }) |>
    bind_rows()

  bind_rows(sex_rows, age_rows) |>
    mutate(country = "ISR", year = as.integer(year), .before = 1)
}

out <- lapply(years, read_year) |>
  bind_rows() |>
  arrange(
    date,
    match(population_group, c("Total", "Jews and Others", "Arabs")),
    match(sex, c("Total", "Male", "Female")),
    match(age, c("Total", age_labels))
  )

if (sum(out$count[out$year == 2017L & out$population_group == "Total" & out$sex == "Total" & out$age == "Total"]) != 44596) {
  stop("2017 all-age total is not 44,596", call. = FALSE)
}

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
