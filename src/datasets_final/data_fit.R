command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .deaths = "out/shared/deaths.rds",
  .exposure = "out/shared/exposure.rds",
  .out = "out/datasets_final/data_fit.zip"
)

out <- read_rds(.deaths) |>
  filter(year < 2020L) |>
  select(country, year, sex, age, deaths) |>
  inner_join(
    read_rds(.exposure) |>
      select(country, year, sex, age, exposure_nonscaled),
    by = c("country", "year", "sex", "age")
  ) |>
  mutate(
    deaths = round(deaths),
    age = as.character(age)
  ) |>
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
