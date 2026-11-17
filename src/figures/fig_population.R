command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .population = "out/figures/vals_population.rds",
  year_min = 1960L,
  .out = "out/figures/fig_population.pdf"
)

joined <- read_rds(.population) |>
  filter(year >= year_min) |>
  select(country, year, sex, age, count_hmd, count_wpp)

combos <- joined |>
  distinct(country, sex) |>
  arrange(country, sex)

data <- joined |>
  pivot_longer(
    cols = c(count_hmd, count_wpp),
    names_to = "source",
    values_to = "count"
  ) |>
  mutate(source = if_else(source == "count_hmd", "HMD", "WPP"))

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)

pdf(file = .out, paper = "a4r", onefile = TRUE)
for (i in seq_len(nrow(combos))) {
  country_i <- combos$country[[i]]
  sex_i <- combos$sex[[i]]
  data_i <- data |>
    filter(country == country_i, sex == sex_i)

  p <- ggplot(data_i, aes(x = year, y = count, colour = source)) +
    facet_wrap(vars(age), scales = "free_y") +
    geom_vline(xintercept = 2020, linewidth = 0.3, colour = "grey50") +
    geom_line(linewidth = 0.4) +
    scale_colour_manual(values = c(HMD = "black", WPP = "darkorange")) +
    expand_limits(y = 0) +
    labs(
      title = paste(country_i, sex_i, sep = " - "),
      x = "Year",
      y = "Population",
      colour = NULL
    ) +
    theme(
      text = element_text(size = 8),
      legend.position = "bottom"
    )
  print(p)
}
dev.off()
