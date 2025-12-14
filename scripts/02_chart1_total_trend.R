# ============================================================
# IJC445 Data Visualisation
# Script: 02_chart1_total_trend.R
# Purpose:
#   Chart 1 - Total passenger journeys over time (Great Britain)
# Output:
#   figures/fig01_total_trend.png
# ============================================================

# ---- Load cleaned/tidy data ----

source("scripts/01_load_clean.R")

chart1_data <- tidy_journeys %>%
  group_by(time_period) %>%
  summarise(total_million = sum(journeys_million, na.rm = TRUE), .groups = "drop") %>%
  mutate(time_period = factor(time_period, levels = unique(time_period)))

p1 <- ggplot(chart1_data, aes(x = time_period, y = total_million, group = 1)) +
  geom_line(linewidth = 0.8) +
  scale_x_discrete(breaks = function(x) x[seq(1, length(x), by = 4)]) +
  labs(
    title = "A. Total passenger journeys over time (Great Britain)",
    subtitle = "Quarterly data",
    x = NULL,
    y = "Passenger journeys (millions)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(face = "bold"))

ggsave("figures/fig01_total_trend.png", p1, width = 10, height = 4.5, dpi = 300)
message("✅ Saved fig01_total_trend.png")
