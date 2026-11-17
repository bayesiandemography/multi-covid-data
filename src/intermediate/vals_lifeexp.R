command::use_renv()

suppressPackageStartupMessages({
  library(agetime)
  library(command)
  library(dplyr)
  library(poputils)
  library(purrr)
  library(readr)
})

cmd_assign(
  .data = "out/data.csv.zip",
  .lifeexp = "out/hmd/lifeexp.rds",
  .out = "out/intermediate/vals_lifeexp.rds"
)

# 0 and 1-4 are separate, other closed groups are five years wide,
# and the open group starts at 80 or older.
eligible_ages <- function(labels) {
  labels <- unique(as.character(labels))
  if (length(labels) == 0L || anyNA(labels) || any(!nzchar(labels))) {
    return(FALSE)
  }
  ok <- tryCatch(
    {
      age_assert(
        labels,
        has_zero = TRUE,
        has_open_right = TRUE,
        no_gap = TRUE,
        no_overlap = TRUE
      )
      TRUE
    },
    error = function(e) FALSE
  )
  if (!ok || !all(c("0", "1-4") %in% labels)) {
    return(FALSE)
  }

  lower <- age_lower(labels)
  width <- age_width(labels)
  open <- age_is_open_right(labels)
  if (sum(open) != 1L || lower[open] < 80) {
    return(FALSE)
  }
  closed <- !open
  if (any(width[labels == "0"] != 1) || any(width[labels == "1-4"] != 4)) {
    return(FALSE)
  }
  other <- closed & !(labels %in% c("0", "1-4"))
  !any(width[other] != 5)
}

raw <- read_csv(.data, show_col_types = FALSE) |>
  filter(!is.na(deaths), !is.na(exposure), exposure > 0) |>
  mutate(
    age = as.character(age),
    mx = deaths / exposure
  ) |>
  filter(is.finite(mx))

keep <- raw |>
  group_by(country, year, sex) |>
  summarise(labels = list(age), .groups = "drop") |>
  mutate(keep = map_lgl(labels, eligible_ages)) |>
  filter(keep) |>
  select(country, year, sex)

rates <- raw |>
  semi_join(keep, by = c("country", "year", "sex"))

# AK is the infant method used by the Human Mortality Database.
calculated <- lifeexp(
  rates,
  mx = mx,
  age = age,
  sex = sex,
  by = c(country, year),
  infant = "AK"
)

out <- calculated |>
  inner_join(read_rds(.lifeexp), by = c("country", "year", "sex")) |>
  rename(ex_data = ex, ex_hmd = value) |>
  mutate(difference = ex_data - ex_hmd) |>
  arrange(country, year, sex)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
