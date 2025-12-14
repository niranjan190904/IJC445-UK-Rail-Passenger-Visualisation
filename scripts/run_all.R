# ============================================================
# IJC445 Data Visualisation
# Script: run_all.R
# Purpose: Build everything (data + all figures + composite) in one go
# How to use:
#   1) Open the IJC445 RStudio Project
#   2) Run: source("run_all.R")
# Outputs:
#   - figures/fig01_total_trend.png
#   - figures/fig02_operator_trends.png
#   - figures/fig03_operator_ranking.png
#   - figures/fig04_covid_change.png
#   - figures/fig_composite.png
#   - outputs/*.txt logs (columns, preview, top8 operators)
# ============================================================

# ============================================================
# run_all.R
# Purpose: One-click build for the entire project
# ============================================================

rm(list = ls())

dir.create("outputs", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

source("scripts/00_packages.R")
source("scripts/01_load_clean.R")
source("scripts/02_chart1_total_trend.R")
source("scripts/03_chart2_operator_trends.R")
source("scripts/04_chart3_operator_comparison.R")
source("scripts/05_chart4_covid_change.R")
source("scripts/06_make_composite.R")

message("✅ ALL DONE. Check figures/ for final images.")
