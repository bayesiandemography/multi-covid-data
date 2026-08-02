command::use_renv()

suppressPackageStartupMessages({
  library(agetime)
  library(command)
  library(dplyr)
  library(ggplot2)
  library(purrr)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .hmd_deaths = "out/hmd/deaths.rds",
  .stmf_deaths = "out/stmf/deaths.rds",
  .out = "out/figures/fig_deaths.pdf"
)

hmd <- read_rds(.hmd_deaths) |>
  mutate(age = as.character(age)) |>
  select(country, year, sex, age, count_hmd = count)

stmf <- read_rds(.stmf_deaths) |>
  select(country, year, sex, age, count_stmf = count)

# Coarsen HMD life-table ages into each country's STMF age bands.
hmd_to_stmf <- function(country_i) {
  stmf_ages <- stmf |>
    filter(country == country_i) |>
    pull(age) |>
    unique()
  hmd_ages <- hmd |>
    filter(country == country_i) |>
    pull(age) |>
    unique()
  if (length(hmd_ages) == 0L || length(stmf_ages) == 0L) {
    return(NULL)
  }

  mapping <- age_mapping(
    labels_x = hmd_ages,
    labels_y = stmf_ages,
    relation = "is-contained-in",
    interpret_fail = "silent"
  ) |>
    filter(!is.na(x), !is.na(y))

  if (nrow(mapping) == 0L) {
    return(NULL)
  }

  hmd |>
    filter(country == country_i) |>
    inner_join(mapping, by = c("age" = "x"), relationship = "many-to-many") |>
    group_by(country, year, sex, age = y) |>
    summarise(count_hmd = sum(count_hmd, na.rm = TRUE), .groups = "drop")
}

hmd_matched <- unique(stmf$country) |>
  map(hmd_to_stmf) |>
  list_rbind()

joined <- stmf |>
  left_join(hmd_matched, by = c("country", "year", "sex", "age")) |>
  mutate(age = age_set_order(age, interpret_fail = "silent"))

combos <- joined |>
  distinct(country, sex) |>
  arrange(country, sex)

data <- joined |>
  pivot_longer(
    cols = c(count_hmd, count_stmf),
    names_to = "source",
    values_to = "count"
  ) |>
  mutate(source = if_else(source == "count_hmd", "HMD", "STMF"))

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)

pdf(file = .out, paper = "a4r", onefile = TRUE)
for (i in seq_len(nrow(combos))) {
  country_i <- combos$country[[i]]
  sex_i <- combos$sex[[i]]
  data_i <- data |>
    filter(country == country_i, sex == sex_i)

  p <- ggplot(data_i, aes(x = year, y = count, colour = source)) +
    facet_wrap(vars(age), scales = "free_y") +
    geom_line(linewidth = 0.4) +
    scale_colour_manual(values = c(HMD = "black", STMF = "darkorange")) +
    labs(
      title = paste(country_i, sex_i, sep = " - "),
      x = "Year",
      y = "Deaths",
      colour = NULL
    ) +
    theme(
      text = element_text(size = 8),
      legend.position = "bottom"
    )
  print(p)
}
dev.off()
