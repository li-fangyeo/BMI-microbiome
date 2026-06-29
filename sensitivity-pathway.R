#Sensitivity analysis - species-associated pathways
#07042026

#data
irn #sig pathways after validation = 347
dicho #sig pathways after validation = 324

#Make a dataframe of overlapping pathways 
irn %>% 
  dplyr::inner_join(dicho, by = "Pathway") %>%
  DT::datatable(caption = "Significant in both")

##Statins and metformin
a <- readRDS("../data/tse_mgs-20241118_104759.rds") %>%
  colData() %>%
  as.data.frame()

a %>% select(c("PREVAL_RX_A10BA", "PREVAL_RX_C10AA")) %>%
  table()

vars <- list(BL_AGE = "Age",
             MEN = "Men",
             BMI = "BMI",
             VYOTARO = "Waist circ",
             WHR = "waist-hip ratio",
             PREVAL_DIAB = "Diabetes",
             PREVAL_CVD = "Prevalent cardiovascular disease",
             CURR_SMOKE = "Smoking",
             ALKI2_FR02 = "Alcohol consumption per week (g)",
             HFC = "Healthy food choices",
             Q57X = "Exercise",
             shannon = "Shannon diversity",
             observed = "Observed richness",
             EAST = "Eastern finland",
             total_reads = "Total reads",
             PREVAL_RX_C10AA = "Statin-users",
             PREVAL_RX_A10BA = "Met-users")

tse <- readRDS("../data/tse_mgs-20241118_104759.rds") %>%
  mia::transformAssay(assay.type = "counts", method = "relabundance") %>% 
  mia::addAlpha(assay.type = "counts", index = c("shannon", "observed"), name = c("shannon", "observed")) %>%
  tse_add_food_score(HFC) %>%
  tse_mutate(dplyr::across(c(MEN,
                             CURR_SMOKE,
                             EAST,
                             Q57X,
                             dplyr::contains("INCIDENT"),
                             dplyr::contains("PREVAL")), as.factor)) %>% 
  tse_mutate(dplyr::across(c(shannon,
                             observed,
                             total_reads), as.numeric)) %>%
  #pregnant
  tse_filter(GRAVID %in% c(1, NA)) %>%
  #antibiotic use in the past 1 month
  tse_filter(BL_USE_RX_J01_1mo %in% c(0, NA)) %>%
  #missing covariate
  tse_filter(dplyr::if_all(dplyr::one_of(names(vars)), not_na)) %>%
  #low reads
  tse_filter(total_reads > 50000) %>%
  #filter for covariates
  tse_select(names(vars)) 

stats
no_statins

test <- no_statins %>% inner_join(stats, join_by(taxa), suffix = c("_ori", "_+statins"),)

test <- tse %>% agglomerateByPrevalence(detection = 0.1/100,
                                       prevalence = 5/100,
                                       rank = "Family")

summarizeDominance(test, rank = "Species")

b <- getPrevalent(test, rank = "Species", prevalence = 0.05, detection = 0.001)
summary(test, assay.type = "counts")

plot_abundance <- plotAbundance(test, abund_values="relabundance", rank = "Genus") +
  theme(legend.key.height = unit(0.5, "cm")) +
  scale_y_continuous(label = scales::percent)

# Calculate mean of relative abundance
mean_abund <- rowMeans(assay(test, "counts"))

# Add mean values to rowData for easy viewing
rowData(test)$mean_abundance <- mean_abund

a<- rowData(test)$mean_abundance
write.csv(a, "mean.csv")
