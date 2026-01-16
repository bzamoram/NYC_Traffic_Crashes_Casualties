# FARS Minnesota ML Pipeline

End-to-end data engineering and machine learning project analyzing fatal
traffic crashes in Minnesota.

## 🔗 Live Demo

[**📊 View Full Interactive
Report**](https://bzamoram.github.io/FARS-Minnesota-ML-Pipeline/)

## 🎯 Project Overview

This project demonstrates a complete data science workflow from data
extraction to model deployment:

-   **Data Engineering**: Automated ETL pipeline from NHTSA FARS data
-   **Database**: SQLite with optimized queries and indexed tables
-   **Machine Learning**: 3 algorithms trained and compared (Logistic
    Regression, Random Forest, Decision Tree)
-   **Best Model**: Logistic Regression with **1.0 AUC** on test set
-   **Visualizations**: Interactive maps with Leaflet, dynamic charts
    with Plotly

## 📊 Key Results

-   **450 fatal crashes** analyzed (2015-2023)
-   **Perfect classification** achieved (AUC: 1.0)
-   **Top risk factors**: Alcohol involvement, dark conditions, winter
    weather
-   **Geographic hotspots** identified for targeted interventions

## 🛠️ Technical Stack

**Data Engineering:** - R (httr, jsonlite) - API integration - SQLite -
Database management - dplyr, tidyr - Data transformation

**Machine Learning:** - caret - Model training framework -
randomForest - Ensemble methods - recipes - Feature engineering
pipeline - pROC - Model evaluation

**Visualization:** - plotly - Interactive charts - leaflet - Geographic
mapping - ggplot2 - Statistical graphics - R Markdown - Report
generation

## 🚀 Reproducibility

Run the complete analysis:

\`\`\`r \# 1. Run ETL Pipeline source("src/run_etl_pipeline.R")
run_fars_pipeline(from_year = 2015, to_year = 2023)

# 2. Train Models

source("src/run_modeling_pipeline.R") results \<-
run_modeling_pipeline()

# 3. Generate Report

rmarkdown::render("Minnesota_FARS_Analysis.Rmd")

💡 Key Insights 1. Winter Impact: Winter crashes show significantly
higher fatality rates

2.  Alcohol Factor: Present in substantial portion of fatal crashes

3.  Rural vs Urban: Rural locations have higher crash severity

4.  Temporal Patterns: Weekend evenings show elevated risk

5.  Predictive Success: Model successfully identifies high-risk
    scenarios

📈 Skills Demonstrated - API integration and data extraction

-   ETL pipeline development

-   Database design and optimization

-   Feature engineering and data preprocessing

-   Machine learning model training and evaluation

-   Data visualization and storytelling

-   Technical documentation

-   Reproducible research with R Markdown
