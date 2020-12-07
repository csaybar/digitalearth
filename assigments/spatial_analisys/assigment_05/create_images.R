library(ggplot2)
states <- read_sf("data/salzburg_population.geojson")
for (index in 1:nrow(states)) {
  name <- states[index,1]$name
  values <- st_drop_geometry(states[index,2:(ncol(states)-3)]) %>% as.numeric()
  dates <- 2000:2019
  dff <- data.frame(name = name, dates = dates, population = values)
  
  pop_plot <- ggplot(dff) +
    geom_line(aes(x = dates, y = population)) +
    geom_point(aes(x = dates, y = population)) +
    geom_smooth(aes(x = dates, y = population), method = "lm", se = FALSE) +
    xlab("") +
    ggtitle(name) +
    theme_classic()
  pop_plot
  gfile<-sprintf("data/fig/ggp_%02d.png", index)
  ggsave(gfile, pop_plot, width = 3,height = 3)
}
