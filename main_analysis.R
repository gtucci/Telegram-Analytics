# ===============================================================================
# MAIN ANALYSIS SCRIPT
# Runs all steps in the correct order
# ===============================================================================

# Load libraries needed for rendering reports
library(rmarkdown)

# Source scripts in order
source("scripts/01_load_and_clean.R")
source("scripts/02_temporal_analysis.R")
source("scripts/03_sentiment_analysis.R")
source("scripts/04_popularity_metrics.R")
source("scripts/05_network_analysis.R")
source("scripts/06_topic_modeling.R")
source("scripts/07_link_sharing.R")
source("scripts/08_visualizations.R")

# Render the analysis report
rmarkdown::render("reports/analysis_report.Rmd", output_dir = "reports")

cat("=== FULL ANALYSIS COMPLETED ===\n")

