#Librerias·····································································

library(ggplot2)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Archivos ·····································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Path de archivos AERONET  

path_Aeronet <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/AERONET_CELIAP/"

# Define the file paths in a list
file_paths <- c(
  paste(path_Aeronet, '20171201_20171231_CEILAP-BA.lev20', sep = ""),
  paste(path_Aeronet, '20180101_20181231_CEILAP-BA.lev20', sep = ""),
  paste(path_Aeronet, '20190101_20191231_CEILAP-BA.lev20', sep = ""),
  paste(path_Aeronet, '20200101_20201231_CEILAP-BA.lev20', sep = ""),
  paste(path_Aeronet, '20210101_20211231_CEILAP-BA.lev20', sep = ""),
  paste(path_Aeronet, '20220101_20221231_CEILAP-BA.lev20', sep = "")
)

# Initialize an empty list to store the data frames for each year
data_frames <- list()

# Loop through each file path
for (file_path in file_paths) {
  # Read the file as character strings
  Aeronet_AOD <- readLines(file_path)
  
  # Initialize a list to store the rows for the current file
  rows_list <- list()
  
  # Loop through each string in the data starting from [8] to skip headers
  for (i in 8:length(Aeronet_AOD)) {
    # Split the string into individual elements by commas
    split_data <- strsplit(Aeronet_AOD[i], ",")[[1]]
    
    # Convert the list of values into a data frame row
    df_row <- as.data.frame(t(split_data), stringsAsFactors = FALSE)
    
    # Add the row to the list
    rows_list[[i]] <- df_row
  }
  
  # Combine all rows of the current file into a single data frame
  df <- do.call(rbind, rows_list)
  
  # Add the current data frame to the list of data frames
  data_frames[[file_path]] <- df
}

# Combine all data frames from all files into one single data frame
combined_df <- do.call(rbind, data_frames)


column_names <- c("Date(dd:mm:yyyy)", "Time(hh:mm:ss)", "Day_of_Year", "Day_of_Year(Fraction)",
                  "AOD_1640nm", "AOD_1020nm", "AOD_870nm", "AOD_865nm", "AOD_779nm", "AOD_675nm",
                  "AOD_667nm", "AOD_620nm", "AOD_560nm", "AOD_555nm", "AOD_551nm", "AOD_532nm", 
                  "AOD_531nm", "AOD_510nm", "AOD_500nm", "AOD_490nm", "AOD_443nm", "AOD_440nm", 
                  "AOD_412nm", "AOD_400nm", "AOD_380nm", "AOD_340nm", "Precipitable_Water(cm)", 
                  "AOD_681nm", "AOD_709nm", "AOD_Empty", "AOD_Empty", "AOD_Empty", "AOD_Empty", 
                  "AOD_Empty", "Triplet_Variability_1640", "Triplet_Variability_1020", 
                  "Triplet_Variability_870", "Triplet_Variability_865", "Triplet_Variability_779", 
                  "Triplet_Variability_675", "Triplet_Variability_667", "Triplet_Variability_620", 
                  "Triplet_Variability_560", "Triplet_Variability_555", "Triplet_Variability_551", 
                  "Triplet_Variability_532", "Triplet_Variability_531", "Triplet_Variability_510", 
                  "Triplet_Variability_500", "Triplet_Variability_490", "Triplet_Variability_443", 
                  "Triplet_Variability_440", "Triplet_Variability_412", "Triplet_Variability_400", 
                  "Triplet_Variability_380", "Triplet_Variability_340", "Triplet_Variability_Precipitable_Water(cm)", 
                  "Triplet_Variability_681", "Triplet_Variability_709", "Triplet_Variability_AOD_Empty", 
                  "Triplet_Variability_AOD_Empty", "Triplet_Variability_AOD_Empty", "Triplet_Variability_AOD_Empty", 
                  "Triplet_Variability_AOD_Empty", "440-870_Angstrom_Exponent", "380-500_Angstrom_Exponent", 
                  "440-675_Angstrom_Exponent", "500-870_Angstrom_Exponent", "340-440_Angstrom_Exponent", 
                  "440-675_Angstrom_Exponent[Polar]", "Data_Quality_Level", "AERONET_Instrument_Number", 
                  "AERONET_Site_Name", "Site_Latitude(Degrees)", "Site_Longitude(Degrees)", 
                  "Site_Elevation(m)", "Solar_Zenith_Angle(Degrees)", "Optical_Air_Mass", 
                  "Sensor_Temperature(Degrees_C)", "Ozone(Dobson)", "NO2(Dobson)", "Last_Date_Processed", 
                  "Number_of_Wavelengths", "Exact_Wavelengths_of_AOD(um)_1640nm", "Exact_Wavelengths_of_AOD(um)_1020nm", 
                  "Exact_Wavelengths_of_AOD(um)_870nm", "Exact_Wavelengths_of_AOD(um)_865nm", 
                  "Exact_Wavelengths_of_AOD(um)_779nm", "Exact_Wavelengths_of_AOD(um)_675nm", 
                  "Exact_Wavelengths_of_AOD(um)_667nm", "Exact_Wavelengths_of_AOD(um)_620nm", 
                  "Exact_Wavelengths_of_AOD(um)_560nm", "Exact_Wavelengths_of_AOD(um)_555nm", 
                  "Exact_Wavelengths_of_AOD(um)_551nm", "Exact_Wavelengths_of_AOD(um)_532nm", 
                  "Exact_Wavelengths_of_AOD(um)_531nm", "Exact_Wavelengths_of_AOD(um)_510nm", 
                  "Exact_Wavelengths_of_AOD(um)_500nm", "Exact_Wavelengths_of_AOD(um)_490nm", 
                  "Exact_Wavelengths_of_AOD(um)_443nm", "Exact_Wavelengths_of_AOD(um)_440nm", 
                  "Exact_Wavelengths_of_AOD(um)_412nm", "Exact_Wavelengths_of_AOD(um)_400nm", 
                  "Exact_Wavelengths_of_AOD(um)_380nm", "Exact_Wavelengths_of_AOD(um)_340nm", 
                  "Exact_Wavelengths_of_PW(um)_935nm", "Exact_Wavelengths_of_AOD(um)_681nm", 
                  "Exact_Wavelengths_of_AOD(um)_709nm", "Exact_Wavelengths_of_AOD(um)_Empty", 
                  "Exact_Wavelengths_of_AOD(um)_Empty", "Exact_Wavelengths_of_AOD(um)_Empty", 
                  "Exact_Wavelengths_of_AOD(um)_Empty", "Exact_Wavelengths_of_AOD(um)_Empty")


# Assign the column names to the data frame
colnames(combined_df) <- column_names

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# AOD_440 ANNUAL ·······························································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Create a new data frame only for AOD at 440 nm
AOD_440 <- combined_df[, c("Date(dd:mm:yyyy)", "Day_of_Year", "Time(hh:mm:ss)",  "AOD_440nm", "Data_Quality_Level")]

# Check if data quality is always Level 2.0

if (all(AOD_440$Data_Quality_Level == "lev20")) {
  print("Data_Quality_Level is 'lev20' for all rows")
} else {
  print("Data_Quality_Level is not 'lev20' for all rows")
}

# Create a new data frame only for AOD at 440 nm
AOD_440 <- combined_df[, c("Date(dd:mm:yyyy)", "Day_of_Year", "Time(hh:mm:ss)",  "AOD_440nm")]

# Extract day, month and year value of Date(dd:mm:yyyy) column
AOD_440$year <- as.numeric(substr(AOD_440$`Date(dd:mm:yyyy)`, 7, 10))

# Re-arrange AOD_440

AOD_440 <- AOD_440[, c("year", "Day_of_Year", "Time(hh:mm:ss)", "AOD_440nm")]

write.csv(AOD_440, 
          file = "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/OUTPUT_CSV/AERONET_CELIAP_AOD440.csv",
          row.names = FALSE)

