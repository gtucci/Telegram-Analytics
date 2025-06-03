# Telegram-Analytics

Template repository for analyzing Telegram messages.

This repository provides a structure and reusable R scripts to analyze messages extracted from public Telegram channels and/or groups. The goal is to support repeatable workflows for content analysis, source mapping, and visualization.

## Features

- Input: raw `.tsv` or `.csv` files with Telegram messages
- Output: processed `.csv` files
- Example analyses:
  - message characterization
  - source networks
  - word clouds
  - topic modeling (LDA)
  - virality and influence scores

## Usage

1. Place raw `.tsv` or `.csv` files in the `data/raw/` directory
2. Run provided R scripts in RStudio
3. Outputs are saved to `data/processed/` and `outputs/`

## Requirements

- R
- RStudio
- R packages:
  - tidyverse
  - lubridate
  - stringr
  - topicmodels
  - wordcloud
  - igraph
  - ggraph

## License

Private repository. For internal and research use only.
