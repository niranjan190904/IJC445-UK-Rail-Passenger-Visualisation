# ============================================================
# IJC445 Data Visualisation
# Script: 00_packages.R
# Purpose: Install/load required packages for the project
# ============================================================

required_pkgs <- c(
  "readxl", "dplyr", "tidyr", "janitor", "readr",
  "stringr", "lubridate", "ggplot2", "patchwork"
)

missing <- required_pkgs[!required_pkgs %in% installed.packages()[, "Package"]]
if (length(missing) > 0) install.packages(missing)

invisible(lapply(required_pkgs, library, character.only = TRUE))
