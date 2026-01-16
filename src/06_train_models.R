library(caret)
library(randomForest)
library(e1071)
library(pROC)
library(doParallel)

#' Set up parallel processing
setup_parallel <- function() {
  cl <- makePSOCKcluster(detectCores() - 1)
  registerDoParallel(cl)
  message(paste("Parallel processing enabled with", detectCores() - 1, "cores"))
  return(cl)
}

#' Train multiple models with cross-validation (SIMPLIFIED for small data)
train_crash_models <- function(train_data, recipe) {
  
  # Setup parallel processing
  cl <- setup_parallel()
  
  # Prepare data using recipe
  prepped_recipe <- prep(recipe, training = train_data)
  train_processed <- bake(prepped_recipe, new_data = train_data)
  
  # Handle class imbalance - check distribution
  class_dist <- table(train_processed$high_severity)
  imbalance_ratio <- max(class_dist) / min(class_dist)
  
  message(paste("\nClass imbalance ratio:", round(imbalance_ratio, 2), ":1"))
  
  # SIMPLIFIED training control for small datasets
  train_control <- trainControl(
    method = "cv",
    number = 5,  # Reduced from 10 for stability
    classProbs = TRUE,
    summaryFunction = twoClassSummary,
    savePredictions = "final",
    allowParallel = TRUE
  )
  
  message(paste0("\n", strrep("=", 60)))
  message("TRAINING MODELS (Simplified for small dataset)")
  message(strrep("=", 60))
  
  # 1. Logistic Regression (baseline)
  message("\n[1/3] Training Logistic Regression...")
  model_glm <- train(
    high_severity ~ .,
    data = train_processed,
    method = "glm",
    family = "binomial",
    trControl = train_control,
    metric = "ROC"
  )
  message("✓ Logistic Regression complete")
  
  # 2. Random Forest (simplified tuning)
  message("\n[2/3] Training Random Forest...")
  model_rf <- train(
    high_severity ~ .,
    data = train_processed,
    method = "rf",
    trControl = train_control,
    metric = "ROC",
    tuneGrid = expand.grid(mtry = c(3, 5, 7)),  # Simplified grid
    ntree = 200,  # Reduced from 500
    importance = TRUE
  )
  message("✓ Random Forest complete")
  
  # 3. Simple Decision Tree
  message("\n[3/3] Training Decision Tree...")
  model_rpart <- train(
    high_severity ~ .,
    data = train_processed,
    method = "rpart",
    trControl = train_control,
    metric = "ROC",
    tuneLength = 3
  )
  message("✓ Decision Tree complete")
  
  # Stop parallel processing
  stopCluster(cl)
  registerDoSEQ()
  
  # Collect all models
  models <- list(
    logistic = model_glm,
    random_forest = model_rf,
    decision_tree = model_rpart
  )
  
  # Save models and recipe
  dir.create("models", showWarnings = FALSE)
  saveRDS(models, "models/all_trained_models.rds")
  saveRDS(prepped_recipe, "models/preprocessing_recipe.rds")
  
  message("\n✓ All models saved to models/ directory")
  
  return(list(models = models, recipe = prepped_recipe))
}
