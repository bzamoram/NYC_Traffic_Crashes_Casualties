#' Evaluate all models on test set
evaluate_models <- function(models, recipe, test_data) {
  
  # Prepare test data
  test_processed <- bake(recipe, new_data = test_data)
  
  message(paste0("\n", strrep("=", 60)))  # FIXED
  message("EVALUATING MODELS ON TEST SET")
  message(strrep("=", 60))  # FIXED
  
  # Initialize results storage
  results <- list()
  roc_curves <- list()
  
  for (model_name in names(models$models)) {
    message(paste("\nEvaluating", model_name, "..."))
    
    model <- models$models[[model_name]]
    
    # Make predictions
    predictions <- predict(model, newdata = test_processed)
    pred_probs <- predict(model, newdata = test_processed, type = "prob")
    
    # Confusion matrix
    cm <- confusionMatrix(predictions, test_processed$high_severity, 
                          positive = "High")
    
    # ROC curve
    roc_obj <- roc(test_processed$high_severity, pred_probs$High)
    
    # Store results
    results[[model_name]] <- list(
      model_name = model_name,
      accuracy = cm$overall['Accuracy'],
      sensitivity = cm$byClass['Sensitivity'],
      specificity = cm$byClass['Specificity'],
      precision = cm$byClass['Pos Pred Value'],
      f1_score = cm$byClass['F1'],
      auc = auc(roc_obj),
      confusion_matrix = cm$table,
      roc_curve = roc_obj,
      model = model  # Store the actual model object
    )
    
    roc_curves[[model_name]] <- roc_obj
    
    # Print summary
    message(paste("  Accuracy:", round(cm$overall['Accuracy'], 4)))
    message(paste("  AUC:", round(auc(roc_obj), 4)))
    message(paste("  F1 Score:", round(cm$byClass['F1'], 4)))
  }
  
  # Create comparison dataframe
  comparison_df <- data.frame(
    Model = names(results),
    Accuracy = sapply(results, function(x) x$accuracy),
    Sensitivity = sapply(results, function(x) x$sensitivity),
    Specificity = sapply(results, function(x) x$specificity),
    Precision = sapply(results, function(x) x$precision),
    F1_Score = sapply(results, function(x) x$f1_score),
    AUC = sapply(results, function(x) x$auc)
  ) %>%
    arrange(desc(AUC))
  
  message(paste0("\n", strrep("=", 60)))  # FIXED
  message("MODEL COMPARISON SUMMARY")
  message(strrep("=", 60))  # FIXED
  print(comparison_df, row.names = FALSE)
  
  # Select best model by AUC
  best_model_name <- comparison_df$Model[1]
  best_model <- models$models[[best_model_name]]
  
  message(paste("\n🏆 BEST MODEL:", best_model_name))
  message(paste("   AUC:", round(comparison_df$AUC[1], 4)))
  
  # Save results
  saveRDS(results, "models/evaluation_results.rds")
  write.csv(comparison_df, "output/model_comparison.csv", row.names = FALSE)
  
  # Create visualizations
  create_evaluation_plots(results, roc_curves, comparison_df)
  
  # Save best model separately
  saveRDS(best_model, "models/best_model.rds")
  
  return(list(
    results = results,
    comparison = comparison_df,
    best_model = best_model,
    best_model_name = best_model_name
  ))
}
