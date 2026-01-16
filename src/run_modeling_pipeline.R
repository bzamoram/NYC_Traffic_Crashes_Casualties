# Load all modeling modules
source("src/04_exploratory_analysis.R")
source("src/05_feature_engineering.R")
source("src/06_train_models.R")
source("src/07_evaluate_models.R")

#' Run complete modeling pipeline
run_modeling_pipeline <- function() {
  
  message(strrep("=", 60))  # FIXED
  message("STARTING MODELING PIPELINE")
  message(paste("Timestamp:", Sys.time()))
  message(strrep("=", 60))  # FIXED
  
  # 1. Load data
  message("\n[STEP 1] Loading data from database...")
  data <- load_model_data()
  
  # 2. Exploratory Data Analysis
  message("\n[STEP 2] Performing exploratory data analysis...")
  eda_results <- perform_eda(data)
  
  # 3. Feature Engineering
  message("\n[STEP 3] Creating feature engineering recipe...")
  recipe <- engineer_features(data)
  
  # 4. Train/Test Split
  message("\n[STEP 4] Splitting data into train and test sets...")
  split_data <- prepare_train_test_split(data, test_size = 0.2, seed = 42)
  
  # 5. Model Training
  message("\n[STEP 5] Training multiple models...")
  trained_models <- train_crash_models(split_data$train, recipe)
  
  # 6. Model Evaluation
  message("\n[STEP 6] Evaluating models on test set...")
  evaluation <- evaluate_models(trained_models, 
                                trained_models$recipe, 
                                split_data$test)
  
  # Final Summary
  message(paste0("\n", strrep("=", 60)))  # FIXED
  message("MODELING PIPELINE COMPLETED!")
  message(strrep("=", 60))  # FIXED
  message(paste("Best Model:", evaluation$best_model_name))
  message(paste("Best AUC:", round(evaluation$comparison$AUC[1], 4)))
  message("\nOutputs saved to:")
  message("  - models/ (trained models and recipe)")
  message("  - output/eda/ (exploratory analysis)")
  message("  - output/evaluation/ (performance metrics)")
  message(strrep("=", 60))  # FIXED
  
  return(evaluation)
}

# Run if executed directly
if (!interactive()) {
  results <- run_modeling_pipeline()
}
