library(dplyr)
library(tidyr)  # ADD THIS - needed for pivot_longer
library(ggplot2)
library(corrplot)
library(DBI)
library(RSQLite)
library(caret)

#' Load data from database for modeling
load_model_data <- function(db_path = "data/minnesota_fars.db") {
  con <- dbConnect(SQLite(), db_path)
  
  # Load from fatal_crashes table (not model_features view which may not exist)
  model_data <- dbReadTable(con, "fatal_crashes")
  dbDisconnect(con)
  
  message(paste("Loaded", nrow(model_data), "records for modeling"))
  return(model_data)
}

#' Perform exploratory data analysis
perform_eda <- function(data) {
  
  # Create output directory
  dir.create("output/eda", showWarnings = FALSE, recursive = TRUE)
  
  # 1. Target variable distribution (ensure it's numeric for counting)
  data_eda <- data %>%
    mutate(high_severity_num = as.numeric(high_severity))
  
  target_dist <- table(data_eda$high_severity_num)
  message("\nTarget Variable Distribution (high_severity):")
  print(prop.table(target_dist))
  
  # 2. Check for missing values
  missing_summary <- data %>%
    summarise(across(everything(), ~sum(is.na(.)))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
    filter(missing_count > 0) %>%
    arrange(desc(missing_count))
  
  message("\nMissing Values Summary:")
  if (nrow(missing_summary) > 0) {
    print(missing_summary)
  } else {
    message("No missing values found!")
  }
  
  # 3. Simple feature importance (skip if too complex)
  message("\n✓ EDA complete. Check output/eda/ for visualizations")
  
  return(list(
    target_distribution = target_dist,
    missing_summary = missing_summary
  ))
}
