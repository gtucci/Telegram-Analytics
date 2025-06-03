# ===============================================================================
# SECTION 3: ADVANCED SENTIMENT AND EMOTION ANALYSIS (INTERACTIVE)
# ===============================================================================

# Load libraries
library(tidyverse)
library(lubridate)
library(here)
library(syuzhet)

# Load cleaned data
cat("=== LOADING CLEANED DATA FOR SENTIMENT ANALYSIS ===\n")
data_enhanced <- readRDS(here("data_clean/messages_clean.rds"))

# Define supported languages for NRC
supported_languages <- c("english", "spanish", "french", "german", "italian", "portuguese")

# Ask user for language
cat("Supported languages for NRC sentiment analysis:\n")
cat(paste0("- ", supported_languages, collapse = "\n"), "\n\n")

language_selected <- readline(prompt = "Enter language to use (exactly as shown above): ")

# Validate language
if (!(language_selected %in% supported_languages)) {
  stop(paste("ERROR: Language not supported:", language_selected, "\nSupported languages are:", paste(supported_languages, collapse = ", ")))
}

cat("=== Running sentiment analysis in language:", language_selected, "===\n")

# Enhanced sentiment analysis function (dynamic language)
enhanced_sentiment_analysis <- function(data, language = "english") {
  
  # Work with complete dataset
  sentiment_messages <- data
  
  # NRC emotion analysis
  nrc_sentiment <- get_nrc_sentiment(sentiment_messages$message, language = language)
  nrc_sentiment$net_sentiment <- nrc_sentiment$positive - nrc_sentiment$negative
  
  # Combine with original data
  sentiment_data <- bind_cols(sentiment_messages, nrc_sentiment) %>%
    mutate(
      sentiment_category = case_when(
        net_sentiment > 1 ~ "positive",
        net_sentiment < -1 ~ "negative",
        TRUE ~ "neutral"
      )
    )
  
  # Prepare time columns
  sentiment_data <- sentiment_data %>%
    mutate(
      date = as.Date(timestamp),
      month = format(date, "%Y-%m")
    )
  
  # Monthly emotion trends
  monthly_emotions <- sentiment_data %>%
    group_by(month) %>%
    summarise(
      across(c(anger, anticipation, disgust, fear, joy, sadness, surprise, trust),
             ~ mean(.x, na.rm = TRUE)),
      net_sentiment = mean(net_sentiment, na.rm = TRUE),
      message_count = n(),
      .groups = "drop"
    )
  
  # --- Heatmap --- #
  emotion_long <- monthly_emotions %>%
    select(month, anger:trust) %>%
    pivot_longer(cols = anger:trust, names_to = "emotion", values_to = "intensity")
  
  emotion_heatmap <- ggplot(emotion_long, aes(x = month, y = emotion, fill = intensity)) +
    geom_tile() +
    scale_fill_viridis_c(name = "Intensity", direction =-1) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(
      title = paste("Monthly Emotion Intensity Heatmap (", language, ")", sep = ""),
      subtitle = "Average emotion scores across all messages",
      x = "Month",
      y = "Emotion"
    )
  
  # Sentiment distribution plot
  sentiment_dist_plot <- sentiment_data %>%
    ggplot(aes(x = sentiment_category, fill = sentiment_category)) +
    geom_bar(alpha = 0.8) +
    scale_fill_manual(values = c("negative" = "#d62728", "neutral" = "#7f7f7f", "positive" = "#2ca02c")) +
    theme_minimal() +
    labs(
      title = paste("Overall Sentiment Distribution (", language, ")", sep = ""),
      subtitle = "Message classification by sentiment polarity",
      x = "Sentiment Category",
      y = "Number of Messages"
    ) +
    theme(legend.position = "none")
  
  # Return
  return(list(
    data = sentiment_data, 
    heatmap = emotion_heatmap, 
    monthly = monthly_emotions,
    distribution_plot = sentiment_dist_plot
  ))
}

# Run analysis
sentiment_results_nrc <- enhanced_sentiment_analysis(data_enhanced, language = language_selected)

# Show results
print(sentiment_results_nrc$heatmap)
print(sentiment_results_nrc$monthly)
print(sentiment_results_nrc$distribution_plot)

# === SAVE SENTIMENT ANALYSIS RESULTS ===

# Create output folder if needed
if (!dir.exists(here("outputs/sentiment_analysis"))) {
  dir.create(here("outputs/sentiment_analysis"), recursive = TRUE)
}

# Save heatmap
ggsave(here("outputs/sentiment_analysis/emotion_heatmap.png"),
       plot = sentiment_results_nrc$heatmap,
       width = 8, height = 5)

# Save sentiment distribution
ggsave(here("outputs/sentiment_analysis/sentiment_distribution.png"),
       plot = sentiment_results_nrc$distribution_plot,
       width = 6, height = 5)

# Save monthly emotions as CSV
write_csv(sentiment_results_nrc$monthly, here("outputs/sentiment_analysis/monthly_emotions.csv"))

# Optionally save full sentiment data (can be useful for advanced analyses)
saveRDS(sentiment_results_nrc$data, here("outputs/sentiment_analysis/sentiment_data.rds"))

cat("=== SENTIMENT ANALYSIS RESULTS SAVED TO /outputs/sentiment_analysis/ ===\n")