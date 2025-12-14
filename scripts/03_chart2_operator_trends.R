# ============================================================
# IJC445 Data Visualisation
# Script: 03_chart2_operator_trends.R
# Purpose: Chart 2 - Operator trends (Top 8) with clean date axis
# Output: figures/fig02_operator_trends.png
# ============================================================

source("scripts/01_load_clean.R")

# ---- Select Top 8 operators by total journeys (whole period) ----
top_ops <- tidy_journeys |>
  group_by(operator) |>
  summarise(total = sum(journeys_million, na.rm = TRUE), .groups = "drop") |>
  arrange(desc(total)) |>
  slice(1:8) |>
  pull(operator)

tidy_top8 <- tidy_journeys |>
  filter(operator %in% top_ops, !is.na(date))

p2 <- ggplot(tidy_top8, aes(x = date, y = journeys_million)) +
  geom_line(linewidth = 0.6) +
  facet_wrap(~ operator, scales = "free_y", ncol = 2) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "B. Passenger journeys by operator over time (Top 8)",
    subtitle = "Quarterly data; free y-scales highlight differences in magnitude",
    x = NULL,
    y = "Passenger journeys (millions)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold")
  )

ggsave("figures/fig02_operator_trends.png", plot = p2, width = 10, height = 7, dpi = 300)

# Save the top operators list so you can reuse consistently
writeLines(top_ops, "outputs/top8_operators.txt")

message("Saved: figures/fig02_operator_trends.png")
message("Saved: outputs/top8_operators.txt")
