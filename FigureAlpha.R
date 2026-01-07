library(dplyr)
library(ggpubr)
library(purrr)
library(ggsignif)
library(mia)

#Alpha as continuous
#Scatterplot
colData(tse)$BMI_Category <- cut(colData(tse)$BMI,
                                 breaks = c(-Inf, 18.5, 24.9, 29.9, 39.9, Inf),
                                 labels = c("Underweight (n=40)", "Normal (n=2137)", 
                                            "Overweight (n=2401)", "Obese (n=1202)", 
                                            "Morbid Obesity (n=66)"))
a<- tse %>% colData() %>% as.data.frame()

a$BMI_cat <- cut(a$BMI,
                 breaks = c(-Inf, 18.5, 25, 30, 40, Inf),
                 labels = c("Underweight", "Normal", "Overweight", "Obese", "Morbid Obesity"))

my_colors <- c("#d4a1a1", "#FFCC00", "#FF9900",  "#990000", "black")
p<-ggplot(a, aes(x = BMI, y = shannon, colour = BMI_Category)) +
  geom_point() +
  theme_classic() +
  scale_colour_manual(values = my_colors)
p

ggsave("alpha.pdf", 
       plot = p, 
       width = 8, 
       height = 6, 
       units = "in")

#Violin plot
# For significance testing, all different combinations are determined
comb <- split(t(combn(levels(a$BMI_Category), 2)), 
              seq(nrow(t(combn(levels(a$BMI_Category), 2)))))


pvals <- purrr::map_dbl(comb, ~ wilcox.test(shannon ~ BMI_Category, data = a %>% filter(BMI_Category %in% .x))$p.value)

# Apply FDR correction
pvals_adj <- p.adjust(pvals, method = "fdr")

# Filter only significant comparisons
significant_comparisons <- comb[pvals_adj < 0.05]

my_colors <- c("lightgrey", "#c2c6cb", "#868c96", "#495362", "#0c192d")


# Plot with only significant annotations
p<- ggplot(a, aes(x = BMI_Category, y = shannon, fill = BMI_Category)) +
  geom_violin() + 
  geom_boxplot(width = 0.1, outlier.shape = NA) + 
  theme_classic(base_size = 16) +
  scale_fill_manual(values = my_colors) +
  geom_signif(comparisons = significant_comparisons, map_signif_level = TRUE,
              step_increase = 0.1) +
  labs(
    x = "BMI category",
    y = "Shannon index",
    fill = "BMI category") +
  theme(legend.position="none",
        axis.text.x = element_text(angle = 45, hjust=1),
        axis.title.x = element_blank(),
        text = element_text(color = "black"))
  


library(DataExplorer)
plot_intro(a)
plot_bar(a)
plot_histogram(a)
plot_correlation(na.omit(a), maxcat = 5L)


  
