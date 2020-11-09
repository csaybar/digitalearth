map_createOJAB <- function(dirfile) {
  ojab <- read_sf(dirfile) %>% 
    '['(1) %>% 
    st_transform(4326) %>% 
    cbind(st_coordinates(.$geometry))
  colnames(ojab) <- c("name", "x", "y", "geometry")
  ojab$name <- "ÖJAB-Haus Salzburg"
  ojab$pop_message <- "<strong>ÖJAB-Haus Salzburg</strong>"
  ojab
}

map_createALPEN <- function(dirfile) {
  kindergardens <- read_sf(dirfile) %>% 
    '['(.$NAME == "KG Alpensiedlung",) %>% 
    '['(c("NAME", "PLAETZE")) %>% 
    cbind(st_coordinates(.$geometry))
  colnames(kindergardens) <- c("name", "plaetze", "x", "y", "geometry")
  kindergardens$pop_message <- "<strong>KG Alpensiedlung</strong>"
  kindergardens
  kindergardens
}

map_drive_time <- function(dirfile) {
  drive_time <- read_sf(dirfile) %>% 
    '['(2,) %>% 
    '['(c("Total_Minutes", "Total_Kilometers"))
  drive_time$pop_message <- sprintf(
    "%sTotal minutes: <strong>%s</strong><br/>Total kilometers: <strong>%s</strong>",
    "<strong>Drive time</strong> <br/>",
    round(drive_time$Total_Minutes, 2), 
    round(drive_time$Total_Kilometers, 2)
  )
  drive_time
}

map_water_container <- function(dirfile) {
  water_container <- read_sf(dirfile) %>% 
    '['("ADDRESS") %>% 
    cbind(st_coordinates(.$geometry))
  water_container$pop_message <- sprintf(
    "<strong>Address:</strong> %s",water_container$ADDRESS 
  )
  water_container
}

map_container_distance <- function(dirfile) {
  container_distance_sf <- read_sf(dirfile)
  water_container_point <- container_distance_sf %>%
    '['(1:3, ) %>% 
    '['("Name") %>% 
    cbind(st_coordinates(.$geometry))
  water_container_point$Name <- c("Strubergasse 1", "Johann-Brunauer-Strabe 4", "Schwarzstrabe 50")
  water_container_point$pop_message <- sprintf(
    "<strong>Address:</strong> %s",water_container_point$Name 
  )
  
  container_distance_sf$RouteName <- gsub(
    pattern = "my_house",
    replacement =  "ÖJAB-Haus",
    x =  container_distance_sf$RouteName
  )
  
  container_distance_sf$RouteName <- gsub(
    pattern = "�",
    replacement =  "b",
    x =  container_distance_sf$RouteName
  )

  container_distance_sf$RouteName <- gsub(
    pattern = " - ",
    replacement = " to",
    x =  container_distance_sf$RouteName
  )
  
  
  water_container_lines <-  container_distance_sf %>%
    '['(4:6, ) %>% 
    '['(c("Total_Kilometers", "Total_Minutes", "RouteName"))
  water_container_lines$pop_message <- sprintf(
    "<strong>%s</strong></br><strong>Distance: </strong>%s km<sup>2</sup></br><strong>Time: </strong>%s",
    water_container_lines$RouteName,
    round(water_container_lines$Total_Kilometers, 2),
    round(water_container_lines$Total_Minutes, 2)
  )
  list(point = water_container_point, 
       lines = water_container_lines)
}

map_drive_distance <- function(dirfile) {
  drive_distance <- read_sf(dirfile) %>% 
    '['(2,) %>% 
    '['(c("Total_Minutes", "Total_Kilometers"))
  drive_distance$pop_message <- sprintf(
    "%sTotal minutes: <strong>%s</strong><br/>Total kilometers: <strong>%s</strong>",
    "<strong>Drive distance</strong> <br/>",
    round(drive_distance$Total_Minutes, 2), 
    round(drive_distance$Total_Kilometers, 2)
  )
  drive_distance
}

map_walk_distance <- function(dirfile) {
  walk_distance <- read_sf(dirfile) %>% 
    '['(2,) %>% 
    '['(c("Total_Minutes", "Total_Kilometers"))
  walk_distance$pop_message <- sprintf(
    "%sTotal minutes: <strong>%s</strong><br/>Total kilometers: <strong>%s</strong>",
    "<strong>Walk distance/time </strong> <br/>",
    round(walk_distance$Total_Minutes, 2), 
    round(walk_distance$Total_Kilometers, 2)
  )
  walk_distance
}


map_01 <- function(dirfile_ojab, 
                   dirfile_kinde, 
                   dirfile_drive_time, 
                   dirfile_drive_distance, 
                   dirfile_walk_distance) {
  map_createOJAB(dirfile_ojab) %>% 
    leaflet() %>% 
    setView(13.04982, 47.79300, 14) %>% 
    addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
    addProviderTiles(providers$CartoDB.Voyager, group = "Carto basemap") %>%
    addCircleMarkers(lng = ~x, 
                     lat = ~y, 
                     weight = 2,
                     color = "green",
                     opacity = 1,
                     fillOpacity = 1,
                     group = "OJAB",
                     popup = ~pop_message) %>% 
    addCircleMarkers(data = map_createALPEN(dirfile_kinde),
                     lng = ~x, 
                     lat = ~y, 
                     weight = 2,
                     color = "green",
                     opacity = 1,
                     fillOpacity = 1,
                     group = "KG Alpensiedlung", 
                     popup = ~pop_message) %>% 
    addPolylines(data = map_drive_time(dirfile_drive_time),
                 color = "black",
                 weight = 2,
                 opacity = 1,
                 fillOpacity = 0.1,
                 dashArray = "3",
                 group = "Drive time", 
                 popup = ~pop_message,
                 highlight = highlightOptions(
                   weight = 5,
                   color = "black",
                   fillOpacity = 0.7,
                   bringToFront = TRUE)
    ) %>% 
    addPolylines(data = map_drive_distance(dirfile_drive_distance),
                 color = "red",
                 weight = 2,
                 opacity = 1,
                 fillOpacity = 0.1,
                 group = "Drive distance",
                 popup = ~pop_message,
                 highlight = highlightOptions(
                   weight = 5,
                   color = "red",
                   fillOpacity = 0.7,
                   bringToFront = TRUE)
    ) %>% 
    addPolylines(data = map_walk_distance(dirfile_walk_distance),
                 color = "blue",
                 weight = 2,
                 opacity = 1,
                 fillOpacity = 0.1,
                 group = "Walk time/walk distance", 
                 popup = ~pop_message,
                 dashArray = "2",
                 highlight = highlightOptions(
                   weight = 5,
                   color = "blue",
                   fillOpacity = 0.7,
                   bringToFront = TRUE
                 )
    ) %>% 
    addLayersControl(
      baseGroups = c("Carto basemap", "ESRI basemap"),
      overlayGroups = c("OJAB", "KG Alpensiedlung", "Drive time",
                        "Drive distance", "Walk time/walk distance"),
      options = layersControlOptions(collapsed = FALSE)
    )
}


map_02 <- function(dirfile_ojab,
                   dirfile_walk_distance) {
  point_container <- map_container_distance("data/02_cont.geojson")$point
  lines_container <- map_container_distance("data/02_cont.geojson")$lines

  map_createOJAB(dirfile_ojab) %>% 
    leaflet() %>% 
    setView(13.03661, 47.81069, 17) %>% 
    addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
    addProviderTiles(providers$CartoDB.Voyager, group = "Carto basemap") %>%
    addCircleMarkers(lng = ~x, 
                     lat = ~y,
                     radius = 10,
                     weight = 3,
                     color = "black",
                     opacity = 1,
                     fillOpacity = 1,
                     group = "OJAB",
                     popup = ~pop_message) %>% 
    addCircleMarkers(data = map_water_container(dirfile_walk_distance),
                     lng = ~X, 
                     lat = ~Y,
                     radius = 1,
                     color = "blue",
                     opacity = 1,
                     fillOpacity = 0.1,
                     group = "OJAB",
                     popup = ~pop_message) %>% 
    addMarkers(data = point_container,
               lng = ~X, 
               lat = ~Y,
               group = "OJAB",
               popup = ~pop_message) %>% 
    addPolylines(data = lines_container,
                 color = "purple",
                 weight = 2.5,
                 opacity = 1,
                 fillOpacity = 0.1,
                 group = "Walk time/walk distance", 
                 popup = ~pop_message,
                 dashArray = "2",
                 highlight = highlightOptions(
                   weight = 7,
                   color = "purple",
                   fillOpacity = 0.7,
                   bringToFront = TRUE
                 ))
}

