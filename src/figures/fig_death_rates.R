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
  .deaths = "out/figures/vals_deaths.rds",
  .exposure = "out/exposure.rds",
  year_min = 2000L,
  year_max = 2025L,
  .out = "out/figures/fig_death_rates.pdf"
)

deaths <- read_rds(.deaths) |>
  filter(year_min <= year, year <= year_max) |>
  mutate(age = as.character(age))

exposure <- read_rds(.exposure) |>
  filter(year_min <= year, year <= year_max) |>
  mutate(age = as.character(age)) |>
  select(country, year, sex, age, exposure)

collapse_exposure <- function(country_i, year_i) {
  deaths_i <- deaths |>
    filter(country == country_i, year == year_i)
  exposure_i <- exposure |>
    filter(country == country_i, year == year_i)

  target_ages <- unique(deaths_i$age)
  expos_ages <- unique(exposure_i$age)
  if (length(target_ages) == 0L || length(expos_ages) == 0L) {
    return(NULL)
  }

  mapping <- age_mapping(
    labels_x = expos_ages,
    labels_y = target_ages,
    relation = "is-contained-in",
    interpret_fail = "silent"
  ) |>
    filter(!is.na(x), !is.na(y))

  if (nrow(mapping) == 0L) {
    return(NULL)
  }

  exposure_i |>
    inner_join(mapping, by = c("age" = "x"), relationship = "many-to-many") |>
    group_by(country, year, sex, age = y) |>
    summarise(exposure = sum(exposure), .groups = "drop")
}

combos <- deaths |>
  distinct(country, year) |>
  arrange(country, year)

exposure_collapsed <- map2(combos$country, combos$year, collapse_exposure) |>
  list_rbind()

data <- deaths |>
  pivot_longer(
    cols = c(count_hmd, count_stmf),
    names_to = "source",
    values_to = "deaths"
  ) |>
  mutate(source = if_else(source == "count_hmd", "HMD", "STMF")) |>
  filter(!is.na(deaths)) |>
  inner_join(
    exposure_collapsed,
    by = c("country", "year", "sex", "age")
  ) |>
  mutate(
    rate = deaths / exposure,
    age = age_set_order(age, interpret_fail = "silent")
  ) |>
  filter(is.finite(rate))

pages <- data |>
  distinct(country, sex) |>
  arrange(country, sex)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)

pdf(file = .out, paper = "a4r", onefile = TRUE)
for (i in seq_len(nrow(pages))) {
  country_i <- pages$country[[i]]
  sex_i <- pages$sex[[i]]
  data_i <- data |>
    filter(country == country_i, sex == sex_i)

  p <- ggplot(data_i, aes(x = year, y = rate, colour = source)) +
    facet_wrap(vars(age), scales = "free_y") +
    geom_vline(xintercept = 2020, linewidth = 0.3, colour = "grey50") +
    geom_line(linewidth = 0.4) +
    scale_colour_manual(values = c(HMD = "black", STMF = "darkorange")) +
    expand_limits(y = 0) +
    labs(
      title = paste(country_i, sex_i, sep = " - "),
      x = "Year",
      y = "Deaths / exposure",
      colour = NULL
    ) +
    theme(
      text = element_text(size = 8),
      legend.position = "bottom"
    )
  print(p)
}
dev.off()
