command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(jsonlite)
  library(readr)
})

cmd_assign(
  .deaths = "data/nso/get.php",
  .out = "out/nso/hong_kong.rds"
)

raw <- fromJSON(.deaths, simplifyDataFrame = TRUE)

out <- raw$dataSet |>
  transmute(
    country = "HKG",
    year = as.integer(period),
    sex = recode_values(
      SEXDesc,
      "Male" ~ "Male",
      "Female" ~ "Female",
      "Total" ~ "Total"
    ),
    age = AGEDesc,
    count = as.numeric(figure),
    sd_value = na_if(sd_value, "")
  ) |>
  arrange(year, sex, age)

if (anyNA(out$sex)) {
  stop("Unrecognised Hong Kong sex label", call. = FALSE)
}

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)
write_rds(out, file = .out)
