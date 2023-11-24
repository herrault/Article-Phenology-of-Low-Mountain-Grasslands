README.md for "Low mountain grasslands under the stress of Climate Change" GitHub Repository
This GitHub repository provides all the necessary documents for the article titled "Low mountain grasslands under the stress of Climate Change." The repository is organized into three distinct folders, each corresponding to key steps in the submitted article.

Trends_NDVI_max
This section enables the reproduction of the calculation of annual NDVI max trends from 2000 to 2020 using MODQ13 data. It relies on Theil Sen trends and Mann-Kendall tests. The provided code also reproduces the frequency histogram based on the assigned trend class for each pixel (positive, negative, non-significant). Additionally, it generates a bar chart detailing the proportion of each trend class based on the dominant land cover class. The two necessary files for this section are:

Table_NDVImax_annual.csv
Table_info.csv
Explain_Trends_NDVImax
This section facilitates the reproduction of the Random Forest model aimed at measuring the effect of topo-climatic variables on the probability of trend class presence. The SMOTE technique is employed to ensure reliable sampling for model training. Performance metrics such as MDA and GINI are utilized to assess the performance of each variable. Partial dependence plots are also visualized to understand the effect of each variable on the positive class (negative trend). The required file for this section is:

data_randomforest.csv
Snow_effects
This section supports the reproduction of statistical models to estimate the effects of snow cover on phenological indicators of low mountain grassland communities. Mixed-effects models are employed, and it is possible to visualize the significant effects of snow-related variables interacting with topographic variables that were identified as significant in each model. The required file for this section is:

table_globale.csv
Feel free to explore each section's folder for detailed instructions and code to replicate the analyses and visualizations presented in the article. If you have any questions or encounter issues, please reach out to the repository owner.
