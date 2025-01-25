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
# seasonal .tif files as raster
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Define the path where your .tif files are located
seasonal_tif_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/OUTPUT_MAIAC_seasonal_tif"

# Get a list of .tif files in the folder divided per mean or st. dev,
seasonal_mean <- list.files(path = seasonal_tif_path, pattern = "meanAOD", full.names = TRUE)
seasonal_sd <- list.files(path = seasonal_tif_path, pattern = "sdAOD", full.names = TRUE)

# Read all the .tif files as rasters
seasonal_mean_rast <- lapply(seasonal_mean, rast)
seasonal_sd_rast <- lapply(seasonal_sd, rast)


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# PLOT | seasonal MEAN AOD 
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Raster data to data frame to use it in ggplot
seasonal_mean_df <- lapply(seasonal_mean_rast, as.data.frame, xy = TRUE)

# Vector data
kml_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/KML/"

LimiteInt <- read_sf(paste(kml_path,'Limite_Internacional.kml', sep = ""))
LimiteProv <- read_sf(paste(kml_path,'LimiteProvincial.kml', sep = ""))

# Bar colours
colfunc <-colorRampPalette(c("darkblue", "blue", "cyan", "green", "yellow", "red", "darkred"))

plots_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/PLOTS/MAIAC_MODIS_seasonal"

seasonal_labels <- gsub(".*meanAOD_(\\d+_\\w+).tif", "\\1", seasonal_mean)

Plots_seasonal = list()

for(i in 1:length(seasonal_mean_df)) {
  
  print(paste0("Ploting: ", seasonal_labels[i]))
  
  Plots_seasonal[[i]] <- ggplot() +  # Start with an empty ggplot object
    geom_raster(data = seasonal_mean_df[[i]], aes(x = x, y = y, fill = mean)) +
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
  Plots_seasonal[[i]] <- Plots_seasonal[[i]] +
    ggspatial::annotation_scale(location = "bl", bar_cols = c("black", "white")) +
    ggspatial::annotation_north_arrow(location = "tr", 
                                      which_north = "true", 
                                      pad_x = unit(0.1, "cm"), pad_y = unit(0.3, "cm"),
                                      style = north_arrow_fancy_orienteering)
  # Se arreglan los tamaños de letras
  Plots_seasonal[[i]] <- Plots_seasonal[[i]] + 
    theme(
      axis.text.x = element_text(size = 30, family = "Times New Roman"),
      axis.text.y = element_text(size = 30, family = "Times New Roman", angle = 90, hjust = 0.5, vjust = 0.5),
      axis.title.x = element_text(size = 30, family = "Times New Roman"),
      axis.title.y = element_text(size = 30, family = "Times New Roman"),
      legend.title = element_text(size = 30, family = "Times New Roman"),
      legend.text = element_text(size = 30, family = "Times New Roman")  # Optionally adjust legend text size
    )
  
  ggsave(Plots_seasonal[[i]],
         path = plots_path, 
         filename = paste0("AOD_mean_",seasonal_labels[i],".png"), 
         width = 1073, height = 683, units = "px", dpi=96)
  
}

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# PLOT | seasonal ST. DEV. AOD 
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Raster data
seasonal_sd_df <- lapply(seasonal_sd_rast, as.data.frame, xy = TRUE)

# Vector data
kml_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/KML/"

LimiteInt <- read_sf(paste(kml_path,'Limite_Internacional.kml', sep = ""))
LimiteProv <- read_sf(paste(kml_path,'LimiteProvincial.kml', sep = ""))

# Bar colours
colfunc <-colorRampPalette(c("darkblue", "blue", "cyan", "green", "yellow", "red", "darkred"))

plots_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/PLOTS/MAIAC_MODIS_seasonal"

Plots_seasonal = list()

for(i in 1:length(seasonal_sd_df)) {
  
  print(paste0("Ploting: ", seasonal_labels[i]))
  
  Plots_seasonal[[i]] <- ggplot() +  # Start with an empty ggplot object
    geom_raster(data = seasonal_sd_df[[i]], aes(x = x, y = y, fill = std)) +
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
  Plots_seasonal[[i]] <- Plots_seasonal[[i]] +
    ggspatial::annotation_scale(location = "bl", bar_cols = c("black", "white")) +
    ggspatial::annotation_north_arrow(location = "tr", 
                                      which_north = "true", 
                                      pad_x = unit(0.1, "cm"), pad_y = unit(0.3, "cm"),
                                      style = north_arrow_fancy_orienteering)
  # Se arreglan los tamaños de letras
  Plots_seasonal[[i]] <- Plots_seasonal[[i]] + 
    theme(
      axis.text.x = element_text(size = 30, family = "Times New Roman"),
      axis.text.y = element_text(size = 30, family = "Times New Roman", angle = 90, hjust = 0.5, vjust = 0.5),
      axis.title.x = element_text(size = 30, family = "Times New Roman"),
      axis.title.y = element_text(size = 30, family = "Times New Roman"),
      legend.title = element_text(size = 30, family = "Times New Roman"),
      legend.text = element_text(size = 30, family = "Times New Roman")  # Optionally adjust legend text size
    )
  
  ggsave(Plots_seasonal[[i]],
         path = plots_path, 
         filename = paste0("AOD_sd_",seasonal_labels[i],".png"), 
         width = 1073, height = 683, units = "px", dpi=96)
  
}


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# PLOT | COMBINED BOXPLOT FOR ALL YEARS
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

combined_df <- do.call(rbind, lapply(1:length(seasonal_mean_df), function(i) {
  df <- seasonal_mean_df[[i]]
  
  # Extract the year and season from the corresponding file name in 'seasonal_mean'
  season_info <- gsub(".*meanAOD_(\\d+)_(\\w+).tif", "\\2", seasonal_mean[i])
  df$year <- gsub(".*meanAOD_(\\d+)_\\w+.tif", "\\1", seasonal_mean[i])  # Add year column
  df$season <- season_info  # Add season column
  
  return(df)
}))


# Create the boxplot
seasonal_boxplot <- ggplot(combined_df, aes(x = factor(year), y = mean, fill = season)) +  # Convert 'year' to a factor
  geom_boxplot(outliers = FALSE) +
  facet_wrap(~ season, scales = "free_x") +  # Create a facet for each season
  labs(x = "Year", y = "Mean Seasonal AOD") +
  scale_fill_brewer(palette = "Set3")      # Optional: choose a color palette

# Save the plot
ggsave(seasonal_boxplot,
       path = plots_path, 
       filename = paste0("seasonal_boxplot_by_season",".png"), 
       width = 763, height = 312, units = "px", dpi = 96)


#------------------------------------------------------------------------------
# Boxplot Statistics
#------------------------------------------------------------------------------

# Build the ggplot object to extract data
plot_build <- ggplot_build(seasonal_boxplot)

# Extract the statistics of the boxplot
boxplot_stats <- plot_build$data[[1]]  # Boxplot data is typically in the first layer

# View the extracted statistics
print(boxplot_stats)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# PLOT | COMBINED BOXPLOT FOR ALL YEARS - OP2 and OP3
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

autumn_df <- combined_df[combined_df$season == "Autumn", ]
summer_df <- combined_df[combined_df$season == "Summer", ]
spring_df <- combined_df[combined_df$season == "Spring", ]
winter_df <- combined_df[combined_df$season == "Winter", ]


summer_boxplot <- ggplot(summer_df, aes(x = factor(year), y = mean, fill = season)) +  # Convert 'year' to a factor
  geom_boxplot(outliers = FALSE, fill= "lightblue") +
  annotate("label", x = "2018", y = 0.27, label.padding = unit(0.35, "lines"), 
           label = expression(italic("Summer")),
           size = 10,
           color = "black", 
           family = "serif") +
  labs(x = "Year", y = "Mean AOD - Area Averaged")

autumn_boxplot <- ggplot(autumn_df, aes(x = factor(year), y = mean, fill = season)) +  # Convert 'year' to a factor
  geom_boxplot(outliers = FALSE, fill= "lightgreen") +
  annotate("label", x = "2018", y = 0.15, label.padding = unit(0.35, "lines"), 
           label = expression(italic("Autumn")),
           size = 10,
           color = "black", 
           family = "serif") +
  labs(x = "Year", y = "Mean AOD - Area Averaged")

winter_boxplot <- ggplot(winter_df, aes(x = factor(year), y = mean, fill = season)) +  # Convert 'year' to a factor
  geom_boxplot(outliers = FALSE,
               fill= "lightcoral") +
  annotate("label", x = "2018", y = 0.25, label.padding = unit(0.35, "lines"), 
           label = expression(italic("Winter")),
           size = 10,
           color = "black", 
           family = "serif") +
  labs(x = "Year", y = "Mean AOD - Area Averaged")


spring_boxplot <- ggplot(spring_df, aes(x = factor(year), y = mean, fill = season)) +  # Convert 'year' to a factor
  geom_boxplot(outliers = FALSE,
               fill= "lightyellow") +
  annotate("label", x = "2018", y = 0.47, label.padding = unit(0.35, "lines"), 
           label = expression(italic("Spring")),
           size = 10,
           color = "black", 
           family = "serif") +
  labs(x = "Year", y = "Mean AOD - Area Averaged")




library(patchwork) 

graph_season_all <- summer_boxplot / autumn_boxplot / winter_boxplot / spring_boxplot +
  plot_layout(axis_titles = "collect") &
  theme(plot.tag = element_text(size = 25, margin = margin(b = 10)),
        axis.title.x = element_text(size = 25, margin = margin(t = 15)),
        axis.title.y = element_text(size = 25, margin = margin(r = 15)),
        plot.tag.position= "top",
        axis.text.y = element_text(size = 25),
        axis.text.x = element_text(size = 25),
        text  = element_text(family = "serif")) 

ggsave(graph_season_all,path = plots_path, filename = "boxplot_year_season.png", width = 1000, height =  1895, units = "px", dpi=96)



graph_season_all <- summer_boxplot | autumn_boxplot | winter_boxplot | spring_boxplot +
  plot_layout(axis_titles = "collect") &
  theme(plot.tag = element_text(size = 25, margin = margin(b = 10)),
        axis.title.x = element_text(size = 25, margin = margin(t = 15)),
        axis.title.y = element_text(size = 25, margin = margin(r = 15)),
        plot.tag.position= "top",
        axis.text.y = element_text(size = 25),
        axis.text.x = element_text(size = 25),
        text  = element_text(family = "serif")) 

ggsave(graph_season_all,path = plots_path, filename = "boxplot_year_season_3.png", width = 4000, height =  400, units = "px", dpi=96)
