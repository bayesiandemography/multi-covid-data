command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(readxl)
})

cmd_assign(
  .deaths = "data/nso/R7toukeihyou.xlsx",
  .out = "out/nso/japan.rds"
)

# Table 7 is deaths and death rates by sex, five-year age, and ranked cause.
# This extract keeps the all-cause total (column C). The total row includes
# deaths of unknown age.
sheets <- c(
  "第7表-1" = "Total",
  "第7表-2" = "Male",
  "第7表-3" = "Female"
)

clean_age <- function(age) {
  age <- gsub("[[:space:]]+", "", age)
  gsub("[0-9]+\\)$", "", age)
}

read_sheet <- function(sheet, sex) {
  read_excel(
    .deaths,
    sheet = sheet,
    range = "B5:C27",
    col_names = c("age", "count"),
    col_types = c("text", "numeric")
  ) |>
    transmute(
      country = "JPN",
      year = 2025L,
      sex = sex,
      age = clean_age(age),
      count = count,
      row = row_number()
    )
}

out <- Map(read_sheet, names(sheets), unname(sheets)) |>
  bind_rows() |>
  arrange(match(sex, c("Total", "Male", "Female")), row) |>
  select(country, year, sex, age, count)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
