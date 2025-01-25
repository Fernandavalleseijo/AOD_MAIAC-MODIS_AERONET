#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Paths (the only thing to modify) ·············································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Base HDF file path (up to the year)
base_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/MCD19A2_061_"

csv_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/OUTPUT_CSV/"

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Files from tile h13v12 (includes AERONET location) ···························
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Initialize an empty character vector to store the file paths
all_files_h13v12 <- character()

# Loop through the years from 2017 to 2022
for (year in 2017:2022) {
  # Construct the full HDF path for the current year
  hdf_path <- paste0(base_path, year, "/")
  
  # Get the files for h13v12 for the current year
  files_h13v12 <- dir(path = hdf_path, pattern = "h13v12", full.names = TRUE)
  
  # Append the file paths to the character vector
  all_files_h13v12 <- c(all_files_h13v12, files_h13v12)
}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Extract orbit_time_stamps in a data.frame (year, day, hr, min, satellite) ····
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

metadata_list <- lapply(all_files_h13v12, terra::describe)


orbit_time_stamps <- lapply(metadata_list, function(metadata) {
  metadata[grepl("Orbit_time_stamp", metadata)]
})


# Define a function to extract components from a single orbit time stamp string
extract_time_stamp <- function(time_stamp_string) {
  # Remove leading spaces and "Orbit_time_stamp="
  time_stamp_string <- gsub("^\\s*Orbit_time_stamp=", "", time_stamp_string)
  
  # Split the string into individual time stamps
  time_stamps <- unlist(strsplit(time_stamp_string, "\\s+")) # The splitting criterion here is whitespace = \\s+
  
  # Initialize an empty list to store the results
  result_list <- list()
  
  # Loop through each time stamp and extract components
  for (time_stamp in time_stamps) {
    year <- substr(time_stamp, 1, 4)
    julian_day <- substr(time_stamp, 5, 7)
    hour <- substr(time_stamp, 8, 9)
    minute <- substr(time_stamp, 10, 11)
    satellite <- substr(time_stamp, 12, 12)
    
    # Append the components to the result list as a named list
    result_list[[length(result_list) + 1]] <- list(
      year = year,
      julian_day = julian_day,
      hour = hour,
      minute = minute,
      satellite = satellite
    )
  }
  
  # Return the result as a data frame
  return(do.call(rbind, result_list))
}

# Apply this function to all elements in orbit_time_stamps
all_time_stamps_matrix <- do.call(rbind, lapply(orbit_time_stamps, extract_time_stamp))

all_time_stamps <- as.data.frame(all_time_stamps_matrix)


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Save as .csv ·································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

all_time_stamps[] <- lapply(all_time_stamps, function(x) {
  if (is.list(x)) {
    return(as.character(unlist(x)))  # Convert to character vector
  } else {
    return(x)  # Leave other columns unchanged
  }
})


write.table(all_time_stamps, paste0(csv_path, "all_time_stamps.csv") , sep = ",", row.names = FALSE)

