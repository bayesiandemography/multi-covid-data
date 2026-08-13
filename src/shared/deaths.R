command::use_renv()

suppressPackageStartupMessages({
  library(agetime)
  library(command)
  library(dplyr)
  library(purrr)
  library(readr)
})

cmd_assign(
  .hmd_deaths = "out/hmd/deaths.rds",
  .stmf_deaths = "out/stmf/deaths.rds",
  year_min = 1970L,
  year_max = 2025L,
  .out = "out/shared/deaths.rds"
)

# Drop closed ages that overlap an open-right age (e.g. 95-99 with 95+).
# age_is_subtotal() only removes groups fully covered by others; an open
# group is not a subtotal unless finer ages cover its whole range.
drop_closed_overlapping_open <- function(labels) {
  labels <- unique(as.character(labels))
  open <- labels[age_is_open_right(labels, interpret_fail = "silent")]
  closed <- setdiff(labels, open)
  if (length(open) == 0L || length(closed) == 0L) {
    return(labels)
  }

  overlap <- age_mapping(
    labels_x = closed,
    labels_y = open,
    relation = "overlaps-with",
    interpret_fail = "silent"
  ) |>
    filter(!is.na(x), !is.na(y), x != y)

  setdiff(labels, unique(overlap$x))
}

stmf_age_levels <- function(labels) {
  labels <- unique(as.character(labels))
  labels <- labels[
    !is.na(labels) &
      nzchar(labels) &
      !age_is_missing(labels, interpret_fail = "silent") &
      !age_is_total(labels, interpret_fail = "silent")
  ]

  keep <- labels[
    !age_is_subtotal(labels, interpret_fail = "silent")
  ]
  keep <- drop_closed_overlapping_open(keep)

  age_set_order(keep, interpret_fail = "silent")
}

assert_stmf_ages <- function(labels, country, year, sex) {
  tryCatch(
    age_assert(
      labels,
      has_zero = TRUE,
      has_open_right = TRUE,
      no_gap = TRUE,
      no_overlap = TRUE
    ),
    error = function(e) {
      stop(
        "STMF age coverage failed for country=",
        country,
        " year=",
        year,
        " sex=",
        sex,
        ": ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )
  invisible(labels)
}

hmd_raw <- read_rds(.hmd_deaths)
hmd_age_levels <- levels(hmd_raw$age)

hmd_out <- hmd_raw |>
  filter(year_min <= year, year <= year_max) |>
  transmute(
    country,
    year,
    sex,
    age = factor(as.character(age), levels = hmd_age_levels),
    deaths = count,
    source = "hmd"
  )

stmf <- read_rds(.stmf_deaths) |>
  filter(year_min <= year, year <= year_max) |>
  transmute(
    country,
    year,
    sex,
    age = as.character(age),
    deaths = count
  )

stmf_fill_years <- stmf |>
  distinct(country, year) |>
  anti_join(
    hmd_out |> distinct(country, year),
    by = c("country", "year")
  )

stmf_out <- stmf_fill_years |>
  mutate(
    age_levels = map2(
      country,
      year,
      \(country_i, year_i) {
        as.character(
          stmf_age_levels(
            stmf$age[stmf$country == country_i & stmf$year == year_i]
          )
        )
      }
    )
  ) |>
  mutate(
    rows = pmap(
      list(country, year, age_levels),
      \(country_i, year_i, levels_i) {
        sexes <- stmf |>
          filter(country == country_i, year == year_i) |>
          distinct(sex) |>
          pull(sex)
        walk(
          sexes,
          \(sex_i) assert_stmf_ages(levels_i, country_i, year_i, sex_i)
        )
        stmf |>
          filter(
            country == country_i,
            year == year_i,
            age %in% levels_i
          ) |>
          mutate(
            age = factor(age, levels = levels_i),
            source = "stmf"
          )
      }
    )
  ) |>
  pull(rows) |>
  list_rbind()

out <- bind_rows(hmd_out, stmf_out) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
