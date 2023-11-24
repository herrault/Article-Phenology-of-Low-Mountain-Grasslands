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
```


```{r setup2 }

a1 = scale(X$ssl, center = TRUE, scale = TRUE)
a2 = scale(X$sfgws, center = TRUE, scale = TRUE)
a3 = scale(X$scv, center = TRUE, scale = TRUE)
a4 = scale(X$Elev, center = TRUE, scale = TRUE)
a5 = scale(X$DAH, center = TRUE, scale = TRUE)
a10 = scale(X$pkv, center = TRUE, scale = TRUE)
a11 = scale(X$TTP, center = TRUE, scale = TRUE)
```

```{r setup3 }

dataset = data.frame("SSL" = a1,"SFGWS" = a2,"SCV" = a3,"Altitude" = a4,"DAH" = a5)
MM = cor(dataset)
p.mat = cor.mtest(dataset)
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(MM, method="color", col = col(200), 
         type="upper", order="hclust", 
         addCoef.col = "black", 
         tl.col="black", tl.srt=45, 
         p.mat = p.mat$p, sig.level = 0.05, insig = "blank", 
         diag=FALSE
) 

```

```{r setup4 }

df = data.frame(a1,a2,a3,a4,a5,a10,a11,"ID"=X$ID,"year"=X$year)
fm1 <- lme(a10 ~ a1+a2+a3+a4+a5+a1:a4+a1:a5+a2:a4+a2:a5+a3:a4+a3:a5, data = df, random = ~ 1|ID|year)
VIF(fm1)
fm2 <- lme(a11 ~ a1+a2+a3+a4+a5+a1:a4+a1:a5+a2:a4+a2:a5+a3:a4+a3:a5, data = df, random = ~ 1|ID|year)
VIF(fm2)
```

```{r setup5 }

aa = plot_model(fm1, type = "pred", terms = c("a1", "a4"), colors = "bw")+theme_light()+
  theme(legend.position = "none",text=element_text(size=14,  family="Lato"))+ggtitle("")+
  xlab("Snow Duration (SD)")+ylab("Peak of Value (PkV)")
bb = plot_model(fm1, type = "pred",terms = c("a3", "a4"), colors = "bw")+theme_light()+
  theme(legend.position = "none",text=element_text(size=14,  family="Lato"))+ggtitle("")+
  xlab("Snow Cover Variability (SCV)")+ylab("Peak of Value (PkV)")
cc = plot_model(fm1, type = "pred", terms = c("a3", "a5"), colors = "bw")+theme_light()+
  theme(legend.position = "none",text=element_text(size=14,  family="Lato"))+ggtitle("")+
  xlab("Snow Cover Variability (SCV)")+ylab("Peak of Value (PkV)")

aaa = plot_model(fm2, type = "pred", terms = c("a1", "a4"), colors = "bw")+theme_light()+
  theme(legend.position = "none",text=element_text(size=14,  family="Lato"))+ggtitle("")+
  xlab("Snow Duration (SD)")+ylab("Time to Peak (TTP)")
bbb = plot_model(fm2, type = "pred", terms = c("a2", "a4"), colors = "bw")+theme_light()+
  theme(legend.position = "none",text=element_text(size=14,  family="Lato"))+ggtitle("")+
  xlab("SFGWS*")+ylab("Time to Peak (TTP)")
ccc = plot_model(fm2, type = "pred", terms = c("a3", "a4"), colors = "bw")+theme_light()+
  theme(legend.position = "none",text=element_text(size=14,  family="Lato"))+ggtitle("")+
  xlab("Snow Cover Variability (SCV)")+ylab("Time to Peak (TTP)")
ddd = plot_model(fm2, type = "pred", terms = c("a2", "a5"), colors = "bw")+theme_light()+
  theme(legend.position = "none",text=element_text(size=14,  family="Lato"))+ggtitle("")+
  xlab("SFGWS*")+ylab("Time to Peak (TTP)")
```


```{r setup6 }
library(ggpubr)
z1 = ggscatter(X, x = "sfgws", y = "scv", add = "reg.line",
          conf.int = TRUE, cor.coef = TRUE,cor.coef.size = 7,cor.method = "pearson",
          cor.coeff.args = list(label.x = 10),
          xlab = "SFGWS", ylab = "SCV",
          color = "black",shape = 21, size = 3,
          add.params = list(color = "blue", fill = "lightgray"), font.label = c(12,"plain")) + 
  theme(text = element_text(size = 17))

z2 = ggscatter(X, x = "sfgws", y = "ssl", add = "reg.line",
          conf.int = TRUE, cor.coef = TRUE,cor.coef.size = 7,cor.method = "pearson",
          cor.coeff.args = list(label.x = 10),
          xlab = "SFGWS", ylab = "SSL",
          color = "black",shape = 21, size = 3,
          add.params = list(color = "blue", fill = "lightgray"), font.label = c(12,"plain")) + 
  theme(text = element_text(size = 17))


z3 = ggscatter(X, x = "ssl", y = "scv", add = "reg.line",
          conf.int = TRUE, cor.coef = TRUE, cor.coef.size = 7,cor.method = "pearson",
          cor.coeff.args = list(label.x = 30),
          xlab = "SSL", ylab = "SCV",
          color = "black", shape = 21, size = 3,
          add.params = list(color = "blue", fill = "lightgray"),font.label = c(12,"plain")) + 
  theme(text = element_text(size = 17))


```
