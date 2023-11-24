# Low Mountain Grasslands under the Stress of Climate Change

This GitHub repository provides all the necessary documents (code and datasets) for the article titled "Low mountain grasslands under the stress of Climate Change." subimitted to AGU JGR:Biogeosciences. The repository is organized into three distinct folders, each corresponding to key steps in the submitted article. If you want to download the datasets, please follow this [link](https://zenodo.org/records/10204066)

If you use this script and/or these datasets, please cite the paper as follow.

- Herrault, PA., Ertlen, D., & Ullman, A. (Soumis). Low mountain grasslands under the stress of climate change. *Journal of Geophysical Research: Biogeosciences* [Data set]. Zenodo.https://zenodo.org/doi/10.5281/zenodo.10204065


## Trends_NDVI_max

This section enables the reproduction of the calculation of annual NDVI max trends from 2000 to 2020 using MODIS data. It is based on Theil Sen slopes and Mann-Kendall tests. The provided code also allows for the reproduction of the frequency histogram based on the assigned class for each pixel (positive, negative, non-significant). Additionally, it generates a bar chart detailing the proportion of each trend class based on the dominant land cover class. The two necessary files for this section are:

1. `Table_NDVImax_annual.csv`
2. `Table_info.csv`

## Explain_Trends_NDVImax

This section enables the reproduction of the Random Forest model aimed at measuring the effect of topo-climatic variables on the probability of presence of observed trend classes. It utilizes the SMOTE technique to ensure reliable sampling for model training. Performance indicators such as MDA and GINI are used to measure the performance of each variable. Partial dependence plots are also visualized to understand the effect of each variable on the positive class (negative trend). The required file for this section is:

- `data_randomforest.csv`

## Snow_effects

This section supports the reproduction of statistical models aiming to estimate the effects of snow cover on phenological indicators of low mountain grassland communities. Mixed-effects models are employed. It is also possible to visualize the significant effects of variables characterizing snow in interaction with topographic variables that have been identified as significant in each model. The required file for this section is:

- `table_globale.csv`

Feel free to explore each section's folder for detailed instructions and code to replicate the analyses and visualizations presented in the article. If you have any questions or encounter issues, please reach out to the repository owner.
