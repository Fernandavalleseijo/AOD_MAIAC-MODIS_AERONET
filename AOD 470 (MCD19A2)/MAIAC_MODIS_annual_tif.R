#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Libraries  ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Load necessary libraries
library(sf)
library(terra)
library(purrr)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Paths (the only thing to modify) ·············································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Define the list of directories (folders) for each year
years <- c(2018,2019, 2020, 2021, 2022) # Change this depending on how many years you are working with
folders <- paste0("C:/Users/", # Change this to your desired directory
                  years)
# Path of region of interest (ROI) 
ROI_path <- "C:/Users/" # Change this to your desired path where the .kml file is stored

save_path <- "C:/Users/" # Change this to your desired output directory

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ROI ··········································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# ROI Vector in crs = Long-Lat 
StudyRegion <- read_sf(ROI_path)

# To use in terra:crop (Because rasters are in sinusoidal projection)
extent = terra::ext(StudyRegion)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Processing ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Loop through each folder, calculate the mean and standard deviation, and save the results
for (i in seq_along(folders)) {
  
  year_folder <- folders[i]
  year <- years[i]
  
  print(paste0("Processing year: ", year))
  
  # Get the list of .tif files in the current year's folder
  tif_files <- list.files(path = year_folder, pattern = ".tif", full.names = TRUE)
  
  # Read all the .tif files as a list of rasters for the current year
  raster_list <- map(tif_files, rast)
  
  rm(tif_files)
  gc()
  
  # Crop the files to avoid the blank parts related to the mask from the previous code
  raster_crop <- map(raster_list, crop, extent)
  
  rm(raster_list)
  gc()
  
  print("Aligning rasters...")
  
  # Take the first raster of the list as a reference raster 
  # To resample all the rasters so they align (align was affected because of mosaic)
  reference_raster <- raster_crop[[1]]
  raster_list_resampled <- map(raster_crop, resample, y = reference_raster)
  
  rm(raster_crop)
  gc()
  
  # Stack all rasters for the current year
  raster_stack <- rast(raster_list_resampled)
  
  rm(reference_raster)
  rm(raster_list_resampled)
  gc()
  
  print("Computing statistics...")
  
  # Calculate the mean raster for the current year
  annual_mean <- mean(raster_stack, na.rm = TRUE)
  
  # Calculate the standard deviation raster for the current year
  annual_sd <- stdev(raster_stack, pop = TRUE, na.rm = TRUE)
  
  rm(raster_stack)
  gc()
  
  # Save the mean raster
  mean_filename <- file.path(save_path, paste0("meanAOD_", year, ".tif"))
  writeRaster(annual_mean, mean_filename, overwrite=TRUE)
  
  # Save the standard deviation raster
  sd_filename <- file.path(save_path,paste0("sdAOD_", year, ".tif"))
  writeRaster(annual_sd, sd_filename, overwrite=TRUE)
  
  rm(annual_mean)
  rm(annual_sd)
  gc()
}




