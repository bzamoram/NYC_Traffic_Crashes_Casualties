source("src/00_download_fars_data.R")
source("src/02_transform_data.R")
source("src/03_load_data.R")

run_fars_pipeline <- function(from_year = 2015, to_year = 2023) {
  
  dir.create("data/raw", showWarnings = FALSE, recursive = TRUE)
  dir.create("logs", showWarnings = FALSE)
  
  log_file <- paste0("logs/pipeline_", Sys.Date(), ".log")
  sink(log_file, append = TRUE, split = TRUE)
  
  tryCatch({
    message(strrep("=", 60))
    message("Starting FARS ETL Pipeline for Minnesota")
    message(paste("Timestamp:", Sys.time()))
    message(strrep("=", 60))
    
    # EXTRACT - Download data
    message("\n[1/3] DOWNLOADING FARS DATA...")
    years <- from_year:to_year
    all_data <- lapply(years, download_fars_csv)
    accidents <- bind_rows(all_data)
    message(paste("✓ Downloaded", nrow(accidents), "crash records"))
    
    # TRANSFORM
    message("\n[2/3] TRANSFORMING AND ENGINEERING FEATURES...")
    clean_data <- transform_fars_data(accidents)
    message("✓ Transformation complete")
    
    # VALIDATE
    message("\n[2.5/3] VALIDATING DATA QUALITY...")
    is_valid <- validate_data(clean_data)
    
    # LOAD
    message("\n[3/3] LOADING TO DATABASE...")
    load_to_database(clean_data)
    message("✓ Data loaded to database")
    
    message(paste0("\n", strrep("=", 60)))
    message("PIPELINE COMPLETED SUCCESSFULLY!")
    message(paste("Total crashes processed:", nrow(clean_data)))
    message(paste("Total fatalities:", sum(clean_data$total_fatalities)))
    message(strrep("=", 60))
    
    saveRDS(list(
      pipeline_run_date = Sys.time(),
      years_processed = from_year:to_year,
      records_processed = nrow(clean_data),
      status = "SUCCESS"
    ), "data/pipeline_metadata.rds")
    
  }, error = function(e) {
    message("\n❌ PIPELINE FAILED!")
    message(paste("Error:", e$message))
    
    saveRDS(list(
      pipeline_run_date = Sys.time(),
      status = "FAILED",
      error_message = e$message
    ), "data/pipeline_metadata.rds")
  })
  
  sink()
  message(paste("Log saved to:", log_file))
}
