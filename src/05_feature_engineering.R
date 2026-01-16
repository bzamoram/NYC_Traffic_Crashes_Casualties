library(dplyr)
library(recipes)

#' Advanced feature engineering for crash severity prediction
engineer_features <- function(data) {
  
  # IMPORTANT: Convert target to factor BEFORE creating recipe
  data <- data %>%
    mutate(high_severity = factor(high_severity, 
                                  levels = c(0, 1), 
                                  labels = c("Low", "High")))
  
  # Create recipe for preprocessing
  crash_recipe <- recipe(high_severity ~ ., data = data) %>%
    
    # Remove ID columns
    step_rm(case_id) %>%
    
    # Handle missing values
    step_impute_mode(all_nominal(), -all_outcomes()) %>%
    step_impute_median(all_numeric()) %>%
    
    # Create interaction features (only if those columns exist)
    # step_interact(terms = ~ winter_crash:snow_ice_weather) %>%
    # step_interact(terms = ~ dark_conditions:adverse_weather) %>%
    # step_interact(terms = ~ rural_crash:speed_related) %>%
    # step_interact(terms = ~ alcohol_involved:dark_conditions) %>%
    
    # Time-based features
    step_mutate(
      rush_hour = hour_of_day %in% c(7, 8, 9, 16, 17, 18),
      late_night = hour_of_day %in% c(0, 1, 2, 3, 4, 5),
      high_risk_time = (day_of_week %in% c("Fri", "Sat", "Sun")) & 
        (hour_of_day >= 18 | hour_of_day <= 4)
    ) %>%
    
    # Convert logical to numeric (for modeling)
    step_mutate(across(where(is.logical), as.integer)) %>%
    
    # One-hot encoding for categorical variables
    step_dummy(all_nominal(), -all_outcomes(), one_hot = FALSE) %>%
    
    # Remove zero variance features
    step_zv(all_predictors()) %>%
    
    # Remove highly correlated features (> 0.9)
    step_corr(all_numeric_predictors(), threshold = 0.9) %>%
    
    # Normalize numeric features
    step_normalize(all_numeric_predictors())
  
  message("✓ Feature engineering recipe created")
  
  return(crash_recipe)
}

#' Prepare train/test split with stratification
prepare_train_test_split <- function(data, test_size = 0.2, seed = 42) {
  
  set.seed(seed)
  
  # Ensure target is factor
  data <- data %>%
    mutate(high_severity = factor(high_severity, 
                                  levels = c(0, 1),
                                  labels = c("Low", "High")))
  
  # Stratified split to maintain class balance
  train_index <- createDataPartition(data$high_severity, 
                                     p = 1 - test_size, 
                                     list = FALSE)
  
  train_data <- data[train_index, ]
  test_data <- data[-train_index, ]
  
  message(paste("\nTrain set:", nrow(train_data), "records"))
  message(paste("Test set:", nrow(test_data), "records"))
  message("\nTrain set class distribution:")
  print(table(train_data$high_severity))
  message("\nTest set class distribution:")
  print(table(test_data$high_severity))
  
  return(list(train = train_data, test = test_data))
}
