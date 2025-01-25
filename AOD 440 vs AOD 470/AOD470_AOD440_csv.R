#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Libraries ····································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Load necessary library
library(dplyr)
library(ggplot2)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Paths (the only thing to modify) ·············································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

csv_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/OUTPUT_CSV/"

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Imput CSV Data ·······························································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

AOD440 <- read.csv(paste0(csv_path, "AERONET_MONTEVIDEO_AOD440.csv"), sep = ",")

AOD470 <- read.csv(paste0(csv_path, "MAIAC_MODIS_25km_MONTEVIDEO.csv"), sep = ",")

# Rearrange hour and minute from AOD 470 so that in appear all together in a column
AOD470$time <- sprintf("%02d:%02d", AOD470$hour, AOD470$minute)

# Drop the original 'hour' and 'minute' columns if they're no longer needed
AOD470 <- AOD470[, !names(AOD470) %in% c("hour", "minute")]

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Join data with a temporal window of +/- 60 min from satellite overpass········
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# If AOD 440 has negative values transform them to NA
AOD440$AOD_440nm[AOD440$AOD_440nm < 0] <- NA

# Convert time columns to POSIXct datetime format for easy time calculations
AOD440$Time <- as.POSIXct(paste(AOD440$year, AOD440$Day_of_Year, AOD440$Time.hh.mm.ss.), format="%Y %j %H:%M:%S", tz="UTC")
AOD470$Time <- as.POSIXct(paste(AOD470$Year, AOD470$Julian_Date, AOD470$time), format="%Y %j %H:%M", tz="UTC")

# Initialize the new data frame by selecting necessary columns from AOD470
result <- AOD470 %>%
  mutate(AOD_440 = NA)  # Add a new column for AOD_440 with NA values

# Iterate over each row in AOD470 to calculate the average AOD_440nm within +/- 60 minutes
for (i in 1:nrow(result)) {
  # Get the reference time, year, and day of year for the current row
  ref_time <- result$Time[i]
  ref_year <- result$Year[i]
  ref_day <- result$Julian_Date[i]
  
  # Filter AOD440 for matching year, day of year, and within +/- 60 minutes of the reference time
  subset_AOD440 <- AOD440 %>%
    filter(year == ref_year,
           Day_of_Year == ref_day,
           abs(difftime(Time, ref_time, units = "mins")) <= 60)
  
  # Calculate the mean of AOD_440nm for the filtered rows and store it in the result data frame
  result$AOD_440[i] <- mean(subset_AOD440$AOD_440nm, na.rm = TRUE)
}

# Drop the 'Time' columns if not needed in the final result
result <- result %>%
  select(Year, Julian_Date, satellite, AOD_25km, AOD_440)

colnames(result)[4] <- "AOD_470"

# Filter out rows with NaN values in AOD_440
filtered_result <- na.omit(result)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Save data filtered without NA values ·········································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

write.table(filtered_result, paste0(csv_path, "AOD440_AOD470_25km_Montevideo.csv") , sep = ",", row.names = FALSE)

