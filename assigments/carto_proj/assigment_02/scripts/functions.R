map_base <- function(states) {
  bins <- c(0, 1000, 1500, 2000, 2500, 3000, Inf)
  pal <- colorBin("YlOrRd", domain = states$density, bins = bins)
  
  labels <- sprintf(
    "<strong>%s</strong><br/>%g people / km<sup>2</sup>",
    states$name, states$density
  ) %>% lapply(htmltools::HTML)
  leaflet(states) %>%
    setView(13.05073, 47.79724, 13) %>% 
    addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Carto basemap") %>%
    addPolygons(
      fillColor = ~pal(density),
      weight = 1,
      opacity = 1,
      color = "black",
      fillOpacity = 0.7,
      highlight = highlightOptions(
        weight = 5,
        color = "white",
        fillOpacity = 0.7,
        bringToFront = TRUE),
      label = labels,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto")) %>%
    addLegend(pal = pal, values = ~density, opacity = 0.7, title = NULL,
              position = "bottomright")
}


map_tau <- function(states) {
  states$tau[is.na(states$tau)] = 0 
  bins <- seq(-1, 1, length.out = 11)
  pal <- colorBin(
    palette = c(muted("red"), "white", muted("blue")),
    domain = states$tau, 
    bins = bins
  )
  labels <- sprintf(
    "<strong>%s</strong><br/>%g slope",
    states$name, states$slope
  ) %>% lapply(htmltools::HTML)

  leaflet(states) %>%
    setView(13.05073, 47.79724, 13) %>% 
    addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Carto basemap") %>%
    addPolygons(
      fillColor = ~pal(tau),
      weight = 1,
      opacity = 1,
      color = "black",
      fillOpacity = 0.7,
      highlight = highlightOptions(
        weight = 5,
        color = "white",
        fillOpacity = 0.7,
        bringToFront = TRUE),
      label = labels,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto")) %>%
    addLegend(pal = pal, values = ~tau, opacity = 0.7, title = NULL,
              position = "bottomright")
}


map_create_trends <- function(states, estimator = "tau") {
  n_years <- 1:21
  only_values <- st_drop_geometry(states[paste0("X",2000:2020)])
  tau_v <- function(x) mk.test(as.numeric(only_values[x,]))[["estimates"]]["tau"]
  tau_slope <- function(x) lm(as.numeric(only_values[x,])~n_years)$coefficients[2]
  if (estimator == "tau") {
    sapply(1:nrow(only_values), tau_v) 
  } else if (estimator == "slope") {
    sapply(1:nrow(only_values), tau_slope)
  }
}

map_plotly_graph <- function(states) {
  eliminate_mean <- function(x) {
    values <- as.numeric(only_values[x,])
    (values-mean(values))/sd(values)
  }
  only_values <- st_drop_geometry(states[c(paste0("X",2000:2020))])
  names_df <- st_drop_geometry(states["name"])
  only_values_nomeans <- data.frame(lapply(1:33, eliminate_mean)) %>%
    t %>% as.data.frame()
  rownames(only_values_nomeans) <- NULL
  colnames(only_values_nomeans) <- colnames(only_values)
  data_var <- cbind(names_df, only_values_nomeans)
  data_var$tau <- states$tau
  data_var$slope <- states$slope
  data_var_melt <- data_var %>%
    pivot_longer(paste0("X",2000:2020), names_to = "year", values_to = "fake_pop")
  data_var_melt2 <- only_values %>%
    pivot_longer(paste0("X",2000:2020), names_to = "year", values_to = "fake_pop")
  data_var_melt$year <- as.numeric(substr(data_var_melt$year,2,5))
  data_var_melt$population <- round(data_var_melt2$fake_pop)
  
  # Salzburg
  salzburg_data <- data_var_melt %>% 
    filter(name == "Salzburg")
  
  ggmap <- ggplot(data_var_melt) +
    geom_line(aes(x = year, 
                  y = fake_pop,
                  color = tau,
                  fake2 = population,
                  group = name),
              size = 0.6,
              alpha = 0.6) +
    scale_colour_gradient2() +
    xlab("") +
    ylab("Standard score") +
    scale_x_continuous(limits = c(2000, 2020), expand = c(0, 0)) +
    theme_bw()
  ggplotly(ggmap, tooltip = c("name", "year", "population"))
}

