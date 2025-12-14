# ============================================================
# IJC445 Data Visualisation
# Script: 06_make_composite.R
# Purpose: Combine the 4 figures into one composite image
# Output: figures/fig_composite.png
# ============================================================

source("scripts/00_packages.R")

# Read saved plots? Better: rebuild from scripts and combine as objects.
# We'll build objects by sourcing each plot script and reusing the ggplot objects.
# To do that, we slightly adjust: we will regenerate plots directly here.

source("scripts/01_load_clean.R")

# Recreate Chart 1 object
chart1_data <- tidy_journeys |>
  group_by(time_period) |>
  summarise(total_million = sum(journeys_million, na.rm = TRUE), .groups = "drop") |>
  mutate(time_period = factor(time_period, levels = unique(time_period)))

p1 <- ggplot(chart1_data, aes(x = time_period, y = total_million, group = 1)) +
  geom_line(linewidth = 0.8) +
  labs(title = "A. Total passenger journeys over time", x = NULL, y = "Millions") +
  scale_x_discrete(breaks = function(x) x[seq(1, length(x), by = 4)]) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), plot.title = element_text(face = "bold"))

# Top 8 operators + Chart 2 object
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
  labs(title = "B. Journeys by operator (Top 8)", x = NULL, y = "Millions") +
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"), plot.title = element_text(face = "bold"))

# Latest year + Chart 3 object
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
  labs(title = paste0("C. Operator comparison (", latest_year, ")"), x = NULL, y = "Millions") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

# COVID change + Chart 4 object
covid_compare <- tidy_journeys |>
  filter(operator %in% top_ops) |>
  mutate(period_group = case_when(
    year %in% c(2018, 2019) ~ "Pre (2018–19)",
    year %in% c(2023, 2024) ~ "Post (2023–24)",
    TRUE ~ NA_character_
  )) |>
  filter(!is.na(period_group)) |>
  group_by(operator, period_group) |>
  summarise(avg_million = mean(journeys_million, na.rm = TRUE), .groups = "drop")

covid_change <- covid_compare |>
  pivot_wider(names_from = period_group, values_from = avg_million) |>
  mutate(pct_change = (`Post (2023–24)` - `Pre (2018–19)`) / `Pre (2018–19)` * 100)

p4 <- ggplot(covid_change, aes(x = reorder(operator, pct_change), y = pct_change)) +
  geom_col() +
  coord_flip() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "D. Pre vs post COVID change", x = NULL, y = "% change") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

# ---- Combine using patchwork ----
composite_plot <- (p1 / p2) | (p3 / p4)

ggsave("figures/fig_composite.png", plot = composite_plot, width = 14, height = 10, dpi = 300)

message("Saved: figures/fig_composite.png")
