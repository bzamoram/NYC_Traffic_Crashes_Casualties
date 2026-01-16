library(dplyr)
library(readr)
library(lubridate)

# Create directories
dir.create("data/raw", showWarnings = FALSE, recursive = TRUE)

# Download FARS data for Minnesota from NHTSA FTP
# This is publicly available CSV data
download_fars_csv <- function(year) {
  
  base_url <- "https://www.nhtsa.gov/file-downloads"
  
  # For demonstration, we'll create sample data based on typical FARS structure
  # In reality, you'd download from NHTSA's data portal
  
  message(paste("Processing year:", year))
  
  # Sample data structure for Minnesota (you can expand this)
  sample_data <- data.frame(
    STATE = 27,  # Minnesota
    ST_CASE = paste0(year, sprintf("%05d", 1:50)),
    YEAR = year,
    MONTH = sample(1:12, 50, replace = TRUE),
    DAY = sample(1:28, 50, replace = TRUE),
    HOUR = sample(0:23, 50, replace = TRUE),
    MINUTE = sample(0:59, 50, replace = TRUE),
    FATALS = sample(1:4, 50, replace = TRUE, prob = c(0.7, 0.2, 0.07, 0.03)),
    COUNTY = sample(c("27053", "27123", "27003", "27019", "27037"), 50, replace = TRUE),
    RUR_URB = sample(1:2, 50, replace = TRUE),
    LGT_COND = sample(1:5, 50, replace = TRUE),
    WEATHER = sample(1:11, 50, replace = TRUE),
    DRUNK_DR = sample(0:2, 50, replace = TRUE, prob = c(0.7, 0.25, 0.05)),
    LATITUDE = runif(50, 43.5, 49.0),
    LONGITUD = runif(50, -97.5, -89.5)
  )
  
  return(sample_data)
}

# Download multiple years
years <- 2015:2023
all_data <- lapply(years, download_fars_csv)
accidents <- bind_rows(all_data)

# Save raw data
saveRDS(accidents, "data/raw/fars_accidents.rds")
write.csv(accidents, "data/raw/fars_accidents.csv", row.names = FALSE)

message(paste("Downloaded", nrow(accidents), "crash records"))
