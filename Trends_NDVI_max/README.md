---
title: "Script_trends_annualNDVImax"
output:
  html_document: default
  pdf_document: default
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Introduction

This is an R Markdown document to perform the stage 1 of the article published in JGR:Biogeosciences "Low-mountain grasslands under the stress of Climate Change" (Herrault_et_al_2023). 

- Calculate NDVI max trends
- Enhance the output table
- Create Histograms and barplots

## Calculate annual NDVImax trends

```{r setup1 }

# Load necessary libraries
library(ggplot2)
library(gridExtra)
library(wql)

# Read the CSV file "Table_NDVImax_annual.csv" into the data frame W
W = read.csv("Table_NDVImax_annual.csv")
## Column names and definition
# ID = ID pixels
# x = coordinate x of the pixel centroid
# y = coordinate y of the pixel centroid
# pkv = peak of value
# date = year

# Extract unique IDs from the data frame
id = unique(W$ID)

# Initialize an empty list to store results for each ID
list_res = list()

# Loop through each unique ID to perform Mann-Kendall trend test on the "pkv" variable
for (i in 1:length(id)) {
  # Subset the data for the current ID and select relevant columns ("year" and "pkv")
  top = W[W$ID == id[i], c("date", "pkv")]

  # Create a time series object from the "pkv" variable for the current ID
  pkv.time_serie <- ts(top$pkv, start = 2000, end = 2020, frequency = 1)

  # Apply the Mann-Kendall trend test to the time series
  pkv_mannken = mannKen(pkv.time_serie)

  # Create a data frame with results for the current ID
  res = data.frame(id[i], pkv_mannken$p.value, pkv_mannken$sen.slope)
  
  # Set column names for the result data frame
  colnames(res) = c("ID", "pval_mann", "slope_theil")

  # Store the result data frame in the list
  list_res[[i]] = res
}

# Combine all result data frames into a single data frame M
M = do.call(rbind, list_res)
```

## Enhance the output table

```{r setup2 }

# Assign a default class of 0 to all rows in the 'M' data frame
M$class = 0

# Update class values based on conditions
# Class 2: p-value < 0.05 and negative slope
M$class[M$pval_mann < 0.05 & M$slope_theil < 0] = 2

# Class 3: p-value < 0.05 and positive slope
M$class[M$pval_mann < 0.05 & M$slope_theil > 0] = 3

# Class 1: p-value > 0.05 (no significant trend)
M$class[M$pval_mann > 0.05] = 1

# Read another CSV file "table_info.csv" into the data frame 'X'
X = read.csv("table_info.csv")
## Column names and definition
# LandCover = Dominant land cover in the pixel (shrubs or herbaceous)

# Merge the 'M' and 'X' data frames based on the common column "ID"
ET = merge(M, X, by = "ID")
```

## Create the graphics

```{r setup3}
# Create a copy of the 'ET' data frame for graphics purposes
ET_graphics = ET

# Plot a histogram for the 'slope_theil' variable with different colors based on 'class'
g1 = ggplot(ET_graphics, aes(x = slope_theil, fill = as.factor(class))) +
  geom_histogram(position = "identity", alpha = 0.8, bins = 50) +
  scale_fill_manual(name = "", values = c("black", "brown2", "mediumseagreen"),
                    labels = c("p = ns", "slope < 0 and p < 0.05", "slope > 0 and p < 0.05")) +
  xlab("") +
  ylab("") +
  theme_minimal() +
  theme(text = element_text(size = 16, family = 'Lato'))

# Create a subset of the data frame 'M' based on the 'LandCover' variable
M_1 = data.frame(table(M$class[ET_graphics$LandCover == "Herbaceous"]))
M_2 = data.frame(table(M$class[ET_graphics$LandCove == "Shrubs"]))
M_sub = rbind(M_1, M_2)
M_sub$class = c("Herbaceous", "Herbaceous", "Herbaceous", "Shrubs", "Shrubs", "Shrubs")

# Plot a grouped bar chart for the subset with different colors based on 'Var1'
g2 = ggplot(M_sub, aes(x = class, y = Freq)) +
  geom_col(aes(fill = Var1), width = 0.4, alpha = 0.8) +
  xlab("") +
  ylab("Frequency") + coord_flip() +
  theme(legend.position = "None") +
  scale_fill_manual(name = "", values = c("black", "brown2", "mediumseagreen")) + theme_minimal() +
  theme(text = element_text(size = 16, family = 'Lato'))
```



