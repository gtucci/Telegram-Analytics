# ===============================================================================
# STEP 8 – SHARED DOMAIN ANALYSIS
# ===============================================================================

library(tidyverse)
library(stringr)
library(janitor)
library(urltools)
library(here)

# Create output folder
output_dir <- here("outputs", "link_analysis")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# 1. Extract URLs from message column
link_data <- data_enhanced %>%
  mutate(urls = str_extract_all(message, "https?://[^\\s]+")) %>%
  unnest(urls) %>%
  filter(!is.na(urls))

# 2. Extract domain using urltools
link_data <- link_data %>%
  mutate(domain = domain(urls)) %>%
  filter(!is.na(domain))

# 3. Count domain frequency
domain_counts <- link_data %>%
  count(domain, sort = TRUE) %>%
  clean_names()

# Save full domain counts
write_csv(domain_counts, file = file.path(output_dir, "domain_counts.csv"))

# 4. Top domains plot
top_n <- 15
top_domains_plot <- domain_counts %>%
  slice_head(n = top_n) %>%
  ggplot(aes(x = reorder(domain, n), y = n)) +
  geom_col(fill = "#1f77b4", alpha = 0.8) +
  coord_flip() +
  theme_minimal() +
  labs(
    title = paste("Top", top_n, "Most Shared Domains"),
    subtitle = "Extracted from all URLs in message content",
    x = "Domain",
    y = "Number of Mentions"
  )

# Save plot
ggsave(file.path(output_dir, "top_domains.png"), plot = top_domains_plot, width = 8, height = 5, dpi = 300)

# Return result
list(
  domain_counts = domain_counts,
  plot = top_domains_plot
)
