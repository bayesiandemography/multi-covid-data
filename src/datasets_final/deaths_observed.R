command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .deaths = "out/shared/deaths.rds",
  .out = "out/datasets_final/deaths_observed.zip"
)

out <- read_rds(.deaths) |>
  filter(year >= 2020L) |>
  select(country, year, sex, age, deaths) |>
  mutate(age = as.character(age)) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
csv_path <- file.path(tempdir(), sub("\\.zip$", ".csv", basename(.out)))
write_csv(out, csv_path)
unlink(.out)
if (utils::zip(.out, csv_path, flags = "-j") != 0L) {
  stop("zip failed: ", .out, call. = FALSE)
}
unlink(csv_path)
