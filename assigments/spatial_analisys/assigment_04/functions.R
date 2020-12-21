library(tidyverse)
library(reticulate)
library(plotly)
library(leaflet)
library(mapview)
library(leafem)
library(raster)
library(RSAGA)
library(stars)
library(sf)

mapviewOptions(fgb = FALSE)

create_watershed_and_rivers <- function(codes) {
  catchments <- read_sf("data/catchments.shp")
  # basin
  cselected <- catchments[catchments$HZB_CODE %in%  codes, ] %>% 
    st_cast("POLYGON") %>% 
    "["("FID")
  # rivers
  rivers <- read_sf("data/stream.shp") %>% 
    st_intersection(cselected) %>% 
    "["("FID")
  list(basin = cselected, river = rivers)
}

map_01 <- function() {
  codes <- "2  8272285 42 0 0 0 0"
  results_sf <- create_watershed_and_rivers(codes = codes)
  basin <- results_sf$basin
  rivers <- results_sf$river
  # 3. rivers 
  # dem_raster <- download_dem(basin)
  dem_raster <- raster("data/dem.tif")
  dem_raster[dem_raster <= 0] = NA
  
  basin_polyline <- st_cast(basin$geometry, "LINESTRING")
  m1 <- mapview::mapview(dem_raster, col.regions = topo.colors(7), 
                         na.color = "#FFFFFF00")
  m2 <- mapview::mapview(basin_polyline, color = "black", lwd = 3.5)
  m3 <- mapview::mapview(rivers$geometry, color = "blue", lwd = 3.5)
  m1 + m2 + m3
}

map_02 <- function() {
  codes <- "2  8272285 42 0 0 0 0"
  results_sf <- create_watershed_and_rivers(codes = codes)
  basin <- results_sf$basin
  rivers <- results_sf$river
  
  basin_me <- st_read("data/catchments_acc.shp", quiet=TRUE)
  basin_me <- basin_me[which.max(st_area(basin_me)),]
  rivers_me <- st_intersection(st_zm(st_read("data/stream_acc.shp", quiet=TRUE)), basin_me)
  
  m1 <- mapview(basin_me$geometry, color = "black", lwd = 3.5, col.regions = "black")
  m2 <- mapview(rivers_me$geometry, color = "blue", lwd = 3.5)
  
  m3 <- mapview(basin$geometry, color = "black", lwd = 3.5, col.regions = "black")
  m4 <- mapview(rivers$geometry, color = "blue", lwd = 3.5)
  
  (m1 + m2) | (m3 + m4)
}


map_03 <- function() {
  basin_me <- st_read("data/catchments_acc.shp", quiet=TRUE)
  basin_me <- basin_me[which.max(st_area(basin_me)),]
  rivers_me <- st_intersection(st_zm(st_read("data/stream_acc.shp", quiet=TRUE)), basin_me)
  basin_me <-st_cast(basin_me$geometry, "MULTILINESTRING")
  time_out <- raster("data/time_out.sdat")
  m1 <- mapview(basin_me, color = "black", lwd = 3.5, col.regions = "black")
  m2 <- mapview(rivers_me$geometry, color = "blue", lwd = 0.5)
  m3 <- mapview(time_out, at = seq(0,60,5),
                na.color = "#FFFFFF00", layer.name = "Concentration time [min]")
  (m1 + m2 + m3)
}


map_04 <- function() {
  time_out <- raster("data/time_out.sdat")
  f <- hist(getValues(time_out), breaks=20, plot = FALSE)
  dat <- data.frame(counts= f$counts,breaks = f$mids)
  g1 <- ggplot(dat, aes(x = breaks, y = counts, fill =counts)) + 
    geom_bar(stat = "identity",alpha = 0.8) +
    xlab("Concentration time (min)") + ylab("Frequency") +
    scale_fill_gradient(low="blue", high="red") + 
    scale_y_continuous(expand = c(0, 0)) +
    theme_classic()
  ggplotly(g1)
}

map_05 <- function() {
  basin_me <- st_read("data/catchments_acc.shp", quiet=TRUE)
  basin_me <- basin_me[which.max(st_area(basin_me)),]$geometry
  
  flow_acc_01 <- st_read("data/stream_acc.shp", quiet=TRUE)
  flow_acc_01 <-st_intersection(st_zm(flow_acc_01), basin_me)
  flow_acc_01$LENGTH <- flow_acc_01$LENGTH * 111111
  m1 <- mapview(flow_acc_01, zcol = "LENGTH")
  
  flow_acc_02 <- st_read("data/stream_acc_nosinks.shp", quiet=TRUE)
  flow_acc_02 <-st_intersection(st_zm(flow_acc_02), basin_me)
  flow_acc_02$Length <- flow_acc_02$Length * 111111
  m2 <- mapview(flow_acc_02$geometry)
  
  basin_me <- st_read("data/catchments_acc.shp", quiet=TRUE)
  basin_me <- basin_me[which.max(st_area(basin_me)),]
  basin_me <-st_cast(basin_me$geometry, "MULTILINESTRING")
  
  m3 <- mapview(basin_me, color = "black", lwd = 3.5, col.regions = "black")
  m4 <- (m3 + m1) | (m3 + m2)
  m4
}
