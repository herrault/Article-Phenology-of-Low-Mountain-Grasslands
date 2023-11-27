---
title: "Script_snow_effects"
output:
  pdf_document: default
  html_document: default
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Etape 1
```{r setup1 }

# Import Packages

library(effects)
library(sjPlot)
library(nlme)
library(insight)
library(sjmisc)
library(regclass)
library(corrplot)
library(ggplot2)

# Import Data
X = read.csv("table_globale.csv")
## Column names and Definition
# ID = ID pixel
# x = coordinate x of the pixel centroid
# y = coordinate y of the pixel centroid
# last_snow = day of last presence of snow
# first_snow = day of first presence of snow
# ssl = snow season length
# swi = soil wetness index
# sfgws = spring frozen ground without snow
# year = year
# scv = snow cover variability
# sos = day of start of season
# eos = day of end of season
# dop = day of date of peak
# pkv = peak of value
# climatic_balance = climatic balance
# T_max_summer = summer maximum temperature
# TTP =Time to Peak
# Elev = Elevation
# DAH = Diurnal Anistropic Heating

```

```{r setup2 }
# Scaling the 'ssl' variable in the data frame or matrix X, centering and scaling it.
a1 = scale(X$ssl, center = TRUE, scale = TRUE)

# Scaling the 'sfgws' variable in the data frame or matrix X, centering and scaling it.
a2 = scale(X$sfgws, center = TRUE, scale = TRUE)

# Scaling the 'scv' variable in the data frame or matrix X, centering and scaling it.
a3 = scale(X$scv, center = TRUE, scale = TRUE)

# Scaling the 'Elev' variable in the data frame or matrix X, centering and scaling it.
a4 = scale(X$Elev, center = TRUE, scale = TRUE)

# Scaling the 'DAH' variable in the data frame or matrix X, centering and scaling it.
a5 = scale(X$DAH, center = TRUE, scale = TRUE)

# Scaling the 'pkv' variable in the data frame or matrix X, centering and scaling it.
a10 = scale(X$pkv, center = TRUE, scale = TRUE)

# Scaling the 'TTP' variable in the data frame or matrix X, centering and scaling it.
a11 = scale(X$TTP, center = TRUE, scale = TRUE)
```

```{r setup3 }

# Creating a data frame named 'dataset' with standardized variables a1 to a5
dataset = data.frame("SSL" = a1, "SFGWS" = a2, "SCV" = a3, "Altitude" = a4, "DAH" = a5)

# Computing the correlation matrix 'MM' for the variables in the dataset
MM = cor(dataset)

# Performing a significance test on the correlations in the dataset
p.mat = cor.mtest(dataset)

# Defining a color palette for correlation plot
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))

# Creating a correlation plot using corrplot library
corrplot(MM, method = "color", col = col(200), 
         type = "upper", order = "hclust", 
         addCoef.col = "black", 
         tl.col = "black", tl.srt = 45, 
         p.mat = p.mat$p, sig.level = 0.05, insig = "blank", 
         diag = FALSE)


```

```{r setup4 }

# Creating a data frame 'df' with variables a1 to a5, a10, a11, ID, and year
df = data.frame(a1, a2, a3, a4, a5, a10, a11, "ID" = X$ID, "year" = X$year)

# Fitting a linear mixed-effects model (lme) for a10 using variables a1 to a5, and interactions
fm1 <- lme(a10 ~ a1 + a2 + a3 + a4 + a5 + a1:a4 + a1:a5 + a2:a4 + a2:a5 + a3:a4 + a3:a5, data = df, random = ~ 1|ID|year)

# Calculating the Variance Inflation Factor (VIF) for the fitted model fm1
VIF(fm1)

# Fitting another linear mixed-effects model (lme) for a11 using variables a1 to a5, and interactions
fm2 <- lme(a11 ~ a1 + a2 + a3 + a4 + a5 + a1:a4 + a1:a5 + a2:a4 + a2:a5 + a3:a4 + a3:a5, data = df, random = ~ 1|ID|year)

# Calculating the Variance Inflation Factor (VIF) for the fitted model fm2
VIF(fm2)
```

```{r setup5 }

# Plotting predicted values for fm1 with respect to a1 and a4
aa = plot_model(fm1, type = "pred", terms = c("a1", "a4"), colors = "bw") +
     theme_light() +
     theme(legend.position = "none", text = element_text(size = 14, family = "Lato")) +
     ggtitle("") +
     xlab("Snow Duration (SD)") +
     ylab("Peak of Value (PkV)")

# Plotting predicted values for fm1 with respect to a3 and a4
bb = plot_model(fm1, type = "pred", terms = c("a3", "a4"), colors = "bw") +
     theme_light() +
     theme(legend.position = "none", text = element_text(size = 14, family = "Lato")) +
     ggtitle("") +
     xlab("Snow Cover Variability (SCV)") +
     ylab("Peak of Value (PkV)")

# Plotting predicted values for fm1 with respect to a3 and a5
cc = plot_model(fm1, type = "pred", terms = c("a3", "a5"), colors = "bw") +
     theme_light() +
     theme(legend.position = "none", text = element_text(size = 14, family = "Lato")) +
     ggtitle("") +
     xlab("Snow Cover Variability (SCV)") +
     ylab("Peak of Value (PkV)")

# Plotting predicted values for fm2 with respect to a1 and a4
aaa = plot_model(fm2, type = "pred", terms = c("a1", "a4"), colors = "bw") +
      theme_light() +
      theme(legend.position = "none", text = element_text(size = 14, family = "Lato")) +
      ggtitle("") +
      xlab("Snow Duration (SD)") +
      ylab("Time to Peak (TTP)")

# Plotting predicted values for fm2 with respect to a2 and a4
bbb = plot_model(fm2, type = "pred", terms = c("a2", "a4"), colors = "bw") +
      theme_light() +
      theme(legend.position = "none", text = element_text(size = 14, family = "Lato")) +
      ggtitle("") +
      xlab("SFGWS*") +
      ylab("Time to Peak (TTP)")

# Plotting predicted values for fm2 with respect to a3 and a4
ccc = plot_model(fm2, type = "pred", terms = c("a3", "a4"), colors = "bw") +
      theme_light() +
      theme(legend.position = "none", text = element_text(size = 14, family = "Lato")) +
      ggtitle("") +
      xlab("Snow Cover Variability (SCV)") +
      ylab("Time to Peak (TTP)")

# Plotting predicted values for fm2 with respect to a2 and a5
ddd = plot_model(fm2, type = "pred", terms = c("a2", "a5"), colors = "bw") +
      theme_light() +
      theme(legend.position = "none", text = element_text(size = 14, family = "Lato")) +
      ggtitle("") +
      xlab("SFGWS*") +
      ylab("Time to Peak (TTP)")
```


```{r setup6 }
# Load the ggpubr library for enhanced ggplot2 functionalities
library(ggpubr)

# Create a scatter plot (z1) for the relationship between 'sfgws' and 'scv'
z1 = ggscatter(X, x = "sfgws", y = "scv", add = "reg.line",
               conf.int = TRUE, cor.coef = TRUE, cor.coef.size = 7, cor.method = "pearson",
               cor.coeff.args = list(label.x = 10),
               xlab = "SFGWS", ylab = "SCV",
               color = "black", shape = 21, size = 3,
               add.params = list(color = "blue", fill = "lightgray"), font.label = c(12, "plain")) +
     theme(text = element_text(size = 17))

# Create a scatter plot (z2) for the relationship between 'sfgws' and 'ssl'
z2 = ggscatter(X, x = "sfgws", y = "ssl", add = "reg.line",
               conf.int = TRUE, cor.coef = TRUE, cor.coef.size = 7, cor.method = "pearson",
               cor.coeff.args = list(label.x = 10),
               xlab = "SFGWS", ylab = "SSL",
               color = "black", shape = 21, size = 3,
               add.params = list(color = "blue", fill = "lightgray"), font.label = c(12, "plain")) +
     theme(text = element_text(size = 17))

# Create a scatter plot (z3) for the relationship between 'ssl' and 'scv'
z3 = ggscatter(X, x = "ssl", y = "scv", add = "reg.line",
               conf.int = TRUE, cor.coef = TRUE, cor.coef.size = 7, cor.method = "pearson",
               cor.coeff.args = list(label.x = 30),
               xlab = "SSL", ylab = "SCV",
               color = "black", shape = 21, size = 3,
               add.params = list(color = "blue", fill = "lightgray"), font.label = c(12, "plain")) +
     theme(text = element_text(size = 17))


```
