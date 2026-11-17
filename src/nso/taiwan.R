command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
  library(readxl)
})

cmd_assign(
  .deaths = "data/nso/114%e5%b9%b4%e5%b9%b4%e9%bd%a1%e5%88%a5%e7%b5%b1%e8%a8%881150622.xlsx",
  .out = "out/nso/taiwan.rds"
)

# Each leading-cause sheet starts with an all-cause row, three times:
# total, male, female. Later county sheets are not all-cause age tables.
read_sheet <- function(sheet) {
  grid <- as.matrix(
    read_excel(
      .deaths,
      sheet = sheet,
      col_names = FALSE,
      .name_repair = "unique_quiet"
    ) |>
      mutate(across(everything(), as.character))
  )
  idx <- which(grepl("所有死亡原因", grid))
  if (length(idx) == 0L) {
    return(NULL)
  }
  hits <- arrayInd(idx, dim(grid))
  colnames(hits) <- c("row", "col")
  hits <- hits[order(hits[, "col"]), , drop = FALSE]
  if (nrow(hits) != 3L) {
    stop(
      "Expected 3 all-cause cells on sheet ",
      sheet,
      ", found ",
      nrow(hits),
      call. = FALSE
    )
  }

  title <- grid[, 1]
  title <- title[!is.na(title) & nzchar(title)][1]

  data.frame(
    country = "TWN",
    year = 2025L,
    sheet = sheet,
    age = title,
    sex = c("Total", "Male", "Female"),
    count = as.numeric(grid[cbind(hits[, "row"], hits[, "col"] + 1L)]),
    stringsAsFactors = FALSE
  )
}

# Leading-cause sheets 表1–表12 (including 表2(1)). Later sheets are
# county tables of unnatural deaths and are left for a later extract.
sheets <- excel_sheets(.deaths)
sheets <- sheets[grepl("^表([1-9]|1[0-2])(\\([0-9]+\\))?$", sheets)]

out <- lapply(sheets, read_sheet) |>
  bind_rows() |>
  arrange(.data$sheet, .data$sex)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
