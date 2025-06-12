# Telegram Analytics Project

## Overview

This project implements a **modular, reproducible pipeline** for analyzing Telegram message datasets (CSV/TSV), using R. The analysis scripts are optimized to work directly with datasets exported via [TeleCatch](https://github.com/labaffa/telecatch), but they are also compatible with any Telegram message dataset.

Important: Before running the scripts, verify that your dataset contains the required columns with the correct names. You can find the list of expected columns in the [scripts](https://github.com/gtucci/Telegram-Analytics/tree/main/scripts) files.

It includes:

-   **Dataset preparation and cleaning**
-   **Temporal trends**
-   **Sentiment and emotion analysis**
-   **Popularity and virality metrics**:
    -   Channel influence
    -   Forwarded sources
    -   Mentions & Hashtags
-   **Network analysis** 
-   **Topic modeling** 
-   **Link sharing analysis** 
-   **Automated reporting** 

------------------------------------------------------------------------

## Project Structure

``` text
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

------------------------------------------------------------------------

## How to Run the Pipeline

1️⃣ Open `Telegram-Analytics.Rproj` in **RStudio**.

2️⃣ Run the master script: `/ source("main_analysis.R")/`

3️⃣ The pipeline will prompt you to:

-   Select input data: A folder containing .csv or .tsv files OR a single file anywhere on disk
-   Select language for sentiment analysis (NRC-supported languages)
    -   English
    -   Spanish
    -   French
    -   German
    -   Italian
    -   Portuguese

4️⃣ The pipeline will process all steps and generate:

-   **Cleaned data** → `/data_clean/`
-   **Plots and CSVs** → `/outputs/`
-   **Final HTML report** → `/reports/`

------------------------------------------------------------------------

## Reproducibility

✅ No hardcoded paths → uses here::here()

✅ Interactive input → fully flexible

✅ Modular scripts → easy to add new steps

✅ Automated report → can be re-run anytime

------------------------------------------------------------------------

## Requirements

-   R \>= 4.2
-   RStudio
-   Packages:
    -   tidyverse
    -   lubridate
    -   here
    -   janitor
    -   data.table
    -   syuzhet
    -   ggplot2
    -   viridis
    -   knitr
    -   rmarkdown
    -   magik
    -   cowplot
    -   stringr

------------------------------------------------------------------------


------------------------------------------------------------------------

# Authors and Acknowledgment

Telegram Analytics was developed by Giulia Tucci under the **CGIAR FOCUS** **Climate Security Digital Methods** team. The project was conducted with support from the CGIAR Science Programs **\###**. I would like to thank all funders who supported this research through their contributions to the [CGIAR Trust Fund](https://www.cgiar.org/funders/).

------------------------------------------------------------------------

# Licence

See the [LICENSE](https://github.com/gtucci/Telegram-Analytics/blob/main/LICENSE) file for license rights and limitations (MIT).


------------------------------------------------------------------------

# How to Cite

Tucci, G. (2025). Telegram Analytics: A modular pipeline for analyzing public Telegram data. Retrieved from https://github.com/gtucci/Telegram-Analytics
