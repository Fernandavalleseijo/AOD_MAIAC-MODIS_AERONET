#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Libraries  ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

library(sf)
library(terra)

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

# Loop through the years from 2020 to 2022 (only L2 Aeronet data for montevideo available for 2020-2022)
for (year in 2020:2022) {
  # Construct the full HDF path for the current year
  hdf_path <- paste0(base_path, year, "/")
  
  # Get the files for h13v12 for the current year
  files_h13v12 <- dir(path = hdf_path, pattern = "h13v12", full.names = TRUE)
  
  # Append the file paths to the character vector
  all_files_h13v12 <- c(all_files_h13v12, files_h13v12)
}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Region of interest (ROI) ·····················································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Path of region of interest (ROI) 
ROI_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/KML/"

# ROI Vector in crs = Long-Lat 
Montevideo_window_25km <- read_sf(paste(ROI_path,'Montevideo_win_25km.kml', sep = ""))

# Raster Projection - Sinusoidal - (MAIAC MCD19A2 V61)
proj_sinu <- terra::crs("ESRI:53008") 

# Longitude Latitude Projection (Most commonly used)
proj_longlat <- terra::crs("EPSG:4326")

# ROI Vector in crs = Sinusoidal 
Montevideo_window_sinu <- st_transform(Montevideo_window_25km, crs=proj_sinu)

# To use in terra:crop (Because rasters are in sinusoidal projection)
extent = terra::ext(Montevideo_window_sinu)


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# AOD and QA for AOD ··························································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Apply the terra::rast function to each file
AOD_list <- lapply(all_files_h13v12, function(file) {
  terra::rast(file, subds="Optical_Depth_047", win=extent)
})

AOD_QA_list <- lapply(all_files_h13v12, function(file) {
  terra::rast(file, subds="AOD_QA", win=extent)
})

# Convert rasters to data frames
AOD_df_list <- lapply(AOD_list, function(aod_raster) {
  as.data.frame(aod_raster, xy = TRUE)
})

AOD_QA_df_list <- lapply(AOD_QA_list, function(aod_qa_raster) {
  as.data.frame(aod_qa_raster, xy = TRUE)
})

# Reduce QA data frames to match AOD data frames
AOD_QA_df_reduced_list <- lapply(seq_along(AOD_df_list), function(i) {
  row_names <- as.numeric(rownames(AOD_df_list[[i]]))
  AOD_QA_df_list[[i]][row_names, ]
})

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Filter AOD with QA for AOD ···················································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Function to extract QA for AOD bits (8-11)
extract_AOD_quality_bits <- function(num) {
  if (!is.na(num)) {
    AOD_quality_bits <- bitwAnd(bitwShiftR(num, 8), 15)  # Extract bits 8-11
    return(AOD_quality_bits)
  } else {
    return(NA)
  }
}

# Function to process each column of AOD_df and apply QA filter
process_AOD_layer <- function(col_index, AOD_df, AOD_QA_df_reduced) {
  # Extract QA for AOD bits (8-11)
  QA_bits_AOD <- sapply(AOD_QA_df_reduced[, col_index], extract_AOD_quality_bits)
  
  # Best quality corresponds to bits 8-11 being "0000" (decimal 0)
  valid_AOD_quality <- QA_bits_AOD == 0
  
  # Handle NAs in the QA data
  valid_AOD_quality[is.na(valid_AOD_quality)] <- FALSE
  
  # Apply the QA filter: Set values to NA where the quality is not best
  AOD_df[!valid_AOD_quality, col_index] <- NA
  
  return(AOD_df[, col_index])
}

# Apply the QA filter to all files using lapply
AOD_df_filtered_list <- lapply(seq_along(AOD_df_list), function(i) {
  AOD_df <- AOD_df_list[[i]]  # Get the AOD data frame for this file
  AOD_QA_df_reduced <- AOD_QA_df_reduced_list[[i]]  # Corresponding reduced QA data frame
  
  if (nrow(AOD_df) != 0) {  # Skip empty files
    
    # Apply the process_AOD_layer function to each column of AOD_df starting from column 3
    AOD_df_filtered <- AOD_df  # Copy AOD_df to store filtered values
    AOD_df_filtered[, 3:ncol(AOD_df)] <- lapply(3:ncol(AOD_df), function(col_index) {
      print(paste0("Processing layer N°", col_index, "/", ncol(AOD_df)))
      process_AOD_layer(col_index, AOD_df, AOD_QA_df_reduced)
    })
    
    # Convert the list back to data frame (since lapply produces a list for each column)
    AOD_df_filtered <- as.data.frame(AOD_df_filtered)
    
    return(AOD_df_filtered)  # Return the filtered data frame
  }
})

extracted_names <- sub(".*\\.A(\\d{7})\\..*", "\\1", all_files_h13v12)

# Assign those names to your AOD_df_filtered_list
names(AOD_df_filtered_list) <- extracted_names

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Extract puntual - bilinear - AOD for each layer ······························
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

extract_mean_fun <- function(aod_df) {
  # Check if the input data frame is NULL or empty
  if (is.null(aod_df) || nrow(aod_df) == 0) {
    return(NULL)  # Return NULL for empty or NULL data frames
  }
  
  # Select only the columns that start with "Optical_Depth_047_" and calculate the mean
  optical_depth_cols <- grep("^Optical_Depth_047_", names(aod_df), value = TRUE)
  
  # Calculate the mean for each Optical_Depth_047_* column, ignoring NA values
  mean_values <- sapply(aod_df[optical_depth_cols], function(column) mean(column, na.rm = TRUE))
  
  return(mean_values)
}

# Apply the function to each element of the AOD_df_filtered_list
results <- lapply(AOD_df_filtered_list, extract_mean_fun)

#------------------------------------------------------------------------------
# Create unique data frame 

# Create an empty data frame to store the combined results
combined_results <- data.frame(Year = integer(),
                               Julian_Date = integer(),
                               Layer = character(),
                               AOD_25km = numeric(),
                               stringsAsFactors = FALSE)

# Loop through each element in the results list
for (name in names(results)) {
  # Get the current result vector (mean values for each optical depth column)
  result_vector <- results[[name]]
  
  # Extract year and Julian date from the ID
  year <- as.integer(substr(name, 1, 4))  # First four characters for year
  julian_date <- as.integer(substr(name, 5, 7))  # Next three characters for Julian date
  
  # Check if result_vector is not NULL and has data
  if (!is.null(result_vector) && length(result_vector) > 0) {
    # Loop through each optical depth value in the vector
    for (optical_col in names(result_vector)) {
      # Create a temporary data frame with year, Julian date, optical depth name, and values
      temp_df <- data.frame(Year = year,
                            Julian_Date = julian_date,
                            Layer = optical_col,
                            AOD_25km = result_vector[optical_col],
                            stringsAsFactors = FALSE)
      
      # Bind the temporary data frame to the combined results
      combined_results <- rbind(combined_results, temp_df)
    }
  }
}

#------------------------------------------------------------------------------
# Merge orbit_time_stamps df and combined results df 

# Load dplyr for data manipulation
library(dplyr)

all_time_stamps <- read.csv(paste0(csv_path, "all_time_stamps.csv"), sep = ",")

# Ensure both Year and Julian_Date are integers in both data frames
combined_results$Year <- as.integer(combined_results$Year)
combined_results$Julian_Date <- as.integer(combined_results$Julian_Date)
all_time_stamps$year <- as.integer(unlist(all_time_stamps$year))
all_time_stamps$julian_day <- as.integer(unlist(all_time_stamps$julian_day))

# Add an index column to uniquely identify each row in both dataframes
combined_results <- combined_results %>%
  group_by(Year, Julian_Date) %>%
  mutate(row_id = row_number()) %>%
  ungroup()

all_time_stamps <- all_time_stamps %>%
  group_by(year, julian_day) %>%
  mutate(row_id = row_number()) %>%
  ungroup()

# Merge on Year/Julian_Date with the unique row_id to avoid Cartesian product
merged_df <- combined_results %>%
  left_join(
    all_time_stamps, 
    by = c("Year" = "year", "Julian_Date" = "julian_day", "row_id" = "row_id")
  ) %>%
  select(-row_id)  # Drop row_id column if no longer needed


# Filter out rows where AOD_Bilinear is NA
filtered_df <- merged_df %>%
  filter(!is.na(AOD_25km))

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Save as .csv ·································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

filtered_df[] <- lapply(filtered_df, function(x) {
  if (is.list(x)) {
    return(as.character(unlist(x)))  # Convert to character vector
  } else {
    return(x)  # Leave other columns unchanged
  }
})

write.table(filtered_df, paste0(csv_path, "MAIAC_MODIS_25KM_MONTEVIDEO.csv"), sep = ",", row.names = FALSE)

