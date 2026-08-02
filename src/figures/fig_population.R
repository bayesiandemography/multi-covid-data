command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .hmd_population = "out/hmd/population.rds",
  .wpp_population = "out/wpp/population.rds",
  year_min = 2020L,
  .out = "out/figures/fig_population_covid.pdf"
)

hmd <- read_rds(.hmd_population) |>
  filter(grepl("^[0-9]+$", year)) |>
  mutate(year = as.integer(year)) |>
  select(country, year, sex, age, count_hmd = count)

# WPP Population1January files store counts in thousands.
wpp <- read_rds(.wpp_population) |>
  mutate(count_wpp = count * 1000) |>
  select(country, year, sex, age, count_wpp)

joined <- hmd |>
  left_join(wpp, by = c("country", "year", "sex", "age")) |>
  filter(year >= year_min)

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
    geom_line(linewidth = 0.4) +
    scale_colour_manual(values = c(HMD = "black", WPP = "darkorange")) +
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
