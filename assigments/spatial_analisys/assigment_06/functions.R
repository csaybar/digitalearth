library(tidyverse)
library(plotly)
library(raster)
library(mapview)
library(mapedit)
library(sf)

mapviewOptions(fgb = FALSE)

tower_airport <- read_sf("data/tower_aiport.geojson")
airport <- read_sf("data/airport.geojson")
new_airport <- read_sf("data/extension_airport.geojson")

map_01 <- function() {
  airport$name <- "Current <strong>Deniliquin</strong> airport"
  new_airport$name <- "Planned extension"
  tower_airport$name <- "Tower"
  mapview(st_cast(airport, "LINESTRING"), color = "black") +
    mapview(st_cast(new_airport, "LINESTRING"), color = "red") +
    mapview(tower_airport, zcol = "name")
} 

map_02 <- function() {
  airport$name <- "Current <strong>Deniliquin</strong> airport"
  new_airport$name <- "Planned extension"
  tower_airport$name <- "Tower"
  viz_list <- list.files("data/viz/", full.names = TRUE)
  altq_tower <- gsub("\\.tif$|viz_", "", basename(viz_list)) %>% as.numeric()
  # rviz <- sum(stack(lapply(viz_list, raster)))
  # writeRaster(rviz, "data/viz_sum.tif")
  rviz <- raster("data/viz_sum.tif")
  mapviewOptions(raster.palette = grDevices::hcl.colors(10, palette = "viridis"))
  m1 <-  mapview(st_cast(airport, "LINESTRING"), color = "black") +
  mapview(st_cast(new_airport, "LINESTRING"), color = "red") +
  mapview(tower_airport, zcol = "name")+
  mapview(rviz, na.color = "#FFFFFF00", layer.name = "Visual impact", maxpixels = 10**7)
  m1@map %>%  leaflet::setView(144.96586, -35.55765, 13)
} 



gen_df_viz <- function(save = TRUE) {
  viz_list <- list.files("data/viz/", full.names = TRUE)
  altq_tower <- gsub("\\.tif$|viz_", "", basename(viz_list)) %>% as.numeric()
  for (index in seq_along(viz_list)) {
    total_area <- getValues(raster(viz_list[index]))
    total_area[is.nan(total_area)] = NA
    total_area_sq <- sum(total_area[!is.na(total_area)])* 5 * 5
    df_viz <- data.frame(alt = altq_tower[index], area_km = total_area_sq/1000000)
    if (index == 1) {
      db_base <- df_viz   
    } else {
      db_base <- rbind(db_base, df_viz)
    }
  }
  if (save) {
    write_csv(db_base, "data/viz_df.csv")
  }
}

map_03 <- function() {
  dt <- read_csv("data/viz_df.csv")
  mm1 <- ggplot(dt, aes(x = area_km, y = alt)) +
    geom_line(size=1.15) +
    geom_point(size=3.2) + 
    ylab("Height") +
    xlab("Visible area km2") +
    theme_classic()
  ggplotly(mm1)
}
