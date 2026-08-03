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

drop_containing_parents <- function(labels, lo, hi) {
  keep <- rep(TRUE, length(labels))
  for (i in seq_along(labels)) {
    for (j in seq_along(labels)) {
      if (i == j) {
        next
      }
      child <- lo[j] >= lo[i] &&
        hi[j] <= hi[i] &&
        (lo[j] > lo[i] || hi[j] < hi[i])
      if (child) {
        keep[i] <- FALSE
        break
      }
    }
  }
  keep
}

# Prefer the most detailed STMF age set that still forms a complete
# partition ending in an open age group (highest open lower bound first).
finest_stmf_ages <- function(labels) {
  labels <- unique(as.character(labels))
  labels <- labels[!is.na(labels) & nzchar(labels) & !grepl("^UNK", labels)]
  lo <- as.numeric(age_lower(labels, interpret_fail = "silent"))
  hi <- as.numeric(age_upper(labels, interpret_fail = "silent"))
  ok <- !is.na(lo) & !is.na(hi)
  labels <- labels[ok]
  lo <- lo[ok]
  hi <- hi[ok]
  open <- is.infinite(hi)
  if (!any(open)) {
    stop(
      "no open-right age group in STMF labels: ",
      paste(labels, collapse = ", "),
      call. = FALSE
    )
  }

  open_idx <- which(open)
  open_order <- open_idx[order(lo[open_idx], decreasing = TRUE)]
  closed_idx <- which(!open)
  if (length(closed_idx) > 0L) {
    ck <- drop_containing_parents(
      labels[closed_idx],
      lo[closed_idx],
      hi[closed_idx]
    )
    closed_idx <- closed_idx[ck]
  }

  for (oi in open_order) {
    L <- lo[oi]
    below <- closed_idx[hi[closed_idx] <= L]
    cand_lab <- c(labels[below], labels[oi])
    cand_lo <- c(lo[below], lo[oi])
    cand_hi <- c(hi[below], hi[oi])
    keep <- drop_containing_parents(cand_lab, cand_lo, cand_hi)
    keep[length(keep)] <- TRUE
    cand_lab <- cand_lab[keep]
    diag <- age_diagnose(
      cand_lab,
      has_zero = TRUE,
      has_open_right = TRUE,
      no_gap = TRUE,
      no_overlap = TRUE,
      interpret_fail = "silent"
    )
    if (isTRUE(diag$ok)) {
      return(age_set_order(cand_lab, interpret_fail = "silent"))
    }
  }

  stop(
    "no complete finest STMF age classification among: ",
    paste(labels, collapse = ", "),
    call. = FALSE
  )
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
          finest_stmf_ages(
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
