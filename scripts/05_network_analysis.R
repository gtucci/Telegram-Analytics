# ===============================================================================
# STEP 5: NETWORK ANALYSIS (FINAL VERSION - CSV ONLY - NODES + EDGES)
# ===============================================================================

# Load libraries
library(tidyverse)
library(igraph)
library(here)

# Load cleaned data
cat("=== LOADING CLEANED DATA FOR NETWORK ANALYSIS ===\n")
data_enhanced <- readRDS(here("data_clean/messages_clean.rds"))

# Create output folder
if (!dir.exists(here("outputs/networks"))) {
  dir.create(here("outputs/networks"), recursive = TRUE)
}

# ===============================================================================
# SECTION 5.1: FORWARDING NETWORK
# ===============================================================================

cat("=== BUILDING FORWARDING NETWORK ===\n")

forwarding_edges <- data_enhanced %>%
  filter(is_forwarded == TRUE, !is.na(fwd_from_author_username), fwd_from_author_username != "") %>%
  group_by(source = fwd_from_author_username, target = username) %>%
  summarise(weight = n(), .groups = "drop")

# Build graph
forwarding_graph <- graph_from_data_frame(forwarding_edges, directed = TRUE)

# Nodes table
forwarding_nodes <- tibble(
  id = V(forwarding_graph)$name,
  label = V(forwarding_graph)$name,
  degree = degree(forwarding_graph, mode = "all"),
  indegree = degree(forwarding_graph, mode = "in"),
  outdegree = degree(forwarding_graph, mode = "out"),
  pagerank = page_rank(forwarding_graph)$vector,
  type = "chat"  # All nodes are chats
)

# Save outputs
write_csv(forwarding_edges, here("outputs/networks/forwarding_edges.csv"))
write_csv(forwarding_nodes, here("outputs/networks/forwarding_nodes.csv"))

cat("=== FORWARDING NETWORK SAVED ===\n")

# ===============================================================================
# SECTION 5.2: MENTIONS NETWORK
# ===============================================================================

cat("=== BUILDING MENTIONS NETWORK ===\n")

mentions_edges <- data_enhanced %>%
  mutate(mentions = str_extract_all(message, "@\\w+")) %>%
  unnest(mentions) %>%
  filter(!is.na(mentions), mentions != "") %>%
  group_by(source = username, target = mentions) %>%
  summarise(weight = n(), .groups = "drop")

# Build graph
mentions_graph <- graph_from_data_frame(mentions_edges, directed = TRUE)

# Nodes table
mentions_nodes <- tibble(
  id = V(mentions_graph)$name,
  label = V(mentions_graph)$name,
  degree = degree(mentions_graph, mode = "all"),
  indegree = degree(mentions_graph, mode = "in"),
  outdegree = degree(mentions_graph, mode = "out"),
  pagerank = page_rank(mentions_graph)$vector,
  type = case_when(
    id %in% mentions_edges$source ~ "chat",
    id %in% mentions_edges$target ~ "mention",
    TRUE ~ "unknown"
  )
)

# Save outputs
write_csv(mentions_edges, here("outputs/networks/mentions_edges.csv"))
write_csv(mentions_nodes, here("outputs/networks/mentions_nodes.csv"))

cat("=== MENTIONS NETWORK SAVED ===\n")

# ===============================================================================
# SECTION 5.3: CHANNEL-HASHTAG NETWORK
# ===============================================================================

cat("=== BUILDING CHANNEL-HASHTAG NETWORK ===\n")

hashtags_edges <- data_enhanced %>%
  mutate(hashtags = str_extract_all(message, "#\\w+")) %>%
  unnest(hashtags) %>%
  filter(!is.na(hashtags), hashtags != "") %>%
  mutate(hashtags = tolower(hashtags)) %>%
  group_by(source = username, target = hashtags) %>%
  summarise(weight = n(), .groups = "drop")

# Build graph
hashtags_graph <- graph_from_data_frame(hashtags_edges, directed = TRUE)

# Nodes table
hashtags_nodes <- tibble(
  id = V(hashtags_graph)$name,
  label = V(hashtags_graph)$name,
  degree = degree(hashtags_graph, mode = "all"),
  indegree = degree(hashtags_graph, mode = "in"),
  outdegree = degree(hashtags_graph, mode = "out"),
  pagerank = page_rank(hashtags_graph)$vector,
  type = case_when(
    id %in% hashtags_edges$source ~ "chat",
    id %in% hashtags_edges$target ~ "hashtag",
    TRUE ~ "unknown"
  )
)

# Save outputs
write_csv(hashtags_edges, here("outputs/networks/channel_hashtags_edges.csv"))
write_csv(hashtags_nodes, here("outputs/networks/channel_hashtags_nodes.csv"))

cat("=== CHANNEL-HASHTAG NETWORK SAVED ===\n")

# ===============================================================================
# END OF STEP 5
# ===============================================================================

cat("=== STEP 5 COMPLETE ===\n")
