# Microbiome and obesity
Cross sectional, association analysis between obesity indicators (BMI and waist-hip ratio) and gut microbiome in FINRISK 2002. 
Using eastern finland as discovery cohort, validating significant taxa in western finland.

1) Alpha diversity
2) Beta diversity
3) Bacteroidota:Firmicutes ratio
4) Taxa differential abundance analysis
5) Predicted pathway analysis
6) External validation

## Code files
1. MainAnalysis.rmd
2. beta.rmd
3. Functional.rmd
4. BF_ratio.R
5. Figures
6. FR07.rmd

## Getting started
- Cohort: FINRISK 2002 cohort were split into east (discovery) and west (validation) cohorts; FINRISK 2007 cohort was used to externally validate taxa and pathways significant in western FR02 cohort. 
- Exposure variable: gut microbiota abundances
- Outcome variable: Obesity indicators (namely BMI, WHR)
- Covariate: diabetes, cardiovascular disease, smoking, alcohol consumption per week, healthy food choices, exercise
- Exclusion criteria: antibiotics use 1 month prior to stool collection, pregnant, metagenomic reads < 50,000

### Discovery cohort
Eastern finland cohort, n = 3906

Alpha diversity using shannon index (measures evenness) and observed species (measures richness), with rarefaction of 10 iterations (niter = 10). Obesity indicators and alpha metric were scaled so that the BMI, WC and WHR are comparable.

Differential abundance analysis was done using linear models, corrected for covariates. Taxa were filtered to be at the species level, at detection level of 0.1% and prevalence of 5%, and centre-log transformed.

Significance level was at FDR corrected p-value < 0.05.

### Validation cohort
Western finland cohort, n = 1940

Microbiota data was filtered to only keep significant taxa found in the discovery cohort. And the same linear models, corrected for covariates, were used to validate association signals. 

No. of significant taxa after FDR correction:
| Indicator | Discovery | Validation |
| --------- | --------- | ---------- |
| BMI       | 164       | 132        |
| Waist cm  | 159       | 120        |
| WHR       | 149       | 105        |

-Note: Waist circumference was later removed from analysis because it did not add much insight.

### External validation cohort
External validation cohort, n = 275
Microbiota abundance table was filtered to only keep significant taxa validated in the Western Finland cohort.



