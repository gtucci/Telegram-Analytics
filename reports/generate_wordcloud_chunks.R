library(magick)
library(stringr)
library(here)
library(cowplot)

files <- list.files(
  here("outputs", "topic_modeling", "wordclouds"),
  pattern = "^topic_\\d+_wordcloud\\.png$",
  full.names = TRUE
)
topic_ids <- str_extract(files, "\\d+") |> as.integer()
files <- files[order(topic_ids)]


image_plots <- lapply(seq_along(files), function(i) {
  img <- magick::image_read(files[i])
  ggdraw() +
    draw_image(img, scale = 1) +
    draw_label(paste("Topic", topic_ids[i]), y = 1, vjust = 1.5, fontface = "bold", size = 12)
})


n_cols <- 3
combined_plot <- plot_grid(plotlist = image_plots, ncol = n_cols)


out_path <- here("outputs", "topic_modeling", "combined_wordclouds_grid.png")
ggsave(out_path, combined_plot, width = 12, height = 4 * ceiling(length(image_plots) / n_cols), dpi = 300)

