command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(readr)
})

cmd_assign(
  .vsa29 = "data/nso/VSA29.20260827020459.csv",
  .vsa07 = "data/nso/VSA07.20260827020411.csv",
  .out = "out/nso/ireland.rds"
)

recode_sex <- function(sex) {
  recode_values(
    sex,
    "Male" ~ "Male",
    "Female" ~ "Female",
    "Both sexes" ~ "Total"
  )
}

# VSA29 is occurrence-based and includes cause of death.
# VSA07 is the CSO yearly-summary cube. Its statistic label says
# "Deaths Occurring"; data/nso/README.txt records the 2024-2025
# release as registration-based. The published label is kept as-is.
vsa29 <- read_csv(.vsa29, show_col_types = FALSE) |>
  transmute(
    country = "IRL",
    table = "VSA29",
    statistic = `Statistic Label`,
    year = as.integer(Year),
    sex = recode_sex(Sex),
    age = `Age Group at Death`,
    area = NA_character_,
    cause = `Cause of Death`,
    count = VALUE
  )

vsa07 <- read_csv(.vsa07, show_col_types = FALSE) |>
  transmute(
    country = "IRL",
    table = "VSA07",
    statistic = `STATISTIC Label`,
    year = as.integer(Year),
    sex = recode_sex(Sex),
    age = `Age Group at Death`,
    area = `Area of Residence`,
    cause = NA_character_,
    count = VALUE
  )

out <- bind_rows(vsa29, vsa07) |>
  arrange(table, year, area, cause, sex, age)

if (anyNA(out$sex)) {
  stop("Unrecognised Ireland sex label", call. = FALSE)
}

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
