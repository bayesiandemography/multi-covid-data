command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .deaths = "out/intermediate/deaths.rds",
  .exposure = "out/intermediate/exposure.rds",
  .out = "out/data.csv.zip"
)

deaths <- read_rds(.deaths) |>
  mutate(age = as.character(age)) |>
  select(
    country,
    year,
    sex,
    age,
    deaths,
    deaths_source = source
  )

exposure <- read_rds(.exposure) |>
  mutate(age = as.character(age)) |>
  select(
    country,
    year,
    sex,
    age,
    exposure,
    population_source
  )

out <- full_join(
  deaths,
  exposure,
  by = c("country", "year", "sex", "age")
) |>
  mutate(deaths = round(deaths)) |>
  select(
    country,
    year,
    sex,
    age,
    deaths,
    exposure,
    deaths_source,
    population_source
  ) |>
  arrange(country, year, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
csv_path <- file.path(tempdir(), sub("\\.zip$", "", basename(.out)))
write_csv(out, csv_path)
unlink(.out)
if (utils::zip(.out, csv_path, flags = "-j") != 0L) {
  stop("zip failed: ", .out, call. = FALSE)
}
unlink(csv_path)
