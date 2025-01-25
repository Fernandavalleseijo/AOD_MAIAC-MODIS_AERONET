#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Libraries  ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Load necessary libraries
library(sf)
library(terra)
library(purrr)

library(ggplot2)
library(ggspatial)
library(scales) # oob=squish()

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Annual .tif files as raster
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


# Define the path where your .tif files are located
annual_tif_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/OUTPUT_MAIAC_Annual_tif"

# Get a list of .tif files in the folder divided per mean or st. dev,
annual_mean <- list.files(path = annual_tif_path, pattern = "meanAOD", full.names = TRUE)
annual_sd <- list.files(path = annual_tif_path, pattern = "sdAOD", full.names = TRUE)

# Read all the .tif files as rasters
annual_mean_rast <- lapply(annual_mean, rast)
annual_sd_rast <- lapply(annual_sd, rast)


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# PLOT | ANNUAL MEAN AOD 
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Raster data to data frame to use it in ggplot
annual_mean_df <- lapply(annual_mean_rast, as.data.frame, xy = TRUE)

# Vector data
kml_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/KML/"

LimiteInt <- read_sf(paste(kml_path,'Limite_Internacional.kml', sep = ""))
LimiteProv <- read_sf(paste(kml_path,'LimiteProvincial.kml', sep = ""))

# Bar colours
colfunc <-colorRampPalette(c("darkblue", "blue", "cyan", "green", "yellow", "red", "darkred"))

plots_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/PLOTS/MAIAC_MODIS_Annual"

years <- c(2018,2019, 2020, 2021, 2022)

Plots_anuales = list()

for(i in 1:length(annual_mean_df)) {
  
  print(paste0("Ploting year: ", years[i]))
  
  Plots_anuales[[i]] <- ggplot() +  # Start with an empty ggplot object
    geom_raster(data = annual_mean_df[[i]], aes(x = x, y = y, fill = mean)) +
    geom_sf(data = LimiteInt, color = "black", fill = NA, size = 1) +
    geom_sf(data = LimiteProv, color = "black", fill = NA, size = 1) +
    
    coord_sf(xlim = c(-63.3871, -52.97391), 
             ylim = c(-36.04412, -21.71957), 
             expand = FALSE) +  # Set ext
    
    # Escala de valores de latitud-longitud
    scale_x_continuous(breaks = c(-60, -55), labels=c('60ºW','55ºW'))+
    scale_y_continuous(breaks = c(-34, -30, -26, -22), labels=c('34ºS','30ºS', '26ºS', '22ºS'))+
    
    # Escala de valores del mapa y sus colores
    scale_fill_gradientn(colours = colfunc(7),
                         limits = c(0.0, 0.5), 
                         breaks = c(0.0, 0.1, 0.2, 0.3, 0.4, 0.5), #chequear con valores maximos y minimos
                         oob=squish, 
                         guide=guide_colorbar(title="Mean AOD 0.47 (MAIAC-MODIS)",
                                              title.position = "right",  # Position the title at the top of the color bar
                                              title.hjust = 0.5,  # Center the title horizontally
                                              title.theme = element_text(angle = 90, vjust = 1),  # Rotate the title vertically
                                              nbin=100, 
                                              barheight=unit(0.80, "npc")))+
    labs(
      x = "Longitude",
      y = "Latitude")   # Changed fill label to "Mean AOD"
  
  
  # Se agrega la flecha del norte y la barra de escala 
  Plots_anuales[[i]] <- Plots_anuales[[i]] +
    ggspatial::annotation_scale(location = "bl", bar_cols = c("black", "white")) +
    ggspatial::annotation_north_arrow(location = "tr", 
                                      which_north = "true", 
                                      pad_x = unit(0.1, "cm"), pad_y = unit(0.3, "cm"),
                                      style = north_arrow_fancy_orienteering)
  # Se arreglan los tamaños de letras
  Plots_anuales[[i]] <- Plots_anuales[[i]] + 
    theme(
      axis.text.x = element_text(size = 30, family = "Times New Roman"),
      axis.text.y = element_text(size = 30, family = "Times New Roman", angle = 90, hjust = 0.5, vjust = 0.5),
      axis.title.x = element_text(size = 30, family = "Times New Roman"),
      axis.title.y = element_text(size = 30, family = "Times New Roman"),
      legend.title = element_text(size = 30, family = "Times New Roman"),
      legend.text = element_text(size = 30, family = "Times New Roman")  # Optionally adjust legend text size
    )
  
  ggsave(Plots_anuales[[i]],
         path = plots_path, 
         filename = paste0("AOD_mean_",years[i],".png"), 
         width = 1073, height = 700, units = "px", dpi=96)
  
}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# PLOT | ANNUAL ST. DEV. AOD 
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Raster data
annual_sd_df <- lapply(annual_sd_rast, as.data.frame, xy = TRUE)

# Vector data
kml_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/"

LimiteInt <- read_sf(paste(kml_path,'Limite_Internacional.kml', sep = ""))
LimiteProv <- read_sf(paste(kml_path,'LimiteProvincial.kml', sep = ""))

# Bar colours
colfunc <-colorRampPalette(c("darkblue", "blue", "cyan", "green", "yellow", "red", "darkred"))

plots_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/PLOTS/MAIAC_MODIS_Annual"

Plots_anuales = list()

for(i in 1:length(annual_sd_df)) {
  
  print(paste0("Ploting year: ", years[i]))
  
  Plots_anuales[[i]] <- ggplot() +  # Start with an empty ggplot object
    geom_raster(data = annual_sd_df[[i]], aes(x = x, y = y, fill = std)) +
    geom_sf(data = LimiteInt, color = "black", fill = NA, size = 1) +
    geom_sf(data = LimiteProv, color = "black", fill = NA, size = 1) +
    
    coord_sf(xlim = c(-63.3871, -52.97391), 
             ylim = c(-36.04412, -21.71957), 
             expand = FALSE) +  # Set ext
    
    # Escala de valores de latitud-longitud
    scale_x_continuous(breaks = c(-60, -55), labels=c('60ºW','55ºW'))+
    scale_y_continuous(breaks = c(-34, -30, -26, -22), labels=c('34ºS','30ºS', '26ºS', '22ºS'))+
    
    # Escala de valores del mapa y sus colores
    scale_fill_gradientn(colours = colfunc(7),
                         limits = c(0.0, 0.5), 
                         breaks = c(0.0, 0.1, 0.2, 0.3, 0.4, 0.5), #chequear con valores maximos y minimos
                         oob=squish, 
                         guide=guide_colorbar(title="Mean AOD 0.47 (MAIAC-MODIS)",
                                              title.position = "right",  # Position the title at the top of the color bar
                                              title.hjust = 0.5,  # Center the title horizontally
                                              title.theme = element_text(angle = 90, vjust = 1),  # Rotate the title vertically
                                              nbin=100, 
                                              barheight=unit(0.80, "npc")))+
    labs(
      x = "Longitude",
      y = "Latitude")   # Changed fill label to "Mean AOD"
  
  
  # Se agrega la flecha del norte y la barra de escala 
  Plots_anuales[[i]] <- Plots_anuales[[i]] +
    ggspatial::annotation_scale(location = "bl", bar_cols = c("black", "white")) +
    ggspatial::annotation_north_arrow(location = "tr", 
                                      which_north = "true", 
                                      pad_x = unit(0.1, "cm"), pad_y = unit(0.3, "cm"),
                                      style = north_arrow_fancy_orienteering)
  # Se arreglan los tamaños de letras
  Plots_anuales[[i]] <- Plots_anuales[[i]] + 
    theme(
      axis.text.x = element_text(size = 30, family = "Times New Roman"),
      axis.text.y = element_text(size = 30, family = "Times New Roman", angle = 90, hjust = 0.5, vjust = 0.5),
      axis.title.x = element_text(size = 30, family = "Times New Roman"),
      axis.title.y = element_text(size = 30, family = "Times New Roman"),
      legend.title = element_text(size = 30, family = "Times New Roman"),
      legend.text = element_text(size = 30, family = "Times New Roman")  # Optionally adjust legend text size
    )
  
  ggsave(Plots_anuales[[i]],
         path = plots_path, 
         filename = paste0("AOD_sd_",years[i],".png"), 
         width = 1073, height = 700, units = "px", dpi=96)
  
}


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# PLOT | COMBINED BOXPLOT FOR ALL YEARS
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Combine the data frames into one, adding a 'year' column
combined_df <- do.call(rbind, lapply(1:length(annual_mean_df), function(i) {
  df <- annual_mean_df[[i]]
  df$year <- years[i]  # Add a column for year
  return(df)
}))


Annual_boxplot <- ggplot(combined_df, aes(x = factor(year), y = mean)) +  # Convert 'year' to a factor
  geom_boxplot(outliers = FALSE,
               fill = "lightblue") +
  labs(x = "Year", y = "Mean Annual AOD") 

ggsave(Annual_boxplot,
       path = plots_path, 
       filename = paste0("Annual_boxplot",".png"), 
       width = 763, height = 312, units = "px", dpi=96)

#------------------------------------------------------------------------------
# Boxplot Statistics
#------------------------------------------------------------------------------

# Build the ggplot object to extract data
plot_build <- ggplot_build(Annual_boxplot)

# Extract the statistics of the boxplot
boxplot_stats <- plot_build$data[[1]]  # Boxplot data is typically in the first layer

# View the extracted statistics
print(boxplot_stats)
