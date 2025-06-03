# ===============================================================================
# STEP 4: POPULARITY AND VIRALITY METRICS
# ===============================================================================

# Load libraries
library(tidyverse)
library(lubridate)
library(here)

# Load cleaned data
cat("=== LOADING CLEANED DATA FOR POPULARITY ANALYSIS ===\n")
data_enhanced <- readRDS(here("data_clean/messages_clean.rds"))

# ===============================================================================
# SECTION 4.1: CHANNEL INFLUENCE ANALYSIS
# ===============================================================================

channel_influence_analysis <- function(data) {
  
  channel_stats <- data %>%
    group_by(username) %>%
    summarise(
      message_count = n(),
      avg_views = mean(views, na.rm = TRUE),
      total_views = sum(views, na.rm = TRUE),
      avg_message_length = mean(nchar(message), na.rm = TRUE),
      unique_channels = n_distinct(channel_id),
      first_message = min(timestamp, na.rm = TRUE),
      last_message = max(timestamp, na.rm = TRUE),
      activity_span_days = as.numeric(difftime(last_message, first_message, units = "days")),
      forwarded_count = sum(is_forwarded, na.rm = TRUE),
      replies_count = sum(is_reply, na.rm = TRUE),
      media_count = sum(has_media, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      influence_score = log1p(total_views) * log1p(message_count) * log1p(unique_channels),
      messages_per_day = ifelse(activity_span_days > 0, message_count / activity_span_days, message_count),
      engagement_ratio = (forwarded_count + replies_count) / message_count,
      media_usage_rate = media_count / message_count
    ) %>%
    arrange(desc(influence_score))
  
  # Top channels plot
  top_channels_plot <- channel_stats %>%
    slice_head(n = 20) %>%
    ggplot(aes(x = reorder(username, influence_score), y = influence_score)) +
    geom_col(fill = "#2C3E50") +
    coord_flip() +
    theme_minimal() +
    labs(
      title = "Top 20 Most Influential Channels",
      subtitle = "Ranked by composite influence score (views × messages × channel diversity)",
      x = "Channel Username",
      y = "Influence Score"
    )
  
  # Activity vs Reach plot
  activity_plot <- channel_stats %>%
    filter(message_count >= 10) %>%
    ggplot(aes(x = message_count, y = total_views)) +
    geom_point(alpha = 0.7, size = 3, color = "#E74C3C") +
    scale_x_log10() +
    scale_y_log10() +
    theme_minimal() +
    labs(
      title = "Channel Activity vs. Reach",
      subtitle = "Messages vs total views (log scale)",
      x = "Messages (log)",
      y = "Total Views (log)"
    )
  
  return(list(
    stats = channel_stats,
    top_channels_plot = top_channels_plot,
    activity_plot = activity_plot
  ))
}

# ===============================================================================
# SECTION 4.2: FORWARDED SOURCES ANALYSIS
# ===============================================================================

forwarded_analysis <- function(data) {
  
  forwarded_data <- data %>%
    filter(is_forwarded == TRUE) %>%
    group_by(fwd_from_author_username, fwd_from_author_type) %>%
    summarise(
      forward_count = n(),
      unique_forwarders = n_distinct(username),
      avg_views = mean(views, na.rm = TRUE),
      total_reach = sum(views, na.rm = TRUE),
      avg_message_length = mean(message_length, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      amplification_factor = total_reach / forward_count,
      virality_score = log1p(forward_count) * log1p(unique_forwarders) * log1p(amplification_factor)
    ) %>%
    arrange(desc(virality_score))
  
  # Top forwarded sources plot
  top_sources_plot <- forwarded_data %>%
    slice_head(n = 15) %>%
    ggplot(aes(x = reorder(fwd_from_author_username, virality_score), 
               y = virality_score, fill = fwd_from_author_type)) +
    geom_col() +
    coord_flip() +
    scale_fill_manual(values = c(
      "channel" = "#3498DB",
      "group"   = "#9B59B6",
      "bot"     = "#E67E22",
      "user"    = "#2ECC71"
    )) +
    theme_minimal() +
    labs(
      title = "Top 15 Most Viral Forwarded Sources",
      subtitle = "Ranked by virality score (forwards × forwarders × amplification)",
      x = "Original Author",
      y = "Virality Score"
    )
  
  # Forwarding behavior plot
  forwarding_behavior_plot <- forwarded_data %>%
    ggplot(aes(x = forward_count, y = unique_forwarders)) +
    geom_point(alpha = 0.7, size = 3, color = "#1ABC9C") +
    geom_smooth(method = "lm", se = TRUE, alpha = 0.3) +
    theme_minimal() +
    labs(
      title = "Forwarding Patterns Analysis",
      subtitle = "Forwards vs unique forwarders",
      x = "Total Forwards",
      y = "Unique Forwarders"
    )
  
  return(list(
    data = forwarded_data,
    top_sources_plot = top_sources_plot,
    forwarding_behavior_plot = forwarding_behavior_plot
  ))
}

# ===============================================================================
# SECTION 4.3: ENTITY ANALYSIS (MENTIONS & HASHTAGS)
# ===============================================================================

entity_analysis <- function(data) {
  
  entities_data <- data %>%
    mutate(
      mentions = str_extract_all(message, "@\\w+"),
      hashtags = str_extract_all(message, "#\\w+")
    )
  
  # Mentions
  mentions_analysis <- entities_data %>%
    unnest(mentions) %>%
    filter(!is.na(mentions)) %>%
    group_by(mentions) %>%
    summarise(
      mention_count = n(),
      unique_mentioners = n_distinct(username),
      avg_views = mean(views, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(mention_count))
  
  # Hashtags
  hashtags_analysis <- entities_data %>%
    unnest(hashtags) %>%
    filter(!is.na(hashtags)) %>%
    mutate(hashtags = tolower(hashtags)) %>%
    group_by(hashtags) %>%
    summarise(
      hashtag_count = n(),
      unique_users = n_distinct(author_username),
      unique_channels = n_distinct(channel_id),
      avg_views = mean(views, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(hashtag_count))
  
  # Mentions plot
  mentions_plot <- mentions_analysis %>%
    slice_head(n = 15) %>%
    ggplot(aes(x = reorder(mentions, mention_count), y = mention_count)) +
    geom_col(fill = "#2C3E50") +
    coord_flip() +
    theme_minimal() +
    labs(
      title = "Top 15 Most Mentioned Users",
      subtitle = "Frequency of user mentions",
      x = "Mention",
      y = "Mention Count"
    )
  
  # Hashtags plot
  hashtags_plot <- hashtags_analysis %>%
    slice_head(n = 15) %>%
    ggplot(aes(x = reorder(hashtags, hashtag_count), y = hashtag_count)) +
    geom_col(fill = "#E67E22") +
    coord_flip() +
    theme_minimal() +
    labs(
      title = "Top 15 Most Used Hashtags",
      subtitle = "Hashtag frequency",
      x = "Hashtag",
      y = "Usage Count"
    )
  
  return(list(
    mentions = mentions_analysis,
    hashtags = hashtags_analysis,
    mentions_plot = mentions_plot,
    hashtags_plot = hashtags_plot
  ))
}



# ===============================================================================
# RUN ANALYSIS
# ===============================================================================

# 4.1 Channels
channel_results <- channel_influence_analysis(data_enhanced)

# 4.2 Forwarded
forwarded_results <- forwarded_analysis(data_enhanced)

# 4.3 Entities
entity_results <- entity_analysis(data_enhanced)

# ===============================================================================
# SAVE OUTPUTS
# ===============================================================================

# Create main output folders
if (!dir.exists(here("outputs/popularity"))) {
  dir.create(here("outputs/popularity"), recursive = TRUE)
}

if (!dir.exists(here("outputs/popularity/entities"))) {
  dir.create(here("outputs/popularity/entities"), recursive = TRUE)
}

# Save channel plots
ggsave(here("outputs/popularity/top_channels.png"),
       plot = channel_results$top_channels_plot,
       width = 8, height = 5)

ggsave(here("outputs/popularity/channel_activity.png"),
       plot = channel_results$activity_plot,
       width = 8, height = 5)

write_csv(channel_results$stats, here("outputs/popularity/top_channels.csv"))

# Save forwarded plots
ggsave(here("outputs/popularity/forwarded_sources.png"),
       plot = forwarded_results$top_sources_plot,
       width = 8, height = 5)

ggsave(here("outputs/popularity/forwarding_behavior.png"),
       plot = forwarded_results$forwarding_behavior_plot,
       width = 8, height = 5)

write_csv(forwarded_results$data, here("outputs/popularity/top_forwarded.csv"))

# Save entity plots
ggsave(here("outputs/popularity/entities/top_mentions.png"),
       plot = entity_results$mentions_plot,
       width = 8, height = 5)

ggsave(here("outputs/popularity/entities/top_hashtags.png"),
       plot = entity_results$hashtags_plot,
       width = 8, height = 5)

write_csv(entity_results$mentions, here("outputs/popularity/entities/mentions.csv"))
write_csv(entity_results$hashtags, here("outputs/popularity/entities/hashtags.csv"))

cat("=== STEP 4 RESULTS SAVED TO /outputs/popularity/ ===\n")