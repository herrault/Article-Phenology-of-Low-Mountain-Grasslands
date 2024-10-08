---
title: "Script_explain_trends_annualNDVImax"
output:
  html_document: default
  pdf_document: default
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Introduction

This code allows to perform the stage 2. It is a loop that iteratively perform random forest model with a synthetic oversampling technique called SMOTE (Synthetic Minority Over-sampling Technique). The three main points are : 

- Perform Random Forest
- Create boxplots featuring Gini and Mean Decrease accuracy
- Create partial dependence plots

## Perform Random Forest 
```{r setup1 }

# Import Packages
library(randomForest)
library(datasets)
library(caret)
library(pdp)
library(performanceEstimation)

# Import Data

Y = read.csv("data_randomforest_.csv")

## Column names and Definition

# ID = ID pixel
# class = class of trends (1- non significant; 2-significant negative)
# DAH = Diurnal Anistropic Heating
# Elevation = Elevation
# CBL_sl = Climatic balance slope
# T_max_sl =  Summer maximum temperature slope
# SWI_sl = Soil Wetness Index slope
# SOS_sl = Start of Season Slope

# Initialize lists to store metrics and results
list_kappa = list()
list_accuracy = list()
list_acc_class1 = list()
list_acc_class2 = list()
list_DAH_gini = list()
list_elevation_gini = list()
list_hyd_gini = list()
list_tmax_gini = list()
list_SWI_gini = list()
list_Green_gini = list()
list_PP = list()

# Loop for 100 iterations
for (t in 1:100) {
  # Extract positive and negative classes from the dataset
  Y1 = Y[Y$class == 1,]  
  Y2 = Y[Y$class == 2,]  
  
  # Concatenate positive and negative classes
  Y_agg = rbind(Y1, Y2)
  
  # Convert class variable to a factor
  Y_agg$class = factor(Y_agg$class)
  
  # Apply SMOTE to balance the classes
  newData <- smote(class ~ ., Y_agg, perc.over = 5, perc.under = 0)
  sub_df <- subset(newData)
  final_df <- rbind(Y_agg[Y_agg$class == 1,], sub_df)
  
  # Split the data into true negative and false negative subsets
  
  #idd = which(final_df$class==2)
  #true_neg = final_df[idd[1:67],]
  #false_neg = final_df[-idd[1:67],]
  
  
  true_pos = final_df[1:67,]
  false_pos = final_df[68:nrow(final_df),]
  
  # Sample indices for training set
  y1 = sample(seq(1, nrow(Y2)), round((66/100) * nrow(Y2)))
  y2_1 = sample(seq(1, nrow(true_pos)), round((66/100) * nrow(true_pos)))
  y2_2 = sample(seq(1, nrow(false_pos)), round((66/100) * nrow(false_pos)))
  
  # Create training and testing sets
  Y_train = rbind(Y2[y1,], rbind(true_pos[y2_1,], false_pos[y2_2,]))
  Y_test_class2 = Y2[-y1,]
  Y_test = rbind(Y_test_class2, true_pos[-y2_1,])
  
  # Train a random forest model
  model <- randomForest(as.factor(class) ~ ., data = Y_train[, -c(1,2)], ntree = 200, na.action = na.omit, importance = TRUE)
  
  # Get variable importance measures
  obj = varImpPlot(model)
  imp <- importance(model)
  DAH_gini = obj[1,]
  elevation_gini = obj[2,]
  hyd_gini = obj[3,]
  tmax_gini = obj[4,]
  SWI_gini = obj[5,]
  Green_gini = obj[6,]
  
  # Specify variables of interest for partial plots
  impvar = c("SWI_sl","Elevation","CBL_sl","DAH","SOS_sl","T_max_sl")
  
  # Store partial plots in a list
  list_pp = list()
  op <- par(mfrow = c(2, 3))
  for (u in 1:length(impvar)){
    pp = partialPlot(model, Y_train[, -c(1,2)], impvar[u], xlab = impvar[u], main = paste("Partial Dependence on", impvar[u]))
    list_pp[[u]] = pp
  }
  par(op)
  
  # Make predictions on the test set
  Y_test$predicted <- predict(model, Y_test[,-c(1,2)])
  
  # Evaluate model performance
  CF = confusionMatrix(as.factor(Y_test$predicted), as.factor(Y_test$class))
  
  # Calculate metrics
  Kappa = CF$overall[2]
  Accuracy = CF$overall[1]
  acc_class1 = CF$table[1]/(CF$table[1]+CF$table[2])
  acc_class2 = CF$table[4]/(CF$table[3]+CF$table[4])
  
  # Store results in lists for later analysis
  list_PP[[t]] = list_pp
  list_kappa[[t]] = Kappa
  list_accuracy[[t]] = Accuracy
  list_acc_class2[[t]] = acc_class2
  list_acc_class1[[t]] = acc_class1
  
  list_DAH_gini[[t]] = DAH_gini
  list_elevation_gini[[t]] = elevation_gini
  list_hyd_gini[[t]] = hyd_gini
  list_tmax_gini[[t]] = tmax_gini
  #list_frozen_gini[[t]] = frozen_gini
  list_SWI_gini[[t]] = SWI_gini
  list_Green_gini[[t]] = Green_gini
}

# Calculate mean of Kappa over 100 iterations
res_kappa = do.call(rbind, list_kappa)
mean(abs(res_kappa))

# Calculate mean of Accuracy over 100 iterations
res_accuracy = do.call(rbind, list_accuracy)
mean(abs(res_accuracy))

# Calculate mean of Class 1 Accuracy over 100 iterations
res_acc_class1 = do.call(rbind, list_acc_class1)
mean(abs(res_acc_class1))

# Calculate mean of Class 2 Accuracy over 100 iterations
res_acc_class2 = do.call(rbind, list_acc_class2)
mean(abs(res_acc_class2))

```

## Create boxplots featuring Gini and Mean Decrease accuracy

```{r setup2 }
# Combine Gini values from different variables into a data frame
TAB_gini = rbind(data.frame(do.call(rbind,list_DAH_gini)), data.frame(do.call(rbind,list_elevation_gini)),
                 data.frame(do.call(rbind,list_hyd_gini)), data.frame(do.call(rbind,list_tmax_gini)),
                 #data.frame(do.call(rbind,list_frozen_gini)),
                 data.frame(do.call(rbind,list_SWI_gini)),
                 data.frame(do.call(rbind,list_Green_gini)))

# Create a new column 'var' to represent the variable names
TAB_gini$var = c(rep("DAH", 100), rep("Elevation", 100), rep("P-ETP slope", 100), rep("T-max slope", 100),
                 #rep("FGWS slope", 100),
                 rep("SWI slope", 100), rep("Green-up slope", 100))

# Create boxplots for Mean Decrease Gini and Mean Decrease Accuracy
b1 = ggplot(TAB_gini, aes(x = var, y = MeanDecreaseGini, fill = var)) +
  geom_boxplot(width = 0.5) + ylab("Mean Decrease Gini") +
  theme_light() +
  theme(text = element_text(size = 16, family = "Lato")) + xlab("") +
  theme(legend.position = "none")

b2 = ggplot(TAB_gini, aes(x = var, y = MeanDecreaseAccuracy, fill = var)) +
  geom_boxplot(width = 0.5) + ylab("Mean Decrease Accuracy") +
  theme_light() +
  theme(text = element_text(size = 16, family = "Lato")) + xlab("") +
  theme(legend.position = "none")
```

## Create partial dependence plots

```{r setup3 }

# Initialize lists to store partial plots for different variables
list_PP1 = list()
list_PP2 = list()
list_PP3 = list()
list_PP4 = list()
list_PP5 = list()
list_PP6 = list()
list_PP7 = list()

# Loop through 100 iterations to extract partial plots from the main list
for (e in 1:100) {
  
  lPP = list_PP[[e]]
  
  # Extract y-values for each variable's partial plot
  lpp1 = lPP[[1]]$y
  lpp2 = lPP[[2]]$y
  lpp3 = lPP[[3]]$y
  lpp4 = lPP[[4]]$y
  lpp5 = lPP[[5]]$y
  lpp6 = lPP[[6]]$y
  
  # Store y-values in separate lists for each variable
  list_PP1[[e]] = lpp1
  list_PP2[[e]] = lpp2
  list_PP3[[e]] = lpp3
  list_PP4[[e]] = lpp4
  list_PP5[[e]] = lpp5
  list_PP6[[e]] = lpp6
 
}

# Create data frames for each variable's mean and standard deviation
pp1_mat = data.frame(do.call(rbind, list_PP1))
pp1_mean = colMeans(pp1_mat)
pp1_sd = sapply(pp1_mat, sd)

pp2_mat = data.frame(do.call(rbind, list_PP2))
pp2_mean = colMeans(pp2_mat)
pp2_sd = sapply(pp2_mat, sd)

pp3_mat = data.frame(do.call(rbind, list_PP3))
pp3_mean = colMeans(pp3_mat)
pp3_sd = sapply(pp3_mat, sd)

pp4_mat = data.frame(do.call(rbind, list_PP4))
pp4_mean = colMeans(pp4_mat)
pp4_sd = sapply(pp4_mat, sd)

pp5_mat = data.frame(do.call(rbind, list_PP5))
pp5_mean = colMeans(pp5_mat)
pp5_sd = sapply(pp5_mat, sd)

pp6_mat = data.frame(do.call(rbind, list_PP6))
pp6_mean = colMeans(pp6_mat)
pp6_sd = sapply(pp6_mat, sd)

# Create a combined data frame with mean, sd, variable name, and x-values
PP_tab = data.frame(c(pp1_mean, pp2_mean, pp3_mean, pp4_mean, pp5_mean, pp6_mean),
                    c(pp1_sd, pp2_sd, pp3_sd, pp4_sd, pp5_sd, pp6_sd),
                    c(rep("var1", 51), rep("var2", 51), rep("var3", 51), rep("var4", 51), rep("var5", 51), rep("var6", 51)),
                    c(lPP[[1]]$x, lPP[[2]]$x, lPP[[3]]$x, lPP[[4]]$x, lPP[[5]]$x, lPP[[6]]$x))

# Set column names for the combined data frame
colnames(PP_tab) = c("mean", "sd", "var", "x")

# Create individual boxplots for each variable and arrange them in a grid
p1 = ggplot(PP_tab[PP_tab$var == "var1", ], aes(x, mean)) +
  geom_ribbon(aes(ymin = mean - sd, ymax = mean + sd), fill = "grey70") + geom_line() + ylim(-1.2, 0.3) +
  ylab("Predicted Browning Trend probability") +
  xlab("SWI slope") + theme_light() +
  theme(text = element_text(family = "Lato"))
  
p2 = ggplot(PP_tab[PP_tab$var == "var2", ], aes(x, mean)) +
  geom_ribbon(aes(ymin = mean - sd, ymax = mean + sd), fill = "grey70") + geom_line() + ylim(-1.2, 0.3) +
  ylab("Predicted Browning Trend probability") +
  theme_light() +
  xlab("Elevation") +
  theme(text = element_text(family = "Lato"))

p3 = ggplot(PP_tab[PP_tab$var == "var3", ], aes(x, mean)) +
  geom_ribbon(aes(ymin = mean - sd, ymax = mean + sd), fill = "grey70") + geom_line() + ylim(-1.2, 0.3) +
  ylab("Predicted Browning Trend probability") +
  theme_light() +
  xlab("P-ETP slope") +
  theme(text = element_text(family = "Lato"))

p4 = ggplot(PP_tab[PP_tab$var == "var4", ], aes(x, mean)) +
  geom_ribbon(aes(ymin = mean - sd, ymax = mean + sd), fill = "grey70") + geom_line() + ylim(-1.2,0.3)+
  ylab("Predicted Browning Trend probability")+
  theme_light()+
  xlab("DAH")+
  theme(text=element_text(family="Lato"))
p5 = ggplot(PP_tab[PP_tab$var == "var5",],aes(x,mean))+
  geom_ribbon(aes(ymin=mean-sd, ymax=mean+sd),fill = "grey70")+geom_line()+ylim(-1.2,0.3)+
  ylab("Predicted Browning Trend probability")+
  theme_light()+
  xlab("Green-up slope")+
  theme(text=element_text(family="Lato"))
p6 = ggplot(PP_tab[PP_tab$var == "var6",],aes(x,mean))+
  geom_ribbon(aes(ymin=mean-sd, ymax=mean+sd),fill = "grey70")+geom_line()+ylim(-1.2,0.3)+
  ylab("Predicted Browning Trend probability")+
  theme_light()+
  xlab("Summer T-max slope")+
  theme(text=element_text(family="Lato"))

grid.arrange(p1,p2,p3,p4,p5,p6,ncol = 3,nrow = 2)
```

