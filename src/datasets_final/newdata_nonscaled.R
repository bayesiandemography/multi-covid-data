command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .exposure = "out/shared/exposure.rds",
  .out = "out/datasets_final/newdata_nonscaled.zip"
)

out <- read_rds(.exposure) |>
  filter(year >= 2020L) |>
  select(country, year, sex, age, exposure_nonscaled) |>
  mutate(age = as.character(age)) |>
  rename(exposure = exposure_nonscaled) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
csv_path <- file.path(tempdir(), sub("\\.zip$", ".csv", basename(.out)))
write_csv(out, csv_path)
unlink(.out)
if (utils::zip(.out, csv_path, flags = "-j") != 0L) {
  stop("zip failed: ", .out, call. = FALSE)
}
unlink(csv_path)
