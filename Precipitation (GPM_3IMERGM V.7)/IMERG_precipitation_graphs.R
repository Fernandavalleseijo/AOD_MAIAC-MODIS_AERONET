#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Libraries ····································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Load necessary library
library(dplyr)
library(ggplot2)
library(lubridate)

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Paths (the only thing to modify) ·············································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

met_path <- ""

plot_path <- ""


pp <- read.csv(paste0(met_path, "g4.areaAvgTimeSeries.GPM_3IMERGM_07_precipitation.20171201-20221231.63W_36S_52W_21S.csv"))

# Remove the first 7 rows
pp <- pp[-(1:7), ]

# Rename columns to "month" and "mm/month"
colnames(pp) <- c("month", "mm/month")

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Plot data  ···································································
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Ensure "mm/month" is numeric
pp$`mm/month` <- as.numeric(pp$`mm/month`)

# Adjust year for December to group it with the next year for summer
pp <- pp %>%
  mutate(
    year = year(month),
    month_num = month(month),
    adjusted_year = ifelse(month_num == 12, year + 1, year),
    season = case_when(
      month_num %in% c(12, 1, 2) ~ "Summer",
      month_num %in% c(3, 4, 5) ~ "Autumn",
      month_num %in% c(6, 7, 8) ~ "Winter",
      month_num %in% c(9, 10, 11) ~ "Spring"
    )
  )

# Aggregate data by season and adjusted year
seasonal_data <- pp %>%
  group_by(adjusted_year, season) %>%
  summarise(total_precip = sum(`mm/month`, na.rm = TRUE)) %>%
  rename(year = adjusted_year) # Rename for clearer plotting

seasonal_data <- seasonal_data[-(21:21), ]

# Set season order
seasonal_data$season <- factor(seasonal_data$season, levels = c("Summer", "Autumn", "Winter", "Spring"))

annual_mean <- seasonal_data %>%
  group_by(year) %>%
  summarise(mean_precip = mean(total_precip, na.rm = TRUE))



# Merge the seasonal_data and annual_mean datasets
combined_data <- left_join(seasonal_data, annual_mean, by = "year")


# Plot op. 1

ggplot(combined_data, aes(x = factor(year), y = total_precip, fill = season)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_line(aes(y = mean_precip, color = "Annual Mean"), group = 1, size = 0.75, linetype = "dashed") +
  geom_point(aes(y = mean_precip, color = "Annual Mean"), 
             group = 1, size = 3, show.legend = TRUE) +  # Point will appear in the color legend
  labs(x = "Year", 
       y = "Precipitation (mm)",
       fill = "Season",
       color = "") +
  scale_fill_manual(values = c("Summer" = "gold1", 
                               "Autumn" = "darkorange", 
                               "Winter" = "skyblue2", 
                               "Spring" = "limegreen")) +
  scale_color_manual(values = "darkslategrey") +  # Specify the color for the Annual Mean
  guides(fill = guide_legend(override.aes = list(shape = NA))) +  # Remove shape from fill legend
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  theme(
    axis.text.x = element_text(size = 15, family = "Times New Roman", angle = 45, hjust = 1),
    axis.text.y = element_text(size = 15, family = "Times New Roman"),
    axis.title.x = element_text(size = 18, family = "Times New Roman"),
    axis.title.y = element_text(size = 18, family = "Times New Roman"),
    legend.title = element_text(size = 18, family = "Times New Roman"),
    legend.text = element_text(size = 15, family = "Times New Roman")  # Optionally adjust legend text size
  )



# Plot op. 2

ggplot(combined_data, aes(x = factor(year), y = total_precip, fill = season)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_line(aes(y = mean_precip, color = "Annual Mean"), group = 1, size = 0.75, linetype = "dashed") +
  geom_point(aes(y = mean_precip, color = "Annual Mean"), 
             group = 1, size = 3, show.legend = TRUE) +  # Point will appear in the color legend
  labs(x = "Year", 
       y = "Precipitation (mm)",
       fill = "",
       color = "") +
  scale_fill_manual(values = c("Summer" = "gold1", 
                               "Autumn" = "darkorange", 
                               "Winter" = "skyblue2", 
                               "Spring" = "limegreen")) +
  scale_color_manual(values = "darkslategrey") +  # Specify the color for the Annual Mean
  guides(
    fill = guide_legend(override.aes = list(shape = NA), direction = "horizontal", title.position = "top"),  # Horizontal season legend
    color = guide_legend(direction = "horizontal", title.position = "top")  # Horizontal line/point legend
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(size = 18, family = "Times New Roman", angle = 45, hjust = 1),
    axis.text.y = element_text(size = 18, family = "Times New Roman"),
    axis.title.x = element_text(size = 20, family = "Times New Roman"),
    axis.title.y = element_text(size = 20, family = "Times New Roman"),
    legend.text = element_text(size = 18, family = "Times New Roman"),
    legend.position = "top",  # Move legend to the top of the plot
    legend.box = "horizontal",  # Arrange legends horizontally in the same box
    legend.box.margin = margin(t = -10, r = 0, b = 0, l = 0)  # Adjust margin to move legend closer to plot
  )

ggsave(filename = paste0(plot_path, "IMERG_PP_year_season_2.png"), plot = last_plot(), 
       width = 756, height = 512, units = "px", dpi=96)

