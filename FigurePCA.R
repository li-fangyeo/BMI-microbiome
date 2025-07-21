#Beta
#PLOT
library(scater)
tse<- tse %>%  mia::agglomerateByRank(rank = "Species") %>% 
  mia::transformAssay(method = "relabundance") %>%
  scater::runMDS(FUN = getDissimilarity,
                 assay.type = "relabundance",
                 method = "bray",
                 na.action = na.exclude,
                 name = "MDS_bray")

# Create ggplot object
p <- plotReducedDim(tse, "MDS_bray", colour_by = "BMI_Category")

# Calculate explained variance
e <- attr(reducedDim(tse, "MDS_bray"), "eig")
rel_eig <- e / sum(e[e > 0])

# Add explained variance for each axis
p <- p + labs(
  x = paste("PCoA 1 (", round(100 * rel_eig[[1]], 1), "%", ")", sep = ""),
  y = paste("PCoA 2 (", round(100 * rel_eig[[2]], 1), "%", ")", sep = "")
)

p<- p +
  ggplot2::theme_classic() +
  ggplot2::theme(
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16))
plot(p)
ggplot2::ggsave(filename = "PCoA_BMI.pdf", 
                plot = p,
                #dpi = 300,
                width = 10,
                height = 8,
                units = "in" )

#PCA
tse <- tse %>% mia::transformAssay(method = "clr", pseudocount = 1)
tse <- runPCA(
  tse,
  name = "PCA", 
  assay.type = "clr", 
  ncomponents = 10
)

colData(tse)$BMI_Category <- cut(colData(tse)$BMI,
                                 breaks = c(-Inf, 18.5, 24.9, 29.9, 39.9, Inf),
                                 labels = c("Underweight", "Normal", 
                                            "Overweight", "Obese", 
                                            "Morbid Obesity"))
h<- plotReducedDim(tse, "PCA", colour_by = "BMI_Category")

my_colors <- c("#434247","#0A9396","#EE9800","#CA6702", "firebrick")
h<- h +
  ggplot2::theme_classic() +
  ggplot2::theme(
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16)) +
  scale_color_manual(values = my_colors) +
  labs(color = "BMI Category")  

h
ggplot2::ggsave(filename = "PCA_BMI.pdf", 
                plot = h,
                #dpi = 300,
                width = 12,
                height = 10,
                units = "in" )
