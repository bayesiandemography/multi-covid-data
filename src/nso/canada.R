command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .deaths = "data/nso/13100768-eng.zip",
  .out = "out/nso/canada.rds"
)

tmpdir <- tempfile("nso-canada")
dir.create(tmpdir)
on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

unzip(.deaths, files = "13100768.csv", exdir = tmpdir)

out <- read_csv(
  file.path(tmpdir, "13100768.csv"),
  show_col_types = FALSE
) |>
  transmute(
    country = "CAN",
    geo = GEO,
    week_ending = as.Date(REF_DATE),
    year = as.integer(format(week_ending, "%Y")),
    sex = recode_values(
      Sex,
      "Males" ~ "Male",
      "Females" ~ "Female",
      "Both sexes" ~ "Total"
    ),
    age = sub("^Age at time of death, ", "", `Age at time of death`),
    count = VALUE,
    status = na_if(STATUS, "")
  ) |>
  arrange(geo, week_ending, sex, age)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
