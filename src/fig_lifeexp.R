command::use_renv()

suppressPackageStartupMessages({
  library(command)
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
})

cmd_assign(
  .lifeexp = "out/intermediate/vals_lifeexp.rds",
  .out = "out/fig_lifeexp.pdf"
)

joined <- read_rds(.lifeexp) |>
  filter(is.finite(ex_data), is.finite(ex_hmd))

combos <- joined |>
  distinct(country, sex) |>
  arrange(country, sex)

data <- joined |>
  pivot_longer(
    cols = c(ex_hmd, ex_data),
    names_to = "source",
    values_to = "life_expectancy"
  ) |>
  mutate(
    source = if_else(source == "ex_hmd", "HMD", "Data file")
  )

dir.create(dirname(.out), recursive = TRUE, showWarnings = FALSE)

pdf(file = .out, paper = "a4r", onefile = TRUE)
for (i in seq_len(nrow(combos))) {
  country_i <- combos$country[[i]]
  sex_i <- combos$sex[[i]]
  data_i <- data |>
    filter(country == country_i, sex == sex_i)

  p <- ggplot(data_i, aes(x = year, y = life_expectancy, colour = source)) +
    geom_vline(xintercept = 2020, linewidth = 0.3, colour = "grey50") +
    geom_line(linewidth = 0.4) +
    scale_colour_manual(values = c(HMD = "black", "Data file" = "darkorange")) +
    labs(
      title = paste(country_i, sex_i, sep = " - "),
      x = "Year",
      y = "Life expectancy at birth",
      colour = NULL
    ) +
    theme(
      text = element_text(size = 8),
      legend.position = "bottom"
    )
  print(p)
}
dev.off()
