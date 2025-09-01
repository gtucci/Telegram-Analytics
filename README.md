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
    -   Forwarding Network
    -   Mentions Network
    -   Channel-Hashtag Network
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
    /networks/              # Nodes & Edges tables (CSV)
    /lda_topics/            # Topic Modeling and word clouds per topic
    /link_sharing/          # Top domains
/reports/                   # Final analysis report
/scripts/                   # Modular analysis scripts
Telegram-Analytics.Rproj    # RStudio project
main_analysis.R             # Master pipeline script
```

------------------------------------------------------------------------


## 📦 Quick Start (Download-only Users)

If you're not using Git and downloaded the ZIP file:

1. Click the green **Code** button and select **Download ZIP** or download here  [![Download ZIP](https://img.shields.io/badge/Download-ZIP-blue)](https://github.com/gtucci/Telegram-Analytics/archive/refs/heads/main.zip)
2. Unzip the folder — GitHub will name it `Telegram-Analytics-main`
3. (Optional) Rename the folder to `Telegram-Analytics` for clarity
4. Open the file `Telegram-Analytics.Rproj` in **RStudio**
5. Run the script `main_analysis.R` to execute the pipeline

------------------------------------------------------------------------

   ## About the Pipeline

 The pipeline will prompt you to:

-   Select input data: A folder containing .csv or .tsv files OR a single file anywhere on disk
-   Select language for sentiment analysis (NRC-supported languages)
    -   English
    -   Spanish
    -   French
    -   German
    -   Italian
    -   Portuguese

The pipeline will process all steps and generate:

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



# Authors and Acknowledgment

Telegram Analytics was developed by Giulia Tucci under the **CGIAR Climate Security digital innovations team**. The project was conducted with support from the CGIAR Science Program on Climate Action and the CGIAR Science Program on Food Frontiers and Security. I would like to thank all funders who supported this research through their contributions to the [CGIAR Trust Fund](https://www.cgiar.org/funders/).

## How to Cite
If you use this project, please cite it as:

> Tucci, G. (2025). *Telegram Analytics: A modular pipeline for analyzing public Telegram data* (Version 1.0.0) [Computer software]. Zenodo. https://doi.org/10.5281/zenodo.15645166
> 
> 📌 Citation metadata is available in [CITATION.cff](./CITATION.cff) and via the **“Cite this repository”** button on GitHub.
> 
>  [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15645166.svg)](https://doi.org/10.5281/zenodo.15645166)

------------------------------------------------------------------------

# Licence

See the [LICENSE](https://github.com/gtucci/Telegram-Analytics/blob/main/LICENSE) file for license rights and limitations (MIT).





