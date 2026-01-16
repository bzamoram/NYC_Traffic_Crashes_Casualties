library(DBI)
library(RSQLite)

#' Load transformed data to SQLite database
load_to_database <- function(transformed_data, db_path = "data/minnesota_fars.db") {
  
  # Connect to database
  con <- dbConnect(SQLite(), db_path)
  
  # Write main table
  dbWriteTable(con, "fatal_crashes", transformed_data, 
               overwrite = FALSE, append = TRUE)
  
  # Create indexes for query performance
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_crash_year 
                  ON fatal_crashes(crash_year)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_crash_datetime 
                  ON fatal_crashes(crash_datetime)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_county 
                  ON fatal_crashes(county)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_metro 
                  ON fatal_crashes(metro_area)")
  dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_winter 
                  ON fatal_crashes(winter_crash)")
  
  # Create materialized view for model features
  dbExecute(con, "DROP VIEW IF EXISTS model_features")
  dbExecute(con, "CREATE VIEW model_features AS
                  SELECT 
                    case_id,
                    crash_year,
                    hour_of_day,
                    day_of_week,
                    is_weekend,
                    season,
                    winter_crash,
                    metro_area,
                    rural_crash,
                    intersection_related,
                    adverse_weather,
                    snow_ice_weather,
                    icy_road,
                    dark_conditions,
                    num_vehicles,
                    speed_related,
                    alcohol_involved,
                    work_zone,
                    multiple_fatalities,
                    high_severity
                  FROM fatal_crashes
                  WHERE latitude IS NOT NULL")
  
  # Create analytics view for visualizations
  dbExecute(con, "DROP VIEW IF EXISTS crash_analytics")
  dbExecute(con, "CREATE VIEW crash_analytics AS
                  SELECT 
                    crash_year,
                    county,
                    season,
                    COUNT(*) as crash_count,
                    SUM(total_fatalities) as total_deaths,
                    AVG(total_fatalities) as avg_deaths_per_crash,
                    SUM(CASE WHEN winter_crash THEN 1 ELSE 0 END) as winter_crashes,
                    SUM(CASE WHEN snow_ice_weather THEN 1 ELSE 0 END) as snow_ice_crashes,
                    SUM(CASE WHEN alcohol_involved THEN 1 ELSE 0 END) as alcohol_crashes,
                    SUM(CASE WHEN pedestrian_involved THEN 1 ELSE 0 END) as pedestrian_deaths
                  FROM fatal_crashes
                  GROUP BY crash_year, county, season")
  
  # Get record count
  record_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM fatal_crashes")
  message(paste("Database contains", record_count$count, "total records"))
  
  dbDisconnect(con)
  
  message("Data successfully loaded to database!")
}
