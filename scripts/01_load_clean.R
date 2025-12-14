# ============================================================
# IJC445 Data Visualisation
# Script: 01_load_clean.R
# Purpose:
#   1) Load ORR Table 1223 (Passenger journeys by operator)
#   2) Clean columns + remove note columns
#   3) Create tidy long dataset for plotting
#
# Creates objects:
#   - data_clean   (wide)
#   - tidy_journeys (long / tidy)
# ============================================================


source("scripts/00_packages.R")

file_path <- "data/table-1223-passenger-journeys-by-operator.xlsx"

# Read sheet 3 with header after 5 rows
data_clean <- read_excel(
  path = file_path,
  sheet = 3,
  skip = 5,
  .name_repair = "unique"
) %>%
  remove_empty(c("rows", "cols")) %>%
  clean_names() %>%
  select(-matches("note_"))  # drop note columns if present

tidy_journeys <- data_clean %>%
  rename(time_period = 1) %>%
  pivot_longer(
    cols = -time_period,
    names_to = "operator",
    values_to = "journeys_million"
  ) %>%
  mutate(
    journeys_million = parse_number(as.character(journeys_million)),
    operator = str_replace(operator, "_million$", ""),
    operator = str_replace_all(operator, "_", " "),
    operator = str_to_title(operator),
    year = as.integer(str_extract(time_period, "\\d{4}")),
    q_start_month = case_when(
      str_detect(time_period, "^Jan") ~ 1,
      str_detect(time_period, "^Apr") ~ 4,
      str_detect(time_period, "^Jul") ~ 7,
      str_detect(time_period, "^Oct") ~ 10,
      TRUE ~ NA_real_
    ),
    date = as.Date(sprintf("%d-%02d-01", year, q_start_month))
  ) %>%
  filter(!is.na(time_period), !is.na(journeys_million))

dir.create("outputs", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

writeLines(names(data_clean), "outputs/columns_data_clean.txt")
writeLines(capture.output(head(tidy_journeys, 10)), "outputs/tidy_preview.txt")

message("✅ Loaded & cleaned. tidy_journeys rows: ", nrow(tidy_journeys))
