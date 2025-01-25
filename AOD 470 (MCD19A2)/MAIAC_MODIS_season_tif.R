#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Libraries  ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Load necessary libraries
library(sf)
library(terra)
library(purrr)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# .tif files ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Define the list of directories (folders) for each year
years <- c(2017, 2018, 2019, 2020, 2021, 2022)
folders <- paste0("C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/", 
                  "OUTPUT_MAIAC_",
                  years)

save_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/OUTPUT_MAIAC_Seasonal_tif"

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Define seasons ·······························································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Define the Julian day ranges for each season considering is not a leap year (at the end is considered)
seasons <- list(
  "Summer" = list(c(335, 365), c(1, 59)),   # Dec (from previous year) + Jan, Feb (current year)
  "Autumn" = list(c(60, 151)),              # Mar, Apr, May
  "Winter" = list(c(152, 243)),             # Jun, Jul, Aug
  "Spring" = list(c(244, 334))              # Sep, Oct, Nov
)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ROI ··········································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Path of region of interest (ROI) 
ROI_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/"
StudyRegion <- read_sf(paste(ROI_path, 'StudyArea_Tesis.kml', sep = ""))

# To use in terra:crop (Because rasters are in sinusoidal projection)
extent <- terra::ext(StudyRegion)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Function to process seasonal means and st.dev ································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

process_seasonal_tif <- function(year_folder, year, season, season_days, previous_year_folder = NULL) {
  
  # If season includes December from the previous year
  if (!is.null(previous_year_folder)) {
    previous_year_days <- list.files(path = previous_year_folder, pattern = ".tif", full.names = TRUE)
    previous_december_files <- previous_year_days[sapply(previous_year_days, function(x) { 
      day_num <- as.numeric(gsub(".*meanAOD_(\\d+).tif", "\\1", x)) # Get the julian number of each file
      day_num >= season_days[[1]][1] && day_num <= season_days[[1]][2] # Compare if day_num falls into season_days range
    })]
  } else {
    previous_december_files <- c()  # If no matching, No December days to add
  }
  
  # Get the list of .tif files for the current year (Ej. ONLY Jan, Feb for Summer)
  current_year_days <- list.files(path = year_folder, pattern = ".tif", full.names = TRUE)
  current_files <- current_year_days[sapply(current_year_days, function(x) { 
    day_num <- as.numeric(gsub(".*meanAOD_(\\d+).tif", "\\1", x)) # Get the julian number of each file
    any(sapply(season_days, function(days) day_num >= days[1] && day_num <= days[2])) # Compare if day_num falls into season_days range
  })]
  
  # Combine December days from the previous year with current year days
  all_files <- c(previous_december_files, current_files)
  
  # Read all rasters
  raster_list <- map(all_files, rast)
  
  # Crop rasters to the study region
  raster_crop <- map(raster_list, crop, extent)
  
  # Resample to align
  reference_raster <- raster_crop[[1]]
  raster_resampled <- map(raster_crop, resample, y = reference_raster)
  
  # Stack all rasters for the season
  raster_stack <- rast(raster_resampled)
  
  # Calculate the mean raster for the season
  season_mean <- mean(raster_stack, na.rm = TRUE)
  
  # Calculate the standard deviation raster for the season
  season_sd <- stdev(raster_stack, pop = TRUE, na.rm = TRUE)
  
  # Save the seasonal mean raster
  mean_filename <- file.path(save_path, paste0("meanAOD_", year, "_", season,".tif"))
  writeRaster(season_mean, mean_filename, overwrite = TRUE)
  
  # Save the seasonal standard deviation raster
  sd_filename <- file.path(save_path, paste0("sdAOD_", year, "_", season,".tif"))
  writeRaster(season_sd, sd_filename, overwrite = TRUE)
  
  print(paste0("Saving .tif from: ", season, " mean and St Dev. for year ", year))
  
  rm(raster_stack, raster_resampled, raster_crop, raster_list)
  gc()
}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Function to check if a year is a leap year ····································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# A year is a leap year if:
#  --- It is divisible by 4 AND
#  --- It is NOT divisible by 100, unless
#  --- It is also divisible by 400.

is_leap_year <- function(year) {
  return((year %% 4 == 0 && year %% 100 != 0) || (year %% 400 == 0))
}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Main loop to process each seasons per year ···································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


for (i in 2:length(folders)) { # Start from index 2, which corresponds to 2018, to avoid processing 2017 (exept from December)
  year_folder <- folders[i]
  year <- years[i]
  
  # Check if there's a previous year to use for December files (only applies to Summer)
  previous_year_folder <- if (i > 1) folders[i - 1] else NULL
  
  print(paste0("Processing year: ", year))
  
  # Check if it's a leap year and adjust February days for "Summer"
  if (is_leap_year(year)) {
    print(paste0(year, " is a leap year. Adjusting summer season day range to include February 29."))
    # Adjust "Summer" season to include Feb 29
    seasons$Summer[[2]][2] <- 60  # Set the end of February to 60 in leap years
  } else {
    # Reset to non-leap year if needed
    seasons$Summer[[2]][2] <- 59  # Regular end of February is day 59
  }
  
  for (season in names(seasons)) {
    season_days <- seasons[[season]]
    
    # Explanation for Summer and previous year handling
    if (season == "Summer") {
      if (is.null(previous_year_folder)) {
        print(paste0("For ", season, " of year ", year, ": No previous year folder provided. Only January and February files of ", year, " will be used."))
      } else {
        print(paste0("For ", season, " of year ", year, ": Including December files from the previous year (", years[i-1], ")."))
      }
    }
    
    # Process each season
    process_seasonal_tif(
      year_folder = year_folder, 
      year = year, 
      season = season, 
      season_days = season_days, 
      previous_year_folder = previous_year_folder
    )
  }
}
