command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(pdftools)
  library(purrr)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .deaths = "data/nso/2025%EB%85%84+%EC%B6%9C%EC%83%9D.%EC%82%AC%EB%A7%9D%ED%86%B5%EA%B3%84%28%EC%9E%A0%EC%A0%95%29.pdf",
  .out = "out/nso/korea.rds"
)

# Table 12, "성·연령별 사망자 수". Counts are published in thousands of
# people. The all-age total includes deaths of unknown age.
ages <- c(
  "Total", "0", "1-9", "10-19", "20-29", "30-39",
  "40-49", "50-59", "60-69", "70-79", "80+"
)

words <- imap(pdf_data(.deaths), \(page, i) mutate(page, page = i)) |>
  list_rbind() |>
  mutate(y = round(y))

lines <- words |>
  group_by(page, y) |>
  summarise(text = paste(text, collapse = " "), .groups = "drop")

# Count tables are headed "사망자 수" and use the unit "천 명".
# The following rate tables also have an age header, but their unit
# line contains "인구".
death_pages <- lines |>
  group_by(page) |>
  summarise(blob = paste(text, collapse = " "), .groups = "drop") |>
  filter(
    grepl("연도", blob),
    grepl("80세", blob),
    grepl("천 명", blob),
    !grepl("인구", blob)
  ) |>
  arrange(page) |>
  pull(page)

if (length(death_pages) != 3L) {
  stop(
    "Expected 3 sex-by-age death pages, found ",
    length(death_pages),
    call. = FALSE
  )
}

column_centers <- function(header) {
  xs <- sort(header$x)
  cluster <- cumsum(c(0, diff(xs) > 22))
  tapply(xs, cluster, mean)
}

parse_page <- function(page, sex) {
  page_words <- words |> filter(page == .env$page)
  header_y <- page_words$y[grep("연도", page_words$text)[1]]
  centers <- column_centers(page_words |> filter(y == header_y))
  if (length(centers) != length(ages) + 1L) {
    stop(
      "Expected ",
      length(ages) + 1L,
      " columns on PDF page ",
      page,
      ", found ",
      length(centers),
      call. = FALSE
    )
  }

  cells <- page_words |>
    filter(y != header_y) |>
    mutate(column = max.col(-abs(outer(x, centers, `-`)), ties.method = "first")) |>
    filter(abs(x - centers[column]) < 28) |>
    arrange(y, column, x) |>
    group_by(y, column) |>
    summarise(text = paste(text, collapse = ""), .groups = "drop") |>
    mutate(text = gsub("[[:space:]]+", "", text)) |>
    pivot_wider(names_from = column, values_from = text)

  year_text <- cells[["1"]]
  year <- suppressWarnings(as.integer(sub("p$", "", year_text)))
  keep <- !is.na(year) & year >= 1983L & year <= 2025L
  value_cols <- as.character(seq_len(length(ages)) + 1L)

  cells |>
    filter(keep) |>
    mutate(
      year = year[keep],
      provisional = grepl("p", year_text[keep]),
      sex = sex
    ) |>
    select(year, provisional, sex, all_of(value_cols)) |>
    pivot_longer(
      all_of(value_cols),
      names_to = "column",
      values_to = "count_thousands"
    ) |>
    mutate(
      count_thousands = as.numeric(count_thousands),
      age = ages[as.integer(column) - 1L],
      age = factor(age, levels = ages)
    ) |>
    select(year, provisional, sex, age, count_thousands)
}

out <- map2(death_pages, c("Total", "Male", "Female"), parse_page) |>
  list_rbind() |>
  transmute(
    country = "KOR",
    year,
    sex,
    age,
    count_thousands,
    count = count_thousands * 1000,
    provisional
  ) |>
  arrange(year, sex, age)

total_2025 <- out |>
  filter(year == 2025L, sex == "Total", age == "Total") |>
  pull(count_thousands)

if (length(total_2025) != 1L || abs(total_2025 - 363.4) > 0.05) {
  stop("Korea 2025 all-age total was not 363.4 thousand", call. = FALSE)
}

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
