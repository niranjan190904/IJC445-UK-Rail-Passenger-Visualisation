# ==============================================================================
# IJC445 – Data Visualisation
# UK Rail Passenger Journey Visualisation (ORR Table 1223)
# Author: Niranjan
#
# Description:
# - Data cleaning and preprocessing of ORR passenger data.
# - Trend analysis of passenger journeys by operator type.
# - COVID impact assessment and recovery tracking (2019-2025).
# - Visualisations saved to 'figures/' folder.
#
# Required packages:
# - tidyverse (includes ggplot2, dplyr, tidyr, stringr, lubridate)
# - readxl (for Excel ingestion), readr
# - janitor (for column cleaning)
# - patchwork (for composite layouts)
# - scales (for percentage formatting)
#
# These packages must be installed before running this script.
# This script is designed to be run within the RStudio Project.
# File paths are relative to the project root.
# ==============================================================================

# 1. SETUP AND PACKAGE LOADING
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, readr, dplyr, tidyr, janitor, stringr, lubridate, ggplot2, patchwork, scales)

# Create figures directory if it doesn't exist
if(!dir.exists("figures")) dir.create("figures")

# 2. DATA LOADING
file_path <- "data/table-1223-passenger-journeys-by-operator.xlsx"

if(!file.exists(file_path)) {
  # Fallback: Generate dummy data if file is missing (For testing purposes)
  message("Warning: Source file not found. Generating dummy dataset for demonstration.")
  dates <- seq(as.Date("2015-01-01"), as.Date("2025-10-01"), by="quarter")
  raw_data <- expand.grid(time_period = as.character(dates),
                          operator = c("Govia Thameslink Railway", "Elizabeth line million note 6",
                                       "London Overground", "South Western Railway", "Southeastern",
                                       "Great Western Railway", "Northern Trains", "ScotRail"))
  raw_data$journeys_million <- runif(nrow(raw_data), 20, 50)
  
  # Simulate 2019 peak and Elizabeth Line introduction
  is_2019 <- lubridate::year(dates) == 2019
  raw_data$journeys_million[raw_data$time_period %in% as.character(dates[is_2019])] <- 
    raw_data$journeys_million[raw_data$time_period %in% as.character(dates[is_2019])] * 1.5
  
  is_liz <- stringr::str_detect(raw_data$operator, "Elizabeth")
  raw_data$journeys_million[is_liz] <- ifelse(raw_data$time_period[is_liz] < "2022-01-01", 0, 80)
} else {
  # Load raw data, treating text placeholders as NA
  raw_data <- read_excel(file_path, sheet = 3, skip = 5, .name_repair = "unique", na = c("", "NA", "[z]"))
}

# 3. DATA CLEANING AND PREPROCESSING
tidy_journeys <- raw_data %>%
  clean_names() %>%
  rename(time_period = 1) %>%
  filter(str_detect(time_period, "\\d{4}")) %>%
  pivot_longer(cols = -time_period, names_to = "operator_raw", values_to = "journeys_million") %>%
  mutate(
    journeys_million = parse_number(as.character(journeys_million)),
    
    # Standardize Operator Names
    operator_clean = operator_raw %>%
      str_replace_all("_", " ") %>%
      str_remove_all(" note \\d+| million") %>%
      str_squish() %>%
      str_to_title(),
    
    # Map to Target Operator List
    operator = case_when(
      str_detect(operator_clean, "(?i)Govia|Gtr") ~ "Govia Thameslink Railway",
      str_detect(operator_clean, "(?i)Elizabeth|Tfl Rail") ~ "Elizabeth Line",
      str_detect(operator_clean, "(?i)Overground") ~ "London Overground",
      str_detect(operator_clean, "(?i)South.*Western") ~ "South Western Railway",
      str_detect(operator_clean, "(?i)Southeastern") ~ "Southeastern",
      str_detect(operator_clean, "(?i)Great.*Western") ~ "Great Western Railway",
      str_detect(operator_clean, "(?i)Northern") ~ "Northern Trains",
      str_detect(operator_clean, "(?i)Scot") ~ "ScotRail",
      TRUE ~ "Other"
    ),
    
    # Date Conversion
    year = as.integer(str_extract(time_period, "\\d{4}")),
    q_start_month = case_when(
      str_detect(time_period, "(?i)Jan") ~ 1,
      str_detect(time_period, "(?i)Apr") ~ 4,
      str_detect(time_period, "(?i)Jul") ~ 7,
      TRUE ~ 10
    ),
    date = make_date(year, q_start_month, 1)
  )

# 4. REFERENCE METADATA
target_operators <- c("Govia Thameslink Railway", "Elizabeth Line", "London Overground", 
                      "South Western Railway", "Southeastern", "Great Western Railway", 
                      "Northern Trains", "ScotRail")

operator_meta <- tibble(
  operator = target_operators,
  type = c("Commuter (London)", "New Infrastructure", "Commuter (London)", 
           "Commuter (London)", "Commuter (London)", "Intercity", 
           "Regional / North", "Regional / Scotland")
)

# Custom Color Palette
my_colors <- c("Commuter (London)" = "#d95f02", 
               "New Infrastructure" = "#7570b3", 
               "Regional / North" = "#1b9e77", 
               "Regional / Scotland" = "#1b9e77", 
               "Intercity" = "#e7298a")

# ==============================================================================
# VISUALISATION GENERATION
# ==============================================================================

# --- PLOT 1: The "Masking Effect" (Total vs Legacy) ---
split_data <- tidy_journeys %>%
  filter(date >= as.Date("2019-01-01")) %>%
  group_by(date) %>%
  summarise(
    Total = sum(journeys_million, na.rm=TRUE),
    Elizabeth = sum(journeys_million[operator == "Elizabeth Line"], na.rm=TRUE)
  ) %>%
  mutate(Legacy = Total - Elizabeth)

f1 <- ggplot(split_data, aes(x=date)) +
  geom_ribbon(aes(ymin=Legacy, ymax=Total), fill="#FFD700", alpha=0.7) +
  geom_line(aes(y=Total, color="Total Network"), linewidth=1.2) +
  geom_line(aes(y=Legacy, color="Legacy Network"), linewidth=1.2, linetype="dashed") +
  scale_color_manual(name=NULL, values = c("Total Network" = "#2c7fb8", "Legacy Network" = "#d95f02")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "A. The Two-Speed Recovery", 
    subtitle = "Yellow Area = The 'Masking Effect' (Volume added by Elizabeth Line).",
    y = "Journeys (m)", x = NULL
  ) +
  theme_minimal(base_size = 12) + 
  theme(legend.position = "bottom", plot.title = element_text(face = "bold"))

# --- PLOT 2: Operator Trends vs 2019 Baseline ---
data_p2 <- tidy_journeys %>%
  filter(operator %in% target_operators, date >= as.Date("2019-01-01")) %>%
  left_join(operator_meta, by="operator")

# Calculate strict quarterly average (Annual 2019 Total / 4)
ref_lines <- data_p2 %>% 
  filter(year == 2019) %>% 
  group_by(operator) %>% 
  summarise(avg_2019 = sum(journeys_million, na.rm=TRUE) / 4) 

f2 <- ggplot(data_p2, aes(x=date, y=journeys_million)) +
  geom_hline(data = ref_lines, aes(yintercept = avg_2019), linetype="dotted", color="black", linewidth = 0.8) +
  geom_line(aes(color=type), linewidth=1) +
  facet_wrap(~operator, scales="free_y", ncol=4) +
  scale_color_manual(values=my_colors) +
  labs(
    title="B. Trends vs 2019 Baseline", 
    subtitle="Dotted Line = 2019 Quarterly Average (Comparison Baseline).", 
    y="Journeys (m)", color=NULL
  ) +
  theme_minimal(base_size=11) + 
  theme(legend.position="bottom", axis.text.x=element_text(angle=45, hjust=1), plot.title = element_text(face = "bold"))

# --- PLOT 3: Market Volume (Rolling Year) ---
max_d <- max(tidy_journeys$date)
data_p3 <- tidy_journeys %>%
  filter(operator %in% target_operators, date > (max_d - months(12))) %>%
  group_by(operator) %>% 
  summarise(total_annual = sum(journeys_million, na.rm=TRUE)) %>%
  left_join(operator_meta, by="operator")

f3 <- ggplot(data_p3, aes(x=reorder(operator, total_annual), y=total_annual, fill=type)) +
  geom_col(width=0.7) + coord_flip() +
  geom_text(aes(label=round(total_annual,0)), hjust=-0.2, size=3.5) +
  scale_fill_manual(values=my_colors) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(
    title="C. Market Volume", 
    subtitle="Total Journeys (Last 4 Quarters)", 
    x=NULL, y="Journeys (m)"
  ) +
  theme_minimal(base_size=11) + 
  theme(legend.position="none", plot.title=element_text(face="bold"))

# --- PLOT 4: Recovery Scorecard (Expanded Negative Range) ---
recovery_data <- tidy_journeys %>%
  filter(operator %in% target_operators) %>%
  group_by(operator) %>%
  summarise(
    val_2019 = sum(journeys_million[year == 2019], na.rm=TRUE),
    val_curr = sum(journeys_million[date > (max_d - months(12))], na.rm=TRUE)
  ) %>%
  mutate(pct_change = (val_curr - val_2019) / val_2019) %>%
  filter(operator != "Elizabeth Line") %>% 
  left_join(operator_meta, by="operator")

f4 <- ggplot(recovery_data, aes(x=reorder(operator, pct_change), y=pct_change, fill=type)) +
  geom_hline(yintercept=0, color="gray50") +
  geom_segment(aes(xend=operator, y=0, yend=pct_change), color="gray80", linewidth=1.5) +
  geom_point(size=6, shape=21, color="white", stroke=1.5) + 
  coord_flip() +
  geom_text(aes(label=scales::percent(pct_change, accuracy=1), 
                hjust=ifelse(pct_change > 0, -0.4, 1.4)), size=3.5, fontface="bold") +
  scale_fill_manual(values=my_colors) +
  # Expanded range: -100% to +50% with 30% breaks
  scale_y_continuous(labels=scales::percent, 
                     limits = c(-1.0, 0.5), 
                     breaks = seq(-0.9, 0.6, 0.3)) + 
  labs(
    title="D. Recovery Scorecard", 
    subtitle="Change vs 2019 (Rolling Year)", 
    x=NULL, y="% Change"
  ) +
  theme_minimal(base_size=11) + 
  theme(legend.position="none", plot.title=element_text(face="bold"))

# --- COMPOSITE PLOT ---
f_composite <- f1 / f2 / (f3 + f4) + 
  plot_layout(heights = c(1, 1.3, 0.8)) +
  plot_annotation(
    title = "UK Rail Recovery Dashboard (2019-2025)",
    caption = "Source: ORR Table 1223 | Analysis by Niranjan"
  )

# ==============================================================================
# 5. EXPORT OUTPUTS
# ==============================================================================

# Save Individual Plots
ggsave("figures/plot_1_masking_effect.png", f1, width = 10, height = 6, dpi = 300)
ggsave("figures/plot_2_trends.png", f2, width = 12, height = 8, dpi = 300)
ggsave("figures/plot_3_volume.png", f3, width = 8, height = 6, dpi = 300)
ggsave("figures/plot_4_recovery.png", f4, width = 8, height = 6, dpi = 300)

# Save Composite Dashboard
ggsave("figures/final_dashboard_composite.png", f_composite, width = 12, height = 15, dpi = 300)

message("Processing Complete.")
message(" - Individual plots saved to 'figures/'")

message(" - Composite dashboard saved as 'figures/final_dashboard_composite.png'")


