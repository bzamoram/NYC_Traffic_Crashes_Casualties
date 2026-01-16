library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)

# NHTSA FARS API base URL
FARS_BASE_URL <- "https://crashviewer.nhtsa.dot.gov/CrashAPI"

# Extracting Minnesota crash data from FARS API
# Minnesota state code = 27
extract_fars_data <- function(from_year = 2015, to_year = 2024) {
  
  message(paste("Extracting FARS data for Minnesota:", from_year, "to", to_year))
  
  # Endpoint: Getting Crashes By Location for Minnesota
  endpoint <- paste0(FARS_BASE_URL, "/crashes/GetCrashesByLocation")
  
  response <- GET(
    endpoint,
    query = list(
      fromCaseYear = from_year,
      toCaseYear = to_year,
      state = 27,  # Minnesota state code
      format = "json"
    )
  )
  
  # Checking response status
  if (status_code(response) != 200) {
    stop(paste("API request failed with status:", status_code(response)))
  }
  
  # Parsing JSON response
  crash_list <- content(response, as = "parsed", type = "application/json")
  
  message(paste("Retrieved", length(crash_list$Results), "crash records"))
  
  return(crash_list$Results)
}

# Getting detailed crash information for each case
get_crash_details <- function(crash_cases) {
  
  details_list <- list()
  
  for (i in seq_along(crash_cases)) {
    case_info <- crash_cases[[i]]
    
    endpoint <- paste0(FARS_BASE_URL, "/crashes/GetCaseDetails")
    
    response <- GET(
      endpoint,
      query = list(
        stateCase = case_info$CaseNumber,
        caseYear = case_info$CaseYear,
        state = 27,
        format = "json"
      )
    )
    
    if (status_code(response) == 200) {
      details_list[[i]] <- content(response, as = "parsed")
    }
    
    # Rate limiting
    if (i %% 50 == 0) {
      message(paste("Processed", i, "of", length(crash_cases)))
      Sys.sleep(1)
    }
  }
  
  return(details_list)
}

#' Get FARS raw dataset tables (Accident, Person, Vehicle)
get_fars_dataset <- function(dataset = "Accident", from_year = 2015, to_year = 2024) {
  
  endpoint <- paste0(FARS_BASE_URL, "/FARSData/GetFARSData")
  
  response <- GET(
    endpoint,
    query = list(
      dataset = dataset,  # Options: Accident, Person, Vehicle, Distract, etc.
      FromYear = from_year,
      ToYear = to_year,
      State = 27,
      format = "json"
    )
  )
  
  data <- content(response, as = "parsed", type = "application/json")
  
  # Convert to data frame
  df <- bind_rows(data$Results)
  
  message(paste("Retrieved", nrow(df), "records from", dataset, "dataset"))
  
  return(df)
}

#' Main extraction function - gets all relevant datasets
extract_all_fars_data <- function(from_year = 2015, to_year = 2024) {
  
  # Get three main datasets
  accidents <- get_fars_dataset("Accident", from_year, to_year)
  persons <- get_fars_dataset("Person", from_year, to_year)
  vehicles <- get_fars_dataset("Vehicle", from_year, to_year)
  
  # Save raw data
  saveRDS(list(
    accidents = accidents,
    persons = persons,
    vehicles = vehicles,
    extraction_date = Sys.Date()
  ), "data/raw/fars_raw_data.rds")
  
  return(list(accidents = accidents, persons = persons, vehicles = vehicles))
}
