#test to find Turibacater
tse_t <- tse %>% mia::agglomerateByPrevalence(detection = args$detection,
                                              prevalence = args$prevalence,
                                              as_relative = TRUE)
selected <- rowData(tse_t)$Genus %in% c("Akkermansia") &
  !is.na(rowData(tse_t)$Genus)
tse_sub <- tse[selected, ]
tse_sub
assays(tse_sub)$counts
assays(tse_sub)$relabundance

library(knitr)
library(dplyr)
library(mia)
#Bacteroidetes:Firmicutes ratio 
tse <- readRDS("tse_rda.rds")
tse <- tse %>% mia::agglomerateByRank("Phylum")

rowData(tse)$Phylum |> table()|> kable()

#Firmicutes
phlya <- c("Firmicutes_A", "Firmicutes_B_370514", "Firmicutes_B_370516", "Firmicutes_B_370518",
           "Firmicutes_B_370520", "Firmicutes_B_370525", "Firmicutes_B_370527",
           "Firmicutes_B_370529", "Firmicutes_B_370531", "Firmicutes_B_370533", 
           "Firmicutes_B_370537","Firmicutes_B_370539", "Firmicutes_B_370541", 
           "Firmicutes_B_370543", "Firmicutes_C", "Firmicutes_D", "Firmicutes_E", 
           "Firmicutes_F", "Firmicutes_G", "Firmicutes_H")


#copilot
firm_rows <- rowData(tse)$Phylum %in% phlya & !is.na(rowData(tse)$Phylum)
firm_counts <- colSums(assay(tse, "counts")[firm_rows, , drop = FALSE])

bact_rows <- rowData(tse)$Phylum == "Bacteroidota"
bact_counts <- colSums(assay(tse, "counts")[bact_rows, , drop = FALSE])

total_counts <- colSums(assay(tse, "counts"))

firm_rel <- firm_counts / total_counts
bact_rel <- bact_counts / total_counts

#FB ratio
BF_ratio <- bact_rel/firm_rel 
BF_ratio[!is.finite(BF_ratio)] <- 1e6

colData(tse)$BF_ratio <- BF_ratio
summary(colData(tse)$BF_ratio)

df <- as.data.frame(colData(tse))
BF <- lm(
  scale(WHR) ~ BF_ratio + BL_AGE + MEN +
    PREVAL_DIAB + PREVAL_CVD + CURR_SMOKE +
    ALKI2_FR02 + HFC + Q57X,
  data = df
)
summary(BF)

model_summary <- summary(BF) 
coef_table <- model_summary$coefficients
coef_table <- round(coef_table, 3)
write.csv(coef_table, "BF_results_WHR.csv", row.names = TRUE)
