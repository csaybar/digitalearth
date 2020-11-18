library(ggplot2)
library(plotly)
library(leaflet)
library(htmltools)
library(mapview)
library(sf)

set.seed(10)
# Read the data
salzburg <- read_sf("data/salzburg_city.shp.shp")
kinder <- read_sf("data/kindergarden.shp.shp") %>% 
  cbind(st_coordinates(.$geometry))  
motor <- read_sf("data/motorway.shp.shp")
kinder$PLAETZE_sqrt  <- sqrt(kinder$PLAETZE)*1.5
min_distance <- sapply(seq_len(nrow(kinder)), function(x) min(st_distance(kinder[x,], motor)))
kinder$min_distance <- min_distance
kinder$classes <- kmeans(kinder$min_distance, 4)$cluster

# Ordering classes
fct_class <- as.factor(kinder$classes)
levels(fct_class) <- c("Low", "Very low", "Medium", "High")
fct_class <- factor(fct_class, c("Very low", "Low", "Medium", "High"))
kinder$classes <- fct_class

kinder$pop_message_map01  <- paste(
  sep = "<br/>",
  sprintf("<strong>name:</strong> %s", kinder$NAME),
  sprintf("<strong>seats:</strong> %s", kinder$PLAETZE)
)

kinder$pop_message_map02  <- paste(
  sep = "<br/>",
  sprintf("<strong>name:</strong> %s", kinder$NAME),
  sprintf("<strong>distance:</strong> %s meters", round(kinder$min_distance))
)

kinder$pop_message_map03  <- paste(
  sep = "<br/>",
  sprintf("<strong>name:</strong> %s", kinder$NAME),
  sprintf("<strong>class:</strong> %s", kinder$classes),
  sprintf("<strong>seats:</strong> %s", kinder$PLAETZE)
)

pal <- colorNumeric(
  palette = "YlOrRd",
  domain = kinder$min_distance
)

pal_class <- colorFactor(
  palette = "RdYlBu",
  domain = kinder$classes,
  reverse = TRUE,
  n = 4
)

# Map N° 01
leaflet(kinder) %>% 
  setView(13.03982, 47.79800, 12) %>% 
  addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
  addProviderTiles(providers$CartoDB.Voyager, group = "Carto basemap") %>%
  addPolylines(data = salzburg, color = "#696969", opacity = 1, weight = 2) %>% 
  addPolylines(data = motor, color = "red", group="Motorways") %>%
  addCircleMarkers(lng = ~X, 
                   lat = ~Y, 
                   weight = 1.5,
                   radius = ~PLAETZE_sqrt,
                   color = "black",
                   opacity = 1,
                   fillOpacity = 0.1,
                   group = "Kindergartens",
                   popup = ~pop_message_map01) %>% 
  addLayersControl(
    baseGroups = c("Carto basemap", "ESRI basemap"),
    overlayGroups = c("Motorways", "Kindergartens"),
    options = layersControlOptions(collapsed = FALSE)
  )

# Map N° 02
leaflet(kinder) %>% 
  setView(13.03982, 47.79800, 12) %>% 
  addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
  addProviderTiles(providers$CartoDB.Voyager, group = "Carto basemap") %>%
  addPolylines(data = salzburg, color = "#696969", opacity = 1, weight = 2) %>% 
  addPolylines(data = motor, color = "red", group="Motorways") %>% 
  addCircleMarkers(lng = ~X, 
                   lat = ~Y, 
                   weight = 1.5,
                   color = "black",
                   fillColor = ~colorQuantile("YlOrRd", min_distance)(min_distance),
                   opacity = 1,
                   fillOpacity = 1,
                   group = "Kindergartens",
                   popup = ~pop_message_map02) %>% 
  addLayersControl(
    baseGroups = c("Carto basemap", "ESRI basemap"),
    overlayGroups = c("Motorways", "Kindergartens"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>% 
  addLegend("bottomleft", pal = pal, values = ~min_distance,
            title = "Distance in meters",
            opacity = 1
  )

# Map 3
leaflet(kinder) %>% 
  setView(13.03982, 47.79800, 12) %>% 
  addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
  addProviderTiles(providers$CartoDB.Voyager, group = "Carto basemap") %>%
  addPolylines(data = salzburg, color = "#696969", opacity = 1, weight = 2) %>% 
  addPolylines(data = motor, color = "red", group="Motorways") %>% 
  addCircleMarkers(lng = ~X, 
                   lat = ~Y, 
                   radius = ~PLAETZE_sqrt,
                   weight = 1.5,
                   color = "black",
                   fillColor = ~colorFactor("RdYlBu", reverse = TRUE, classes)(classes),
                   opacity = 1,
                   fillOpacity = 1,
                   group = "Kindergartens",
                   popup = ~pop_message_map03) %>% 
  addLayersControl(
    baseGroups = c("Carto basemap", "ESRI basemap"),
    overlayGroups = c("Motorways", "Kindergartens"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>% 
  addLegend("bottomleft", pal = pal_class, values = ~classes,
            title = "",
            opacity = 1
  )


# Map 4?
plaetze_classes <- classInt::classIntervals(kinder$PLAETZE, 4, "quantile", dataPrecision = 1)
plaetze_cut <- cut(kinder$PLAETZE, plaetze_classes$brks, include.lowest = TRUE)
plaetze_cut_order <- factor(plaetze_cut, levels(plaetze_cut), ordered = TRUE)
kinder$PLAETZE_class <- plaetze_cut_order

p <- ggplot(data = kinder, aes(x = classes, fill = PLAETZE_class)) +
  geom_bar(position = "dodge") + 
  guides(fill=guide_legend("PLAETZE")) +
  xlab("") +
  ylab("Number of kindergarten")
ggplotly(p)

# Map 5?
leaflet(kinder[kinder$PLAETZE >25,]) %>% 
  setView(13.03982, 47.79800, 12) %>% 
  addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
  addProviderTiles(providers$CartoDB.Voyager, group = "Carto basemap") %>%
  addPolylines(data = salzburg, color = "#696969", opacity = 1, weight = 2) %>% 
  addPolylines(data = motor, color = "red", group="Motorways") %>% 
  addCircleMarkers(lng = ~X, 
                   lat = ~Y, 
                   radius = ~PLAETZE_sqrt,
                   weight = 1.5,
                   color = "black",
                   fillColor = ~colorFactor("RdYlBu", reverse = TRUE, classes)(classes),
                   opacity = 1,
                   fillOpacity = 1,
                   group = "Kindergartens",
                   popup = ~pop_message_map03) %>% 
  addLayersControl(
    baseGroups = c("Carto basemap", "ESRI basemap"),
    overlayGroups = c("Motorways", "Kindergartens"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>% 
  addLegend("bottomleft", pal = pal_class, values = ~classes,
            title = "",
            opacity = 1
  )

# Map 6?
leaflet(kinder[kinder$PLAETZE >25,]) %>% 
  setView(13.03982, 47.79800, 12) %>% 
  addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
  addProviderTiles(providers$CartoDB.Voyager, group = "Carto basemap") %>%
  addPolylines(data = salzburg, color = "#696969", opacity = 1, weight = 2) %>% 
  addPolylines(data = motor, color = "red", group="Motorways") %>% 
  addCircleMarkers(lng = ~X, 
                   lat = ~Y, 
                   radius = ~PLAETZE_sqrt,
                   weight = 1.5,
                   color = "black",
                   fillColor = ~colorFactor("RdYlBu", reverse = TRUE, classes)(classes),
                   opacity = 1,
                   fillOpacity = 1,
                   group = "Kindergartens",
                   popup = ~pop_message_map03) %>% 
  addLayersControl(
    baseGroups = c("Carto basemap", "ESRI basemap"),
    overlayGroups = c("Motorways", "Kindergartens"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>% 
  addLegend("bottomleft", pal = pal_class, values = ~classes,
            title = "",
            opacity = 1
  )

## general 
a <- nrow(kinder)
b <- nrow(kinder[kinder$PLAETZE >25,])
(a - b)/a*100


# Map 7?
buffer <- st_buffer(endCapStyle="ROUND",kinder[kinder$PLAETZE>=25,], 750/111111, nQuadSegs = 10) %>% 
  st_union() %>% 
  st_intersection(salzburg)

leaflet(kinder[kinder$PLAETZE >= 25,]) %>% 
  setView(13.03982, 47.79800, 12) %>% 
  addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
  addProviderTiles(providers$CartoDB.Voyager, group = "Carto basemap") %>%
  addPolylines(data = salzburg, color = "#696969", opacity = 1, weight = 2) %>% 
  addPolylines(data = motor, color = "red", group="Motorways") %>%
  addPolygons(data = buffer, 
              color = "black",
              fillColor = "#134ff2", 
              weight = 1,
              group = "Area of influence") %>% 
  addCircleMarkers(lng = ~X, 
                   lat = ~Y, 
                   radius = 4,
                   weight = 1.5,
                   color = "black",
                   opacity = 1,
                   fillOpacity = 1,
                   group = "Kindergartens") %>% 
  addLayersControl(
    baseGroups = c("Carto basemap", "ESRI basemap"),
    overlayGroups = c("Motorways", "Kindergartens", "Area of influence"),
    options = layersControlOptions(collapsed = FALSE)
  )
