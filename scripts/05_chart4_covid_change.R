# ============================================================
# IJC445 Data Visualisation
# Script: 05_chart4_covid_change.R
# Purpose: Chart 4 - Pre vs Post COVID % change (Top 8)
# Output: figures/fig04_covid_change.png
# ============================================================

source("scripts/03_chart2_operator_trends.R") # ensures tidy_journeys + top_ops exist

# ---- Define comparison windows ----
# Pre-COVID baseline: 2018–2019
# Post-COVID recovery: 2023–2024
covid_compare <- tidy_journeys |>
  filter(operator %in% top_ops) |>
  mutate(period_group = case_when(
    year %in% c(2018, 2019) ~ "Pre-COVID (2018–19)",
    year %in% c(2023, 2024) ~ "Post-COVID (2023–24)",
    TRUE ~ NA_character_
  )) |>
  filter(!is.na(period_group)) |>
  group_by(operator, period_group) |>
  summarise(avg_million = mean(journeys_million, na.rm = TRUE), .groups = "drop")

covid_change <- covid_compare |>
  pivot_wider(names_from = period_group, values_from = avg_million) |>
  mutate(
    pct_change = (`Post-COVID (2023–24)` - `Pre-COVID (2018–19)`) /
      `Pre-COVID (2018–19)` * 100
  ) |>
  arrange(desc(pct_change))

p4 <- ggplot(covid_change, aes(x = reorder(operator, pct_change), y = pct_change)) +
  geom_col() +
  coord_flip() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "D. Change in passenger journeys pre- vs post-COVID (Top 8)",
    subtitle = "Percent change in average quarterly journeys (2018–19 vs 2023–24)",
    x = NULL,
    y = "Percentage change (%)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave("figures/fig04_covid_change.png", plot = p4, width = 8, height = 6, dpi = 300)

message("Saved: figures/fig04_covid_change.png")
