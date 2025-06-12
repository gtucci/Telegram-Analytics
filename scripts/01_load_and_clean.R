# ===============================================================================
# STEP 1: DATA PREPARATION AND PREPROCESSING
# ===============================================================================

# Load libraries
library(tidyverse)
library(lubridate)
library(stringr)
library(data.table)
library(janitor)
library(here)
library(config)
library(rstudioapi)

# --- LOG START TIME ---
cat("=== START TIME: ", Sys.time(), " ===\n")

# --- ASK USER: FOLDER OR FILE ---

cat("Do you want to load:\n")
cat("1 = Folder (merge all CSV/TSV)\n")
cat("2 = Single file (CSV or TSV)\n")
choice <- readline(prompt = "Enter 1 or 2: ")

if (choice == "1") {
  # User chooses folder
  folder_path <- rstudioapi::selectDirectory(caption = "Select Folder Containing CSV or TSV Files")
  
  if (is.null(folder_path)) {
    stop("No folder selected. Stopping.")
  }
  
  cat("=== SELECTED FOLDER: ", folder_path, " ===\n")
  
  # List CSV/TSV files
  file_list <- list.files(folder_path, pattern = "\\.(csv|tsv)$", full.names = TRUE)
  
  if (length(file_list) == 0) {
    stop("No CSV/TSV files found in folder ", folder_path)
  }
  
  cat("=== FILES TO LOAD FROM FOLDER ===\n")
  print(file_list)
  
  # Read and merge all
  data <- map_df(file_list, ~ fread(.x, encoding = "UTF-8") %>% clean_names() %>%
                   mutate(across(where(is.character), ~ iconv(., from = "", to = "UTF-8"))))
  
} else if (choice == "2") {
  # User chooses single file
  file_path <- rstudioapi::selectFile(caption = "Select CSV or TSV File", filter = "Text Files (*.csv; *.tsv)")
  
  if (is.null(file_path)) {
    stop("No file selected. Stopping.")
  }
  
  cat("=== SELECTED FILE: ", file_path, " ===\n")
  
  # Detect extension
  extension <- tools::file_ext(file_path)
  
  if (extension == "csv" || extension == "tsv") {
    data <- fread(file_path, encoding = "UTF-8") %>%
      clean_names() %>%
      mutate(across(where(is.character), ~ iconv(., from = "", to = "UTF-8")))
  } else {
    stop("Unsupported file type: ", extension)
  }
  
} else {
  stop("Invalid choice! Please enter 1 or 2.")
}

cat("=== TOTAL ROWS LOADED: ", nrow(data), " ===\n")
  
# --- CHECK EXPECTED COLUMNS ---

expected_columns <- c(
  "id", 
  "channel_id", 
  "username", 
  "message", 
  "timestamp", 
  "type",
  "country", 
  "language", 
  "category", 
  "views", 
  "media_type",
  "media_description", 
  "media_filename", 
  "author_type", 
  "author_id",
  "author_username", 
  "author_name",
  "reply_to_author_type", 
  "reply_to_author_id", 
  "reply_to_author_username", 
  "reply_to_author_name",
  "fwd_from_author_type", 
  "fwd_from_author_id", 
  "fwd_from_author_username", 
  "fwd_from_author_name"
)

cat("=== COLUMNS DETECTED IN DATASET ===\n")
print(colnames(data))

missing_columns <- setdiff(expected_columns, colnames(data))

if (length(missing_columns) > 0) {
  stop(paste(
    "ERROR: The following required columns are missing from the dataset:",
    paste(missing_columns, collapse = ", ")
  ))
} else {
  cat("All expected columns are present.\n")
}


# --- ENHANCED DATA PREPARATION ---

data_enhanced <- data %>%
  mutate(
    timestamp = as.POSIXct(timestamp),
    message_clean = message %>%
      str_remove_all("https?://\\S+\\s?") %>%
      str_remove_all("@\\w+") %>%
      str_remove_all("#\\w+") %>%
      tolower() %>%
      str_replace_all("[^\\p{L}\\s]", " ") %>%
      str_squish(),
    message_length = nchar(message),
    word_count = str_count(message, "\\S+"),
    has_media = media_type != "" & !is.na(media_type),
    is_forwarded = fwd_from_author_username != "" & !is.na(fwd_from_author_username),
    is_reply = reply_to_author_username != "" & !is.na(reply_to_author_username),
    date = as.Date(timestamp),
    hour = hour(timestamp),
    day_of_week = weekdays(timestamp),
    month = month(timestamp),
    year = year(timestamp)
  )

# --- BASIC DATASET STATISTICS ---

cat("=== DATASET OVERVIEW ===\n")
basic_stats <- data_enhanced %>%
  summarise(
    total_messages = n(),
    unique_channels = n_distinct(channel_id),
    date_range_start = min(timestamp, na.rm = TRUE),
    date_range_end = max(timestamp, na.rm = TRUE),
    avg_message_length = round(mean(message_length, na.rm = TRUE), 1),
    avg_word_count = round(mean(word_count, na.rm = TRUE), 1),
    total_views = sum(views, na.rm = TRUE),
    messages_with_media = sum(has_media, na.rm = TRUE),
    forwarded_messages = sum(is_forwarded, na.rm = TRUE),
    reply_messages = sum(is_reply, na.rm = TRUE)
  )

print(basic_stats)

write_csv(basic_stats, here("outputs/overview/dataset_overview.csv"))

# --- SAVE CLEANED DATA ---

write_csv(data_enhanced, here("data_clean/messages_clean.csv"))
saveRDS(data_enhanced, here("data_clean/messages_clean.rds"))

cat("=== CLEANED DATA SAVED ===\n")

# --- LOG END TIME ---
cat("=== END TIME: ", Sys.time(), " ===\n")
