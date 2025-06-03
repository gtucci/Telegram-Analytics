# Telegram Analytics Project

## Overview

This project implements a **modular, reproducible pipeline** for analyzing Telegram message datasets (CSV/TSV), using R.

It includes:

- **Dataset preparation and cleaning**
- **Temporal trends**
- **Sentiment and emotion analysis**
- **Popularity and virality metrics**:
    - Channel influence
    - Forwarded sources
    - Mentions & Hashtags
- **Network analysis** (planned)
- **Topic modeling** (planned)
- **Link sharing analysis** (planned)
- **Automated reporting** (RMarkdown)

---

## Project Structure

```text
/data_raw/                  # Raw input files (CSV or TSV)
/data_clean/                # Cleaned data (CSV and RDS)
/outputs/                   # Analysis outputs
    /temporal_analysis/     # Temporal trends plots
    /sentiment_analysis/    # Sentiment plots and CSV
    /popularity/            # Popularity metrics
        /entities/          # Mentions & Hashtags
    /networks/              # (Planned)
    /lda_topics/            # (Planned)
    /link_sharing/          # (Planned)
/reports/                   # Final analysis report
/scripts/                   # Modular analysis scripts
Telegram-Analytics.Rproj    # RStudio project
main_analysis.R             # Master pipeline script

```
---

## How to Run the Pipeline

1️⃣ Open `Telegram-Analytics.Rproj` in **RStudio**.

2️⃣ Run the master script:

3️⃣ The pipeline will prompt you to:

- Select input data: A folder containing .csv or .tsv files OR a single file anywhere on disk
- Select language for sentiment analysis (NRC-supported languages)

4️⃣ The pipeline will process all steps and generate:

- **Cleaned data** → `/data_clean/`
- **Plots and CSVs** → `/outputs/`
- **Final HTML report** → `/reports/`

---

## Reproducibility
✅ No hardcoded paths → uses here::here()

✅ Interactive input → fully flexible

✅ Modular scripts → easy to add new steps

✅ Automated report → can be re-run anytime


---

## Requirements
- R >= 4.2
- RStudio
- Packages:
    - tidyverse
    - lubridate
    - here
    - janitor
    - data.table
    - syuzhet
    - viridis
    - knitr
    - rmarkdown
    
---

# Status: In Progress 

## Implemented:

✅ Step 1: Data Cleaning  
✅ Step 2: Temporal Analysis  
✅ Step 3: Sentiment & Emotion Analysis  
✅ Step 4: Popularity & Virality (Channel, Forwarded, Mentions & Hashtags)  

## Planned:

🟡 Step 5: Network Analysis  
🟡 Step 6: Topic Modeling  
🟡 Step 7: Link Sharing  