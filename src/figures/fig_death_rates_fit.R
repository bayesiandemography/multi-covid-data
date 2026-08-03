command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(ggplot2)
  library(readr)
})

cmd_assign(
  .data_fit = "out/datasets_final/data_fit.rds",
  .out = "out/figures/fig_death_rates_fit.pdf"
)

data <- read_rds(.data_fit) |>
  mutate(rate = deaths / exposure) |>
  filter(is.finite(rate))

countries <- data |>
  distinct(country) |>
  arrange(country) |>
  pull(country)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)

pdf(file = .out, paper = "a4r", onefile = TRUE)
for (country_i in countries) {
  data_i <- data |>
    filter(country == country_i)

  p <- ggplot(data_i, aes(x = year, y = rate, colour = sex)) +
    facet_wrap(vars(age), scales = "free_y") +
    geom_line(linewidth = 0.4) +
    scale_colour_manual(values = c(Female = "darkorange", Male = "darkblue")) +
    labs(
      title = country_i,
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
