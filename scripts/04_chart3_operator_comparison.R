# ============================================================
# IJC445 Data Visualisation
# Script: 04_chart3_operator_comparison.R
# Purpose: Chart 3 - Latest-year operator comparison (Top 8)
# Output: figures/fig03_operator_ranking.png
# ============================================================

source("scripts/03_chart2_operator_trends.R") # ensures tidy_journeys + top_ops exist

# ---- Determine the latest year in the dataset ----
latest_year <- tidy_journeys |>
  filter(!is.na(year)) |>
  summarise(max_year = max(year)) |>
  pull(max_year)

chart3_data <- tidy_journeys |>
  filter(operator %in% top_ops, year == latest_year) |>
  group_by(operator) |>
  summarise(total_million = sum(journeys_million, na.rm = TRUE), .groups = "drop") |>
  arrange(desc(total_million))

p3 <- ggplot(chart3_data, aes(x = reorder(operator, total_million), y = total_million)) +
  geom_col() +
  coord_flip() +
  labs(
    title = paste0("C. Passenger journeys by operator in ", latest_year, " (Top 8)"),
    subtitle = "Total journeys aggregated across quarters",
    x = NULL,
    y = "Passenger journeys (millions)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave("figures/fig03_operator_ranking.png", plot = p3, width = 8, height = 6, dpi = 300)

message("Saved: figures/fig03_operator_ranking.png")
