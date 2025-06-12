# ===============================================================================
# STEP 6: TOPIC MODELING (FINAL VERSION WITH USER INPUTS)
# ===============================================================================

# Load libraries
library(tidyverse)
library(tidytext)
library(topicmodels)
library(tm)
library(here)
library(wordcloud)


# Load cleaned data
cat("=== LOADING CLEANED DATA FOR TOPIC MODELING ===\n")
data_enhanced <- readRDS(here("data_clean/messages_clean.rds"))

# Create output folder
if (!dir.exists(here("outputs/topic_modeling"))) {
  dir.create(here("outputs/topic_modeling"), recursive = TRUE)
}

# ===============================================================================
# USER INPUTS
# ===============================================================================

# Number of topics
num_topics <- as.integer(readline(prompt = "Enter number of topics (e.g. 5, 7, 10): "))
cat("=== Running topic modeling with", num_topics, "topics ===\n")

# Stopwords languages
stopword_langs <- readline(prompt = "Enter stopword languages (comma-separated, e.g. 'pt,en,es'): ")
stopword_langs <- str_split(stopword_langs, pattern = ",")[[1]] %>% str_trim()

# Load stopwords for selected languages
custom_stopwords <- map_df(stopword_langs, ~ get_stopwords(language = .x))

# Manual stopwords
manual_stopwords <- readline(prompt = "Enter additional stopwords (comma-separated), or leave blank: ")

if (manual_stopwords != "") {
  manual_stopwords <- str_split(manual_stopwords, pattern = ",")[[1]] %>% str_trim()
  manual_stopwords_df <- tibble(word = manual_stopwords)
  custom_stopwords <- bind_rows(custom_stopwords, manual_stopwords_df)
}

cat("=== Total stopwords loaded:", nrow(custom_stopwords), "===\n")

# ===============================================================================
# STEP 1: Prepare text data
# ===============================================================================

# Tokenization
tokens <- data_enhanced %>%
  select(id, message_clean) %>%
  unnest_tokens(word, message_clean)

# Remove stopwords + short words
tokens <- tokens %>%
  anti_join(custom_stopwords, by = "word") %>%
  filter(str_length(word) > 2)

# ===============================================================================
# STEP 2: Create Document-Term Matrix
# ===============================================================================

dtm <- tokens %>%
  count(id, word) %>%
  cast_dtm(document = id, term = word, value = n)

cat("=== DTM created: ", nrow(dtm), " documents, ", ncol(dtm), " terms ===\n")

# ===============================================================================
# STEP 3: Run LDA
# ===============================================================================

set.seed(1234)  # Reproducibility
lda_model <- LDA(dtm, k = num_topics, control = list(seed = 1234))

# ===============================================================================
# STEP 4: Extract topic terms
# ===============================================================================

topic_terms <- tidy(lda_model, matrix = "beta")

# Top terms per topic
top_terms <- topic_terms %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>%
  ungroup() %>%
  arrange(topic, -beta)

# Save
write_csv(top_terms, here("outputs/topic_modeling/topic_terms.csv"))

cat("=== TOPIC TERMS SAVED ===\n")

# ===============================================================================
# STEP 5: Extract document-topic assignments
# ===============================================================================

doc_topics <- tidy(lda_model, matrix = "gamma")

# Most likely topic per document
doc_assignments <- doc_topics %>%
  group_by(document) %>%
  slice_max(gamma, n = 1) %>%
  ungroup()

# Save
write_csv(doc_assignments, here("outputs/topic_modeling/document_topics.csv"))

cat("=== DOCUMENT TOPICS SAVED ===\n")

# ===============================================================================
# END OF STEP 6
# ===============================================================================

cat("=== STEP 6 COMPLETE ===\n")

# ===============================================================================
# STEP 7: WORD CLOUDS PER TOPIC
# ===============================================================================

# Create output folder for word clouds
cloud_folder <- here("outputs/topic_modeling/wordclouds")
if (!dir.exists(cloud_folder)) dir.create(cloud_folder, recursive = TRUE)

# Loop through topics and generate word cloud
unique_topics <- sort(unique(topic_terms$topic))

for (t in unique_topics) {
  topic_df <- topic_terms %>%
    filter(topic == t) %>%
    arrange(desc(beta)) %>%
    slice_max(beta, n = 50)  # Top 50 terms
  
  png(filename = file.path(cloud_folder, paste0("topic_", t, "_wordcloud.png")),
      width = 1200, height = 800, res = 200)
  
  wordcloud(words = topic_df$term,
            freq = topic_df$beta,
            max.words = 50,
            random.order = FALSE,
            colors = brewer.pal(8, "Dark2"))
  
  dev.off()
  
  cat("Word cloud saved for topic", t, "\n")
}

