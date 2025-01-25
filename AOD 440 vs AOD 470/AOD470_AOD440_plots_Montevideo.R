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

plots_path <- "C:/Users/Fer/OneDrive/FERNANDA/DOCTORADO/TRABAJOS/Prueba_DSCOVR_EPIC_MAIAC/PLOTS/AOD470_AOD440_25km/"


filtered_result <- read.csv(paste0(csv_path, "AOD440_AOD470_25km_Montevideo.csv"), sep = ",")


#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Plot data  ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#------------------------------------------------------------------------------
# Adjust data for plots in general

# Line 1:1 (assuming AOD values linear fit is perfect between AOD440 and AOD470)
x <- seq(0, 2.5, length.out = 10000)
y <- x  # This represents the 1:1 line

# MAIAC AOD470 Expected Error (es lo mismo x e y para este calculo por que valen lo mismo)
upper_bound <- y+(0.05 + 0.05*y)
lower_bound <- y-(0.05 + 0.05*y)

# Create a data frame for plotting the ideal results
ideal <- data.frame(x = x, y = y, upper_bound = upper_bound, lower_bound = lower_bound)


# Check if AOD_470 (MAIAC) falls within these MAIAC-based EE bounds
closest_index <- findInterval(filtered_result$AOD_470, ideal$y) # valor de y mas cercano al ideal de la recta
filtered_result$lower_bound <- ideal$lower_bound[closest_index] #x min del error esperado (df ideal)
filtered_result$upper_bound <- ideal$upper_bound[closest_index]  #x max del error esperado (df ideal)

# Check if AOD_440 (x real) is within the bounds (ideal x min x max)
filtered_result$within_EE <- (filtered_result$AOD_440 >= filtered_result$lower_bound) &
  (filtered_result$AOD_440 <= filtered_result$upper_bound)


#------------------------------------------------------------------------------
# PLOT -- All data ------------------------------------------------------------

# Calculate statistics
N <- nrow(filtered_result)
RMSE <- sqrt(mean((filtered_result$AOD_470 - filtered_result$AOD_440)^2))
bias <- mean(filtered_result$AOD_470 - filtered_result$AOD_440)
within_EE <- mean(filtered_result$within_EE) * 100  # Percentage of points within EE
R <- cor(filtered_result$AOD_470, filtered_result$AOD_440)  # Correlation coefficient

# Add text annotation with R, RMSE, bias, within EE, and N
stats_text <- sprintf("R = %.3f\nRMSE = %.3f\nBias = %.3f\nWithin EE = %.2f%%\nN = %d", R, RMSE, bias, within_EE, N)

# Create the plot
Plot_AllData <- ggplot(ideal, aes(x = x, y = y)) +
  geom_ribbon(aes(ymin = lower_bound, ymax = upper_bound), 
              fill = "gray", alpha = 0.3) +  # Shaded area between bounds
  geom_point(data = filtered_result, aes(x = AOD_440, y = AOD_470), 
             color = "blue", shape = 20) +  # Scatter plot of filtered_result
  geom_line(color = "black", linewidth = 1) +  # Scatter plot of 1:1 line points
  # Escala de valores de latitud-longitud
  scale_x_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5))+
  scale_y_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5))+
  coord_cartesian(
    xlim =  c(0, 2),
    ylim =  c(0, 2))+
  labs(
    x = "AOD 440 (AERONET - Montevideo)",
    y = "AOD 470 (MAIAC/MODIS)"
  ) +
  theme_bw() +
  annotate("text", x = 0.0, y = 1.75, label = stats_text,
           size = 5, color = "black", fontface = "bold",  hjust = 0, family = "Times New Roman")  # Adjust x, y for position

Plot_AllData <- Plot_AllData + 
  theme(
    axis.text.x = element_text(size = 30, family = "Times New Roman"),
    axis.text.y = element_text(size = 30, family = "Times New Roman"),
    axis.title.x = element_text(size = 30, family = "Times New Roman"),
    axis.title.y = element_text(size = 30, family = "Times New Roman"),
    legend.title = element_text(size = 30, family = "Times New Roman"),
    legend.text = element_text(size = 30, family = "Times New Roman")  # Optionally adjust legend text size
  )

ggsave(Plot_AllData,
       path = plots_path, 
       filename = "AOD470_AOD440-MONTEVIDEO_total.png", 
       width = 600, height = 600, units = "px", dpi=96)

#------------------------------------------------------------------------------
# PLOT -- by Satellite  -------------------------------------------------------

# Define custom labels for facets
satellite_labels <- c(T = "TERRA", A = "AQUA")

stats_summary <- filtered_result %>%
  group_by(satellite) %>%
  summarise(
    N = n(),
    RMSE = sqrt(mean((AOD_470 - AOD_440)^2)),
    bias = mean(AOD_470 - AOD_440),
    within_EE = mean(within_EE) * 100,  # Percentage of points within EE
    R = cor(AOD_470, AOD_440)  # Correlation coefficient
  )

# Create the plot
Plot_bySat <- ggplot(ideal, aes(x = x, y = y)) +
  geom_ribbon(aes(ymin = lower_bound, ymax = upper_bound), 
              fill = "gray", alpha = 0.3) +  # Shaded area between bounds
  geom_point(data = filtered_result, aes(x = AOD_440, y = AOD_470),
             color = "blue", shape = 20) +  # Scatter plot of filtered_result
  geom_line(data = ideal, aes(x = x, y = y), color = "black", linewidth = 1) +  # 1:1 line points
  labs(
    x = "AOD 440 (AERONET - MONTEVIDEO)",
    y = "AOD 470 (MAIAC/MODIS)"
  ) +
  scale_x_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5))+
  scale_y_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5))+
  coord_cartesian(
    xlim =  c(0, 2),
    ylim =  c(0, 2))+
  theme_bw() +
  facet_wrap(~ satellite, ncol = 2, labeller = labeller(satellite = satellite_labels)) +  # Create separate plots for each satellhttp://127.0.0.1:40719/graphics/80bf4b5a-c430-4b60-b986-468e3a9e6c77.pngite type
  geom_label(data = stats_summary, 
             aes(x = 0.0, y = 1.55, 
                 label = sprintf("N = %d\nR = %.3f\nRMSE = %.3f\nBias = %.3f\nWithin EE = %.2f%%", 
                                 N, R, RMSE, bias, within_EE)),
             size = 7, 
             color = "black", 
             fontface = "italic", 
             hjust = 0, 
             family = "Times New Roman", 
             label.size = 0.5, # Width of the contour line
             fill = "white",   # Background color
             label.r = unit(0.15, "lines")) # Rounded corners for the label box

Plot_bySat <- Plot_bySat + 
  theme(
    axis.text = element_text(size = 28, family = "Times New Roman"),
    axis.title.x = element_text(size = 28, family = "Times New Roman", 
                                margin = margin(t = 10)), # Increase space above x-axis title
    axis.title.y = element_text(size = 28, family = "Times New Roman", 
                                margin = margin(r = 10)), 
    strip.text = element_text(size = 28, family = "Times New Roman"),
    strip.background = element_rect(colour="black"),
    panel.spacing = unit(2, "lines") )# Optionally adjust legend text size

ggsave(Plot_bySat,
       path = plots_path, 
       filename = "AOD470_AOD440-MONTEVIDEO_satellite.png", 
       width = 1400, height = 600, units = "px", dpi=96)


#------------------------------------------------------------------------------
# PLOT -- by Year  ------------------------------------------------------------

filtered_result_no2017 <- filtered_result %>%
  filter(!(Year %in% c(2017, 2018, 2019)))

# Calculate statistics for each Satellite-Year combination
stats_summary <- filtered_result_no2017 %>%
  group_by(Year) %>%
  summarise(
    N = n(),
    RMSE = sqrt(mean((AOD_470 - AOD_440)^2)),
    bias = mean(AOD_470 - AOD_440),
    within_EE = mean(within_EE) * 100,  # Percentage of points within EE
    R = cor(AOD_470, AOD_440)  # Correlation coefficient
  ) %>%
  mutate(facet_label = Year)

# Create the plot with faceting by Satellite and Year
Plot_byYear <- ggplot(ideal, aes(x = x, y = y)) +
  geom_ribbon(aes(ymin = lower_bound, ymax = upper_bound), 
              fill = "gray", alpha = 0.3) +  # Shaded area between bounds
  geom_point(data = filtered_result_no2017, aes(x = AOD_440, y = AOD_470),
             color = "blue", shape = 20) +  # Scatter plot of filtered_result
  geom_line(data = ideal, aes(x = x, y = y), color = "black", linewidth = 1) +  # 1:1 line points
  scale_x_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5))+
  scale_y_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5))+
  coord_cartesian(
    xlim =  c(0, 2),
    ylim =  c(0, 2))+
  labs(
    x = "AOD 440 (AERONET)\nMontevideo",
    y = "AOD 470 (MAIAC/MODIS)"
  ) +
  theme_bw() +
  facet_wrap(~ facet_label, ncol = 1) +  # Facet by combined Satellite-Year label
  geom_label(data = stats_summary, 
             aes(x = 0.0, y = 1.55, 
                 label = sprintf("N = %d\nR = %.3f\nRMSE = %.3f\nBias = %.3f\nWithin EE = %.2f%%", 
                                 N, R, RMSE, bias, within_EE)),
             size = 7, 
             color = "black", 
             fontface = "italic", 
             hjust = 0, 
             family = "Times New Roman", 
             label.size = 0.5, # Width of the contour line
             fill = "white",   # Background color
             label.r = unit(0.15, "lines")) # Rounded corners for the label box

Plot_byYear <- Plot_byYear + 
  theme(
    axis.text = element_text(size = 28, family = "Times New Roman"),
    axis.title.x = element_text(size = 28, family = "Times New Roman", 
                                margin = margin(t = 10)), # Increase space above x-axis title
    axis.title.y = element_text(size = 28, family = "Times New Roman", 
                                margin = margin(r = 10)), 
    strip.text = element_text(size = 28, family = "Times New Roman"),
    strip.background = element_rect(colour="black"),
    panel.spacing = unit(2, "lines") )# Optionally adjust legend text size

ggsave(Plot_byYear,
       path = plots_path, 
       filename = "AOD470_AOD440-Montevideo_year.png", 
       width = 700, height = 1800, units = "px", dpi=96)

#------------------------------------------------------------------------------
# PLOT -- by Satellite + Year  ------------------------------------------------

# Create a combined label for Satellite and Year in the data frame
filtered_result <- filtered_result %>%
  mutate(facet_label = paste(Year, "-", "Satellite", satellite))

filtered_result_no2017 <- filtered_result %>%
  filter(Year != 2017)

# Calculate statistics for each Satellite-Year combination
stats_summary <- filtered_result_no2017 %>%
  group_by(satellite, Year) %>%
  summarise(
    N = n(),
    RMSE = sqrt(mean((AOD_470 - AOD_440)^2)),
    bias = mean(AOD_470 - AOD_440),
    within_EE = mean(within_EE) * 100,  # Percentage of points within EE
    R = cor(AOD_470, AOD_440)  # Correlation coefficient
  ) %>%
  mutate(facet_label = paste(Year, "-", "Satellite", satellite))

# Create the plot with faceting by Satellite and Year
ggplot(ideal, aes(x = x, y = y)) +
  geom_ribbon(aes(ymin = lower_bound, ymax = upper_bound), 
              fill = "gray", alpha = 0.3) +  # Shaded area between bounds
  geom_point(data = filtered_result_no2017, aes(x = AOD_440, y = AOD_470),
             color = "blue", shape = 20) +  # Scatter plot of filtered_result
  geom_line(data = ideal, aes(x = x, y = y), color = "black", linewidth = 1) +  # 1:1 line points
  labs(
    x = "AOD 440 (AERONET- MONTEVIDEO)",
    y = "AOD 470 (MAIAC)"
  ) +
  theme_minimal() +
  facet_wrap(~ facet_label, ncol = 2) +  # Facet by combined Satellite-Year label
  geom_text(data = stats_summary, 
            aes(x = 0.0, y = 1.50, 
            label = sprintf("R = %.3f\nRMSE = %.3f\nBias = %.3f\nWithin EE = %.2f%%\nN = %d", R, RMSE, bias, within_EE, N)),
            size = 2.5, 
            color = "black", 
            fontface = "bold", 
            hjust = 0)  # Text annotation


#------------------------------------------------------------------------------
# PLOT -- by Satellite + Season  ----------------------------------------------

filtered_result <- filtered_result %>%
  mutate(Season = case_when(
    Julian_Date >= 335 | Julian_Date <= 59 ~ "Summer (DEF)",   # December (335-365), January (1-31), February (32-59)
    Julian_Date >= 60 & Julian_Date <= 151 ~ "Autumn (MAM)",   # March (60-90), April (91-120), May (121-151)
    Julian_Date >= 152 & Julian_Date <= 243 ~ "Winter (JJA)",  # June (152-181), July (182-212), August (213-243)
    Julian_Date >= 244 & Julian_Date <= 334 ~ "Spring (SON)"   # September (244-273), October (274-304), November (305-334)
  ))

# Create a combined label for Satellite and Year in the data frame
filtered_result <- filtered_result %>%
  mutate(facet_label = paste(Season, "-", "Satellite", satellite))


# Calculate statistics for each Satellite-Year combination
stats_summary <- filtered_result %>%
  group_by(satellite, Season) %>%
  summarise(
    N = n(),
    RMSE = sqrt(mean((AOD_470 - AOD_440)^2)),
    bias = mean(AOD_470 - AOD_440),
    within_EE = mean(within_EE) * 100,  # Percentage of points within EE
    R = cor(AOD_470, AOD_440)  # Correlation coefficient
  ) %>%
  mutate(facet_label = paste(Season, "-", "Satellite", satellite))

# Create the plot with faceting by Satellite and Year
ggplot(ideal, aes(x = x, y = y)) +
  geom_ribbon(aes(ymin = lower_bound, ymax = upper_bound), 
              fill = "gray", alpha = 0.3) +  # Shaded area between bounds
  geom_point(data = filtered_result, aes(x = AOD_440, y = AOD_470),
             color = "blue", shape = 20) +  # Scatter plot of filtered_result
  geom_line(data = ideal, aes(x = x, y = y), color = "black", linewidth = 1) +  # 1:1 line points
  labs(
    x = "AOD 440 (AERONET- MONTEVIDEO)",
    y = "AOD 470 (MAIAC)"
  ) +
  theme_minimal() +
  facet_wrap(~ facet_label, ncol = 2) +  # Facet by combined Satellite-Year label
  geom_text(data = stats_summary, 
            aes(x = 0.0, y = 1.50, 
                label = sprintf("R = %.3f\nRMSE = %.3f\nBias = %.3f\nWithin EE = %.2f%%\nN = %d", R, RMSE, bias, within_EE, N)),
            size = 2.5, 
            color = "black", 
            fontface = "bold", 
            hjust = 0)  # Text annotation

