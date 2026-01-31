# UK Rail Passenger Visualisation (ORR Table 1223)

## Module
**IJC445 – Data Visualisation**

## Project Title
**The “Masking Effect” in UK Rail Recovery: A Visual Analysis of Post-Pandemic Passenger Trends**

## Author
Niranjan  
University of Sheffield

---

## 📌 Project Overview

This project analyses UK rail passenger journeys using **Office of Rail and Road (ORR) Table 1223** data.  
The objective is to investigate whether headline rail recovery figures after COVID-19 **mask underlying structural declines** in traditional commuter networks.

Using the **ASSERT framework** and the **Grammar of Graphics (GoG)**, the project develops a composite visualisation that reveals a **two-speed recovery**:
- Strong growth driven by the **Elizabeth Line**
- Continued under-performance of **legacy London commuter operators**

The project is fully reproducible using R.

---


## 🛠 Software Requirements

- **R (version 4.2 or later recommended)**
- **RStudio (recommended but optional)**

### Required R Packages
The script automatically installs required packages if missing:
- `readxl`
- `readr`
- `dplyr`
- `tidyr`
- `janitor`
- `stringr`
- `lubridate`
- `ggplot2`
- `patchwork`
- `scales`
- `pacman`

---

## ▶️ How to Run This Project (Beginner Friendly)

### Step 1: Clone or Download the Repository
- Click **Code → Download ZIP** on GitHub  
  **OR**
- Clone using Git:
  git clone https://github.com/your-username/your-repo-name.git
  
### Step 2: Open the Project in RStudio
Open RStudio
Click File → Open Project
Select the project folder
⚠️ Ensure your working directory is the project root

### Step 3: Check Data File Location
Ensure the following file exists:
data/table-1223-passenger-journeys-by-operator.xlsx
If the file is missing:
The script will generate dummy data for demonstration
A warning message will appear in the console

### Step 4: Run the Analysis Script
Open the script:
scripts/Script.R

Run the script:
Click Source
Or run line-by-line using Ctrl + Enter

### Step 5: View Outputs
After execution:
All plots are saved to the figures/ folder
The final composite dashboard is saved as:
figures/final_dashboard_composite.png

### 📊 Generated Visualisations
Plot A – The Masking Effect
Total Network vs Legacy Network (Elizabeth Line excluded)

Plot B – Operator Trends
Small multiples vs 2019 baseline

Plot C – Market Volume
Rolling annual passenger volume by operator

Plot D – Recovery Scorecard
Percentage change vs 2019

Composite Dashboard
Integrated narrative visualisation

### 🧠 Methodological Frameworks

ASSERT Framework (Ask, Search, Structure, Envision, Represent, Tell)
Grammar of Graphics (Wilkinson, 2005)
Task Abstraction (Brehmer & Munzner, 2013)
Accessibility-aware colour design (ColorBrewer)

### ⚠️ Notes on Reproducibility
All file paths are relative
Script is fully reproducible on any machine with R
No manual data cleaning required

### 📚 Data Source
Office of Rail and Road (ORR)
Dataset: Table 1223 – Passenger journeys by operator
