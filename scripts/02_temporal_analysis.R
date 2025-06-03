# ===============================================================================
# SECTION 2: TEMPORAL ANALYSIS - INTERACTIVE PIPELINE VERSION
# ===============================================================================

# Load libraries
library(tidyverse)
library(lubridate)
library(here)

# Load cleaned data
cat("=== LOADING CLEANED DATA FOR TEMPORAL ANALYSIS ===\n")
data_enhanced <- readRDS(here("data_clean/messages_clean.rds"))

# Temporal data processing function
process_temporal_data <- function(data) {
  
  # Prepare temporal data
  data_temporal <- data %>%
    mutate(
      date = as.Date(timestamp),
      year_month = as.Date(floor_date(timestamp, "month")),
      year_week = floor_date(timestamp, "week"),
      hour = hour(timestamp),
      day_of_week = weekdays(timestamp),
      month = month(timestamp)
    )
  
  # Daily message volume analysis
  daily_counts <- data_temporal %>%
    group_by(date) %>%
    summarise(count = n(), .groups = "drop")
  
  # Weekly patterns analysis
  weekly_patterns <- data_temporal %>%
    group_by(day_of_week) %>%
    summarise(avg_count = n() / length(unique(date)), .groups = "drop")
  
  # Monthly aggregation analysis
  monthly_counts <- data_temporal %>%
    group_by(year_month) %>%
    summarise(count = n(), .groups = "drop")
  
  # Hourly patterns analysis
  hourly_patterns <- data_temporal %>%
    group_by(hour) %>%
    summarise(count = n(), .groups = "drop")
  
  # Return processed data only
  return(list(
    daily_data = daily_counts,
    weekly_data = weekly_patterns,
    monthly_data = monthly_counts,
    hourly_data = hourly_patterns
  ))
}

# Temporal visualization functions
create_daily_temporal_plot <- function(daily_data) {
  ggplot(daily_data, aes(x = date, y = count)) +
    geom_line(alpha = 0.7, linewidth = 1.2, color = "#1f77b4") +
    geom_smooth(method = "loess", se = TRUE, alpha = 0.3, color = "#ff7f0e") +
    theme_minimal() +
    labs(
      title = "Daily Message Volume Evolution",
      subtitle = "Complete dataset temporal analysis with trend line",
      x = "Date", 
      y = "Number of Messages"
    ) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      legend.position = "bottom"
    )
}

create_weekly_temporal_plot <- function(weekly_data) {
  ggplot(weekly_data, aes(x = day_of_week, y = avg_count)) +
    geom_col(fill = "#2ca02c", alpha = 0.8) +
    theme_minimal() +
    labs(
      title = "Weekly Activity Distribution",
      subtitle = "Average message frequency by day of week",
      x = "Day of Week",
      y = "Average Daily Messages"
    ) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      legend.position = "bottom"
    )
}

create_monthly_temporal_plot <- function(monthly_data) {
  ggplot(monthly_data, aes(x = year_month, y = count)) +
    geom_col(fill = "#d62728", alpha = 0.8) +
    scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
    theme_minimal() +
    labs(
      title = "Monthly Message Volume",
      subtitle = "Total monthly message distribution",
      x = "Month", 
      y = "Number of Messages"
    ) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "bottom"
    )
}

create_hourly_temporal_plot <- function(hourly_data) {
  ggplot(hourly_data, aes(x = hour, y = count)) +
    geom_line(linewidth = 1.2, alpha = 0.8, color = "#9467bd") +
    geom_point(size = 2, alpha = 0.7, color = "#9467bd") +
    scale_x_continuous(breaks = seq(0, 23, 2)) +
    theme_minimal() +
    labs(
      title = "Daily Activity Patterns",
      subtitle = "Message distribution by hour of day",
      x = "Hour of Day (24h format)", 
      y = "Total Messages"
    ) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      legend.position = "bottom"
    )
}

# Run processing
temporal_data <- process_temporal_data(data_enhanced)

# Display each temporal plot
cat("=== DISPLAYING TEMPORAL ANALYSIS PLOTS ===\n")

cat("1. Daily temporal evolution:\n")
print(create_daily_temporal_plot(temporal_data$daily_data))

cat("\n2. Weekly distribution patterns:\n") 
print(create_weekly_temporal_plot(temporal_data$weekly_data))

cat("\n3. Monthly volume distribution:\n")
print(create_monthly_temporal_plot(temporal_data$monthly_data))

cat("\n4. Hourly activity patterns:\n")
print(create_hourly_temporal_plot(temporal_data$hourly_data))

# Save daily plot
ggsave(here("outputs/temporal_analysis/temporal_trends.png"), 
       plot = create_daily_temporal_plot(temporal_data$daily_data),
       width = 6, height = 3.5)

# Save weekly plot
ggsave(here("outputs/temporal_analysis/weekly_patterns.png"), 
       plot = create_weekly_temporal_plot(temporal_data$weekly_data),
       width = 6, height = 3.5)

# Save monthly plot
ggsave(here("outputs/temporal_analysis/monthly_patterns.png"), 
       plot = create_monthly_temporal_plot(temporal_data$monthly_data),
       width = 6, height = 3.5)

# Save hourly plot
ggsave(here("outputs/temporal_analysis/hourly_patterns.png"), 
       plot = create_hourly_temporal_plot(temporal_data$hourly_data),
       width = 6, height = 3.5)

cat("=== TEMPORAL PLOTS SAVED TO /outputs/temporal_analysis/ ===\n")
