#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Libraries ····································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

library(terra)
library(ggplot2)
library(sf)
library(metR)
library(patchwork)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Paths (the only thing to modify) ·············································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

met_path <- ""

kml_path <- ""

plot_path <- ""

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Raster  ······································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

pp_2020_summer <- rast( paste0(met_path, "GIOVANNI-g4.timeAvgMap.GPM_3IMERGM_07_precipitation.20191201-20200229.63W_36S_52W_21S.tif"))

pp_2020_winter <- rast( paste0(met_path, "GIOVANNI-g4.timeAvgMap.GPM_3IMERGM_07_precipitation.20200601-20200831.63W_36S_52W_21S.tif"))

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Vector  ······································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Limits <- vect(paste(kml_path, 'Limites.kml', sep = ""))

Limits <- st_as_sf(Limits)

AreaSinMar <- vect(paste(kml_path, 'Area_sin_mar.kml', sep = ""))


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Mask - Cambiar Raster - con Area sin Mar ·····································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

mask <- terra::mask(pp_2020_summer, AreaSinMar)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Contour levels ·······························································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Define contour levels, e.g., every 10 units
contour_levels <- seq(min(values(mask), na.rm = TRUE),
                      max(values(mask), na.rm = TRUE), by = 50)


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Plots ········································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Convert raster to data frame for ggplot
precip_df <- as.data.frame(mask, xy = TRUE)
names(precip_df)[3] <- "precipitation"

# Set contour levels to match legend values
contour_levels <- c(0, 50, 100, 150, 200, 250, 300)


# Summer 2020 ··································································


Summer_2020 <- ggplot() +
  geom_raster(data = precip_df, aes(x = x, y = y, fill = precipitation)) +
  geom_sf(data = Limits, color = "black", fill = NA, linewidth = 1) +
  
  # Add contours and set breaks to match legend values
  geom_contour(data = precip_df, aes(x = x, y = y, z = precipitation), 
               color = "gray28", 
               linewidth = 1,
               breaks = contour_levels) +
  
  # Label contours with values matching the legend
  geom_text_contour(data = precip_df, aes(x = x, y = y, z = precipitation), 
                    color = "yellow", 
                    breaks = contour_levels, 
                    size = 5, 
                    family = "Times New Roman",  # Set font for contour labels
                    label.placer = label_placer_flattest(),
                    check_overlap = TRUE) + 
  
  # Adjust color scale and legend
  scale_fill_stepsn(
    colors = c("#f0f8ff", "#a6cfe3", "#5a9bd6", "#1c75bc", "#174b85", "#0b2d5e"),
    breaks = contour_levels,  
    limits = c(0, 300),
    guide = guide_colorbar(
      title.position = "top",
      title.hjust = 0.5,
      barwidth = unit(12, "cm"),  # Set to desired width; adjust if needed to match map width
      barheight = unit(0.5, "cm") # Thin the legend bar height
    )
  ) +
  
  coord_sf(xlim = c(-63.3871, -52.97391), 
           ylim = c(-36.04412, -21.71957), 
           expand = FALSE) + 
  
  scale_x_continuous(breaks = c(-60, -55), labels = c('60ºW', '55ºW')) +
  scale_y_continuous(breaks = c(-34, -30, -26, -22), labels = c('34ºS', '30ºS', '26ºS', '22ºS')) +
  
  labs(x = "Longitude",
       y = "Latitude",
       title = "Summer 2020",
       fill = "Precipitation (mm/month)") +
  
  # Center and place legend horizontally at the bottom
  theme(
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.box = "horizontal",
    plot.title = element_text(hjust = 0.5, family = "Times New Roman", size = 18), # Center title text
    plot.title.position = "panel",  # Position title inside plot area
    plot.margin = margin(t = 10, r = 10, b = 40, l = 10)  # Adjust bottom margin for title space
  )

# Further customization of text elements
Summer_2020 <- Summer_2020 +  
  theme(
    axis.text.x = element_text(size = 20, family = "Times New Roman"),
    axis.text.y = element_text(size = 20, family = "Times New Roman", angle = 90, hjust = 0.5, vjust = 0.5),
    axis.title.x = element_text(size = 20, family = "Times New Roman"),
    axis.title.y = element_text(size = 20, family = "Times New Roman"),
    legend.title = element_text(size = 20, family = "Times New Roman"),
    legend.text = element_text(size = 20, family = "Times New Roman")  # Optionally adjust legend text size
  )


ggsave(filename = paste0(plot_path, "PP_2020_Summer_map.png"), plot = Summer_2020, 
       width = 639, height = 652, units = "px", dpi=96)


# Winter 2020 ··································································

Winter_2020 <- ggplot() +
  geom_raster(data = precip_df, aes(x = x, y = y, fill = precipitation)) +
  geom_sf(data = Limits, color = "black", fill = NA, linewidth = 1) +
  
  # Add contours and set breaks to match legend values
  geom_contour(data = precip_df, aes(x = x, y = y, z = precipitation), 
               color = "gray28", 
               linewidth = 1,
               breaks = contour_levels) +
  
  # Label contours with values matching the legend
  geom_text_contour(data = precip_df, aes(x = x, y = y, z = precipitation), 
                    color = "yellow", 
                    breaks = contour_levels, 
                    size = 5, 
                    family = "Times New Roman",  # Set font for contour labels
                    label.placer = label_placer_flattest(),
                    check_overlap = TRUE) + 
  
  # Adjust color scale and legend
  scale_fill_stepsn(
    colors = c("#f0f8ff", "#a6cfe3", "#5a9bd6", "#1c75bc", "#174b85", "#0b2d5e"),
    breaks = contour_levels,  
    limits = c(0, 300),
    guide = guide_colorbar(
      title.position = "top",
      title.hjust = 0.5,
      barwidth = unit(12, "cm"),  # Set to desired width; adjust if needed to match map width
      barheight = unit(0.5, "cm") # Thin the legend bar height
    )
  ) +
  
  coord_sf(xlim = c(-63.3871, -52.97391), 
           ylim = c(-36.04412, -21.71957), 
           expand = FALSE) + 
  
  scale_x_continuous(breaks = c(-60, -55), labels = c('60ºW', '55ºW')) +
  scale_y_continuous(breaks = c(-34, -30, -26, -22), labels = c('34ºS', '30ºS', '26ºS', '22ºS')) +
  
  labs(x = "Longitude",
       y = "Latitude",
       title = "Winter 2020",
       fill = "Precipitation (mm/month)") +
  
  # Center and place legend horizontally at the bottom
  theme(
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.box = "horizontal",
    plot.title = element_text(hjust = 0.5, family = "Times New Roman", size = 18), # Center title text
    plot.title.position = "panel",  # Position title inside plot area
    plot.margin = margin(t = 10, r = 10, b = 40, l = 10)  # Adjust bottom margin for title space
  )

# Further customization of text elements
Winter_2020 <- Winter_2020 +  
  theme(
    axis.text.x = element_text(size = 20, family = "Times New Roman"),
    axis.text.y = element_text(size = 20, family = "Times New Roman", angle = 90, hjust = 0.5, vjust = 0.5),
    axis.title.x = element_text(size = 20, family = "Times New Roman"),
    axis.title.y = element_text(size = 20, family = "Times New Roman"),
    legend.title = element_text(size = 20, family = "Times New Roman"),
    legend.text = element_text(size = 20, family = "Times New Roman")  # Optionally adjust legend text size
  )


ggsave(filename = paste0(plot_path, "PP_2020_Winter_map.png"), plot = Winter_2020, 
       width = 639, height = 652, units = "px", dpi=96)

# Combined PP 2020 ··································································

# Remove the legend from Winter_2020
Winter_2020 <- Winter_2020 + theme(legend.position = "none")

# Combine the plots with a shared legend from Summer_2020
combined_plot <- (Summer_2020 | Winter_2020) + 
  plot_layout(guides = "collect") & 
  theme(legend.position = "bottom")  # Center the collected legend at the bottom


ggsave(filename = paste0(plot_path, "PP_2020_Summer_Winter_combined_map.png"), 
       plot = combined_plot, 
       width = 1280, height = 700, units = "px", dpi=96)
