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
    "<strong>%s</strong></br><strong>Distance: </strong>%s km<sup>2</sup></br><strong>Approximate time: </strong>%s min.",
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
    addPolylines(data = lines_container,
                 color = "purple",
                 weight = 6,
                 opacity = 1,
                 fillOpacity = 0.1,
                 group = "Walk time/walk distance", 
                 popup = ~pop_message,
                 dashArray = "2",
                 highlight = highlightOptions(
                   weight = 7,
                   color = "black",
                   fillOpacity = 0.7,
                   bringToFront = TRUE
                 )) %>% 
    addCircleMarkers(lng = ~x, 
                     lat = ~y,
                     radius = 15,
                     weight = 3,
                     color = "black",
                     opacity = 1,
                     fillOpacity = 1,
                     group = "OJAB",
                     popup = ~pop_message) %>% 
    addCircleMarkers(data = map_water_container(dirfile_walk_distance),
                     lng = ~X, 
                     lat = ~Y,
                     radius = 1.5,
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
  addLayersControl(
    baseGroups = c("ESRI basemap", "Carto basemap"),
    options = layersControlOptions(collapsed = FALSE)
  )
}

map_walk4 <- function() {
  walk4 <- st_read("data/04_walk_4min.geojson", quiet = TRUE) %>% 
    '['("Name_1")
  colnames(walk4) <- c("name", "geometry")
  walk4$pop_message <- sprintf(
    "<strong>%s</strong></br>4 minute walking area",walk4$name 
  )
  walk4
}

map_walk8 <- function() {
  walk8 <- st_read("data/04_walk_08min.geojson", quiet = TRUE) %>% 
    '['("Name_1")
  colnames(walk8) <- c("name", "geometry")
  walk8$pop_message <- sprintf(
    "<strong>%s</strong></br>8 minute walking area",walk8$name 
  )
  walk8
}

map_walk10 <- function() {
  walk10 <- st_read("data/04_walk_10min.geojson", quiet = TRUE) %>% 
    '['("Name_1")
  colnames(walk10) <- c("name", "geometry")
  walk10$pop_message <- sprintf(
    "<strong>%s</strong></br>10 minute walking area",walk10$name 
  )
  walk10
}

map_03 <- function() {
  kinder <- read_sf("data/kindergarden.shp.shp", quiet = TRUE) %>% 
    cbind(st_coordinates(.$geometry)) %>% 
    '['(.$NAME %in% c('R.k. Pfarr-KG Dompfarre', 
                           'AGG Vogelweiderstrasse',
                           'KG Alpensiedlung',
                           'AGG "English Play Corner"'),)
  kinder$pop_message_map01  <- paste(
    sep = "<br/>",
    sprintf("<strong>name:</strong> %s", kinder$NAME),
    sprintf("<strong>seats:</strong> %s", kinder$PLAETZE)
  )
  
  map_walk10_obj <- map_walk10()
  map_walk8_obj <- map_walk8()
  map_walk4_obj <- map_walk4()
  
  kinder %>% 
    leaflet() %>%
    setView(13.06702, 47.79488, 14) %>% 
    addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
    addProviderTiles(providers$CartoDB.Voyager, group = "Carto basemap") %>%
    addPolygons(data = map_walk10_obj,
                color = "black",
                fillColor = "red",
                weight = 0.5,
                opacity = 1,
                fillOpacity = 1,
                group = "Walk time/walk distance", 
                popup = ~pop_message,
                dashArray = "2") %>%
  addPolygons(data = map_walk8_obj, 
              color = "black",
              fillColor = "green",
              weight = 0.5,
              opacity = 1,
              fillOpacity = 1,
              group = "Walk time/walk distance", 
              popup = ~pop_message,
              dashArray = "2")  %>%
    addPolygons(data = map_walk4_obj, 
                color = "black",
                fillColor = "yellow",
                weight = 0.5,
                opacity = 1,
                fillOpacity = 1,
                group = "Walk time/walk distance", 
                popup = ~pop_message,
                dashArray = "2"
                ) %>% 
    addCircleMarkers(
      lng = ~X, 
      lat = ~Y, 
      radius =  3,
      color = "black",
      opacity = 1,
      fillOpacity = 1,
      group = "Kindergartens",
      popup = ~pop_message_map01
    )
}

# sdas <- read_sf("data/kindergarden.shp.shp")
# mapview(sdas, mp3)

wranglig_route_data <- function() {
  truck_route <- read_sf("data/03_results2.geojson") 
  truck_route_points <- truck_route[st_geometry_type(truck_route$geometry) == "POINT",]
  truck_route_line <- truck_route[st_geometry_type(truck_route$geometry) == "MULTILINESTRING",]
  
  truck_route_points_f <- truck_route_points["geometry"]
  truck_route_lines_f <- truck_route_line["geometry"]
  
  truck_route_points_f$routes <- sprintf("Route %s", 
                                         gsub(
                                           pattern = "waste treatment plant - Route", 
                                           replacement = "", 
                                           x = truck_route_points$RouteName))
  truck_route_points_f$from_prev_travel_time <- truck_route_points$FromPrevTravelTime
  truck_route_points_f$from_prev_distance <- truck_route_points$FromPrevDistance
  truck_route_points_f$message <- sprintf(
    "<center><strong>%s</strong></center><br/><strong>From previous travel time:</strong>%s min<br/><strong>From previous distance: </strong>%s",
    truck_route_points_f$routes, 
    round(truck_route_points_f$from_prev_travel_time, 3), 
    round(truck_route_points_f$from_prev_distance, 3)
  )
  truck_route_lines_f$routes <- sprintf("Route %s",
                                        gsub(
                                          pattern = "waste treatment plant - Route", 
                                          replacement = "", 
                                          x = truck_route_line$RouteName))
  truck_route_lines_f$total_travel_time <- truck_route_line$TotalTravelTime
  truck_route_lines_f$total_miles <- truck_route_line$Total_Miles
  truck_route_lines_f$message <- sprintf(
    "<center><strong>%s</strong></center><br/><strong>Total travel time:</strong>%s min<br/><strong>Total miles: </strong>%s",
    truck_route_lines_f$routes, 
    round(truck_route_lines_f$total_travel_time), 
    round(truck_route_lines_f$total_miles)
  )
  
  #truck_route_lines_f <- st_drop_geometry(truck_route_lines_f)
  #truck_route_points_f <- st_drop_geometry(truck_route_points_f)
  
  truck_route_points_f <- truck_route_points_f %>% 
    cbind(st_coordinates(.$geometry))
  
  ## ggobject
  truck_route_points_f_ngeom <- st_drop_geometry(truck_route_points_f)
  gg01 <- ggplot(truck_route_points_f_ngeom) +
    geom_boxplot(aes(x = routes,
                     y = from_prev_travel_time, 
                     color = from_prev_travel_time)) +
    theme(legend.position="none") +
    ylab("Travel time") + xlab("") +
    theme_classic()
  list(point = truck_route_points_f, lines = truck_route_lines_f, ggviz = gg01)
}


map_04 <- function(dirfile_ojab,
                   dirfile_walk_distance) {
  point_container <- wranglig_route_data()$point
  lines_container <- wranglig_route_data()$lines
  rep_p <- table(point_container$routes)
  lines_container$color <- c("#ff0400","#ffa352","#0d83ff")
  point_container$color <- c(rep("#ff0400", rep_p[1]),
                             rep("#ffa352", rep_p[2]), 
                             rep("#0d83ff", rep_p[3]))
  point_container %>% 
    leaflet() %>% 
    setView(13.03661, 47.81069, 13) %>% 
    addProviderTiles(providers$CartoDB.Positron, group = "Carto basemap") %>%
    addProviderTiles("Esri.WorldImagery", group = "ESRI basemap") %>%
    addPolylines(data = lines_container,
                 color = ~color,
                 weight = 3,
                 opacity = 1,
                 fillOpacity = 0.1,
                 group = "Walk time/walk distance", 
                 popup = ~message,
                 dashArray = "2") %>% 
    addCircleMarkers(lng = ~X, 
                     lat = ~Y,
                     radius = 5,
                     weight = 2,
                     color = "black",
                     fillColor = ~color,
                     opacity = 1,
                     fillOpacity = 1,
                     group = "OJAB",
                     popup = ~message) %>% 
    addLayersControl(
      baseGroups = c("Carto basemap", "ESRI basemap"),
      options = layersControlOptions(collapsed = FALSE)
    )
}


