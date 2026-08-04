command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .newdata_nonscaled = "out/datasets_final/newdata_nonscaled.rds",
  .newdata_scaled = "out/datasets_final/newdata_scaled.rds",
  .out = "out/figures/fig_newdata_exposure.pdf"
)

data <- read_rds(.newdata_nonscaled) |>
  inner_join(
    read_rds(.newdata_scaled),
    by = c("country", "year", "sex", "age"),
    suffix = c("_nonscaled", "_scaled")
  ) |>
  pivot_longer(
    cols = c(exposure_nonscaled, exposure_scaled),
    names_to = "scale",
    names_prefix = "exposure_",
    values_to = "exposure"
  ) |>
  mutate(scale = factor(scale, levels = c("nonscaled", "scaled")))

countries <- data |>
  distinct(country) |>
  arrange(country) |>
  pull(country)

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)

pdf(file = .out, paper = "a4r", onefile = TRUE)
for (country_i in countries) {
  data_i <- data |>
    filter(country == country_i)

  p <- ggplot(data_i, aes(x = year, y = exposure, colour = sex, linetype = scale)) +
    facet_wrap(vars(age), scales = "free_y") +
    geom_line(linewidth = 0.4) +
    scale_colour_manual(values = c(Female = "darkorange", Male = "darkblue")) +
    scale_linetype_manual(values = c(nonscaled = "dotted", scaled = "solid")) +
    expand_limits(y = 0) +
    labs(
      title = country_i,
      x = "Year",
      y = "Exposure",
      colour = NULL,
      linetype = NULL
    ) +
    theme(
      text = element_text(size = 8),
      legend.position = "bottom"
    )
  print(p)
}
dev.off()
