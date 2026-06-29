##Circular heatmap
library(ggplot2)
library(dplyr)
library(tibble)

#original FR02 significant pathways
sigfunc <- read.table("SigPathway.csv", sep = ",", header = TRUE)
#F07 validated significant pathways
sigfunc <- read.table("functional-IRN-FR07.csv", sep = ",", header = TRUE)

e <-sigfunc %>%
  filter(p.value < 0.05) %>%
  group_by(LevelTwo) %>%
  mutate(count = n()) %>%
  ungroup() %>%
  mutate(pathway2 = ifelse(count < 2, "Others", LevelTwo)) %>%
  select(-count)%>% 
  arrange(pathway2, Pathway) %>%
  mutate(Pathway = factor(Pathway, levels = unique(Pathway)))


# Create the circular bar plot
A<- ggplot(e, aes(x = factor(Pathway), y = estimate, fill = pathway2)) +
  geom_bar(stat = "identity", width = 1, color = "black") +
  coord_polar(start = 0) +
  theme_classic() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.major.y = element_line(color = "lightgrey", linewidth = 0.2),
    axis.title = element_blank(),
    axis.line = element_blank(),http://127.0.0.1:15189/graphics/plot_zoom_png?width=2512&height=1260
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  ) +
  scale_fill_brewer(palette = "Spectral", name = "Pathway class")

A
##Top 20 functional pathway dotplot
et<- sigfunc %>% 
  arrange(LevelTwo) %>%
  filter(p.value < 0.05) %>%
  #slice_head(n=20) %>%
  select(Pathway, LevelTwo, estimate, p.value) %>%
  mutate(Pathway = factor(Pathway, levels = Pathway))

funcolor<- c("Cell wall biosynthesis" = "#D53E4F", "Carrier biosynthesis" = "#F46D43", 
             "Protein biosynthesis" = "#3288BD", "Folate precursor" = "#FDAE61",
             "Others" ="#ABDDA4" , "Phospholipid biosynthesis" = "#66C2A5", 
             "Nucleotide biosynthesis" = "yellow", "Terpenoid biosynthesis" = "#5E4FA2")
# Create the dot plot
B<- ggplot(et, aes(x = estimate, y = Pathway, color = LevelTwo, size = p.value)) +
  geom_point() +
  scale_size_continuous(range = c(15, 5),
                        breaks = c(0.01, 0.04),
                        labels = c("<0.01", "<0.05")
  ) +
  labs(
    x = "Estimate",
    y = "Pathway",
    color = "Class",
    size = "P-value"
  ) +
  theme_classic() +
  scale_color_manual(values = funcolor) +
  theme(
    text = element_text(color = "black"),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16))

library(patchwork)
nested <- (A / B) +
  plot_annotation(tag_levels = 'A')
nested
ggplot2::ggsave(filename = "pathway.pdf", 
                plot = B,
                #dpi = 300,
                width = 18,
                height = 10,
                units = "in" )

