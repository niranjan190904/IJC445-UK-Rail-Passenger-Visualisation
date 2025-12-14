UK Rail Passenger Journey Visualisation (IJC445)
Project Overview

This project presents a composite data visualisation of UK rail passenger journeys using official data published by the Office of Rail and Road (ORR). The objective is to explore long-term trends in passenger journeys, compare patterns across major rail operators, and examine changes before and after the COVID-19 pandemic through coordinated visual views.

The focus of this project is on data visualisation, visual design choices, and interpretability, rather than predictive modelling.

Dataset

Source: Office of Rail and Road (ORR)

Table: Passenger journeys by operator (Table 1223)

Geographical coverage: Great Britain

Time period: 2011–2025

Granularity: Quarterly passenger journeys (millions)

Project Setup

This project uses an RStudio Project (.Rproj) to manage the working directory.
All file paths in the scripts are relative to the project root, ensuring reproducibility.

To reproduce the visualisations:

Clone or download the repository

Open the .Rproj file in RStudio

Run the master script:

source("run_all.R")


All figures will be generated automatically.

Visualisation Objectives

The composite visualisation addresses the following questions:

How have total UK rail passenger journeys evolved over time?

How do passenger journey trends differ across major rail operators?

How do operators compare in the most recent year of data?

How has passenger demand changed before and after the COVID-19 pandemic?

Methods

Data cleaning and preprocessing (removal of metadata and note columns)

Handling of suppressed values ([Z]) as missing data

Transformation from wide to tidy (long) format

Aggregation and summarisation for visual comparison

Construction of a four-panel composite visualisation using ggplot2 and patchwork

Repository Structure
├─ data/        # Original ORR dataset
├─ scripts/     # R scripts for data preparation and visualisation
├─ figures/     # Final, report-ready figures
├─ outputs/     # Logs and intermediate outputs
├─ run_all.R    # One-click script to reproduce all figures
└─ README.md

Outputs

The project produces the following visual outputs:

Total passenger journeys over time

Passenger journey trends for the top rail operators

Operator comparison for the most recent year

Pre- and post-COVID percentage change by operator

A single composite visualisation combining all four views

All final figures are saved in the figures/ directory.

Author

Niranjan V
