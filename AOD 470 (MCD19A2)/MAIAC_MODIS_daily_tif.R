#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Libraries  ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

library(sf)
library(terra)
library(ggplot2)
library(ggspatial)
library(rlang)        # Para ggmap
library(vctrs)        # Para ggmap
library(ggmap)        # Para agregar mapa base a los plots de ggplot
library(scales)       # oob=squish de de ggplot
library(osmdata)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Paths (the only thing to modify) ·············································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Directory to search for .hdf files
hdf_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/MCD19A2_061_2017/"

# Directory to save output .tiff files
output_directory <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/OUTPUT_MAIAC_2017"  # Change this to your desired output directory

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Files ·······································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# HDF files divided by tile related to the area of study
files_h12v11 <- dir(path = hdf_path, pattern="h12v11", full.names=TRUE)
files_h12v12 <- dir(path = hdf_path, pattern="h12v12", full.names=TRUE) 
files_h13v11 <- dir(path = hdf_path, pattern="h13v11", full.names=TRUE)
files_h13v12 <- dir(path = hdf_path, pattern="h13v12", full.names=TRUE) 

# Combine all file lists into a single list
all_file_lists <- list(
  h12v11 = files_h12v11,
  h12v12 = files_h12v12,
  h13v11 = files_h13v11,
  h13v12 = files_h13v12
)

# Get the maximum length of the files across all tiles
max_length <- max(sapply(all_file_lists, length))


#------------------------------------------------------------------------------
# Check missing files for each tile and organize all tiles together 

# Function to process the files and insert NA where files are missing
process_files <- function(files) {
  # Extract Julian dates from filenames
  extract_julian_date <- function(file) {
    match <- regmatches(file, regexpr("A([0-9]{4})([0-9]{3})", file)) # Updated regex
    if (length(match) > 0) {
      year <- sub("A([0-9]{4})([0-9]{3})", "\\1", match)  # Extract the year
      julian_date <- sub("A([0-9]{4})([0-9]{3})", "\\2", match)  # Extract the Julian date
      return(as.numeric(julian_date))  # Return as numeric
    } else {
      return(NA)  # Handle cases with no match
  }
}
  
# Apply the function to extract the Julian dates from filenames
file_dates <- sapply(files, extract_julian_date)
  
# Create a list with max_length slots (one for each Julian date)
file_list <- vector("list", length = max_length)
  
  # Loop through the expected Julian dates and fill in the files or NA
  for (i in 1:max_length) {
    if (i %in% file_dates) {
      file_index <- which(file_dates == i)
      file_list[[i]] <- files[file_index]
    } else {
      file_list[[i]] <- NA
    }
  }
  
  # Convert the list to a vector (optional)
  file_list <- unlist(file_list)
  
  return(file_list)
}

# Process each set of files
file_list_h12v11 <- process_files(files_h12v11)
file_list_h12v12 <- process_files(files_h12v12)
file_list_h13v11 <- process_files(files_h13v11)
file_list_h13v12 <- process_files(files_h13v12)

rm(files_h12v11)
rm(files_h12v12)
rm(files_h13v11)
rm(files_h13v12)
rm(all_file_lists)

# Initialize lists for all tiles
tiles <- list(
  h12v11 = list(files = file_list_h12v11),
  h12v12 = list(files = file_list_h12v12),
  h13v11 = list(files = file_list_h13v11),
  h13v12 = list(files = file_list_h13v12))

rm(file_list_h12v11)
rm(file_list_h12v12)
rm(file_list_h13v11)
rm(file_list_h13v12)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Region of interest (ROI) ·····················································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Path of region of interest (ROI) 
ROI_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/"

# Raster Projection - Sinusoidal - (MAIAC MCD19A2 V61)
proj_sinu <- terra::crs("ESRI:53008") 

# Longitude Latitude Projection (Most commonly used)
proj_longlat <- terra::crs("EPSG:4326")

# ROI Vector in crs = Long-Lat 
StudyRegion <- read_sf(paste(ROI_path,'StudyArea_Tesis.kml', sep = ""))

# ROI Vector in crs = Sinusoidal 
StudyRegion_sinu <- st_transform(StudyRegion, crs=proj_sinu)

# To use in terra:crop (Because rasters are in sinusoidal projection)
extent = terra::ext(StudyRegion_sinu)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Function to extract QA for AOD bits (8-11) inside the loop ···················
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

extract_AOD_quality_bits <- function(num) {
  if (!is.na(num)) {
    # bitwShiftR: shift bits 8 to 16 to the beginning (right shift)
    # bitwAnd: compare the last 4 bits with 1111 (i.e., last 4 bits of integer 15)
    # This retrieves the 4 bits corresponding to QA for AOD as an integer
    AOD_quality_bits <- bitwAnd(bitwShiftR(num, 8), 15)  
    return(AOD_quality_bits)                              
  } else {
    return(NA)
  }
}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Proccesing ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Find the maximum length among the file lists
max_length <- max(sapply(tiles, function(x) length(x$files)))

# First loop is iterating through each file (daily data)
for (i in 1:max_length) {
  
  # Initialize temporary lists for AOD and QA tiles for merging
  AOD_tiles <- list()
  AOD_QA_tiles <- list()
  
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Store the four tiles of each files together
  
  # Second loop is iterating through each tile: "h12v11" "h12v12" "h13v11" "h13v12"
  for (tile_name in names(tiles)) {
    tile <- tiles[[tile_name]]
    
    # Ensure we don't exceed the length of any list
    if (i <= length(tile$files)) {
      print(paste0("Processing ", tile_name, " N°file: ", i, "/", length(tile$files)))
      
      # Check if the file is NA
      if (is.na(tile$files[i])) {
        print(paste("Skipping file N°", i, "for", tile_name, "due to missing files (NA)"))
        next
      }
      
      # Raster of AOD and QA of AOD for each file
      AOD_tile <- terra::rast(tile$files[i], subds="Optical_Depth_047")
      AOD_QA_tile <- terra::rast(tile$files[i], subds="AOD_QA")
      
      # Store temporary tiles for merging (AOD_tiles will store the 4 tiles together)
      AOD_tiles <- append(AOD_tiles, list(AOD_tile))
      AOD_QA_tiles <- append(AOD_QA_tiles, list(AOD_QA_tile))
    }
  }
  
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Merge using terra::mosaic the four tiles of each files together
  
  # Remove NULL or empty layers before attempting mosaic
  AOD_tiles <- AOD_tiles[!sapply(AOD_tiles, function(x) is.null(x) || terra::nlyr(x) == 0)]
  AOD_QA_tiles <- AOD_QA_tiles[!sapply(AOD_QA_tiles, function(x) is.null(x) || terra::nlyr(x) == 0)]
  
  if (length(AOD_tiles) > 0) {
    # Mosaic the tiles using mean function
    AOD_merged <- do.call(terra::mosaic, c(AOD_tiles, fun = "mean"))
    AOD_QA_merged <- do.call(terra::mosaic, c(AOD_QA_tiles, fun = "mean"))
  
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Crop the mosaic using ROI extent
    
    # Crop the rasters to the region of interest
    AOD_crop <- terra::crop(AOD_merged, extent)
    AOD_QA_crop <- terra::crop(AOD_QA_merged, extent)
 
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Create data frames of AOD values and QA for AOD values to compare them   
    
    # Convert cropped rasters to data frames
    AOD_df <- as.data.frame(AOD_crop, xy = TRUE)
    AOD_QA_df <- as.data.frame(AOD_QA_crop, xy = TRUE)
    
    # Extract row indices from AOD (fewer rows than QA)
    row_names <- as.numeric(rownames(AOD_df))
    
    # Reduce QA DataFrame to match AOD
    AOD_QA_df_reduced <- AOD_QA_df[row_names, ]
    
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Filter AOD df using QA df (Turn AOD values to NA when QA is NOT Best Quality -0000-) 
    
    # Now apply the QA filter based on bits 8-11
    if (nrow(AOD_df) != 0) {  # Skip empty files
      
      for (col in 3:ncol(AOD_df)) {
        
        print(paste0("Processing layer N°", col, "/", ncol(AOD_df)))
        
        # Extract QA for AOD bits (8-11)
        QA_bits_AOD <- sapply(AOD_QA_df_reduced[, col], extract_AOD_quality_bits)
        
        # Filter based on AOD QA ( bits "0000" = 0 decimal, representing best quality)
        valid_AOD_quality <- QA_bits_AOD == 0  # Best quality corresponds to bits 8-11 being "0000"
        
        # Ensure QA values that are NAs are handled by treating them as invalid (set to FALSE)
        valid_AOD_quality[is.na(valid_AOD_quality)] <- FALSE
        
        # Apply the quality filter: Set values to NA where the quality is NOT best = 0 valid_AOD_quality=TRUE
        AOD_df[!valid_AOD_quality, col] <- NA
      }
    }
    
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Calculate the mean values of all layers available for each file
    
    if (!nrow(AOD_df) %in% c(0, 1, 2)) {
      
      # Calculate the daily mean AOD across all columns (after QA filtering)
      meanAOD <- rowMeans(AOD_df[, 3:ncol(AOD_df)], na.rm = TRUE)
      
      # Combine coordinates and mean AOD into one DataFrame
      meanAOD <- cbind(AOD_df[, c(1, 2)], meanAOD)
  
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Create raster from data frame using crs=sinu (the original projection for MCD19A2 V612) 
      
      rast_meanAOD <- terra::rast(meanAOD, type = "xyz", crs = proj_sinu, digits = 6, extent = NULL)
      
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Project raster to crs = longlat (the commonly used)

      proj_mean <- terra::project(rast_meanAOD, proj_longlat)
      
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Mask raster (longlat) with ROI (longlat) to ensure values outside the ROI are set to NA
    
      mask_mean <- terra::mask(proj_mean, StudyRegion)
 
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Save Raster as tif in a specific Output folder 
      
      print(paste0("Saving raster: ", i, "/", length(tile$files)))
      
      # Define the output file path for saving the raster as a TIFF file
      output_file <- file.path(output_directory, paste0("meanAOD_", i, ".tif"))
      
      # Save the raster as a TIFF file
      terra::writeRaster(mask_mean, output_file, overwrite = TRUE)
    }
    
  } else {
    print(paste0("No valid tiles for file N°: ", i))
  }
}



