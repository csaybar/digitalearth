library(googleCloudStorageR)
library(reticulate)
library(leaflet)
library(leafem)
library(raster)
library(stars)
library(sf)

#rgee::ee_Initialize("csaybar", gcs = TRUE)
#requests <- import("requests")
#source_python("utils.py")

create_tile_ <- function(raster) {
  tf1 <- paste0(tempfile(), ".tif")
  writeRaster(raster, tf1, overwrite = TRUE)
  convert_to_cog_single(tf1)  
  
  # from local to gcs
  gcs_global_bucket("rgee_dev")
  gcs_id <- rgee::local_to_gcs(tf1, bucket = "rgee_dev")
  googleCloudStorageR::gcs_update_object_acl(basename(gcs_id), 
                        bucket = gcs_get_global_bucket(),
                        entity_type = "allUsers")
  gcs_id_dev <- googleCloudStorageR::gcs_download_url(basename(gcs_id))
  r <- requests$get(
    url = sprintf("%s/cog/tilejson.json", titiler_server), 
    params = list(
      url = gcs_id_dev,
      assets = "pan",
      minzoom = 8L,  # By default titiler will use 0
      maxzoom = 14L # By default titiler will use 24
    )
  )$json()
}

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

download_dem <- function(basin) {
  ee_cselected <- sf_as_ee(basin)
  dem_data <- dem_alos$select("AVE_DSM")$clip(ee_cselected)
  dem_raster <- ee_as_raster(dem_data, ee_cselected$geometry(), dsn = "data/dem.tif")
  dem_raster[dem_raster<=0]=NA
  dem_raster[[1]]
}


create_dem_range <- function(dem_raster) {
  ee_intervals <- seq(minValue(dem_raster), maxValue(dem_raster), 200)
  ee_intervals[1] <- ee_intervals[1] - 300
  ee_intervals[length(ee_intervals)] <- ee_intervals[length(ee_intervals)] + 300
  intervalss <- lapply(1:(length(ee_intervals) -1), function(x) c(ee_intervals[x:(x+1)], x)) %>% 
    do.call(c, .)
  intervalss_to_text <- lapply(1:(length(ee_intervals) -1), function(x) paste0(ee_intervals[x:(x+1)], collapse = "-")) %>% 
    do.call(c, .)
  ele_class <- reclassify(dem_raster, intervalss)
  dem_areas <- st_as_stars(ele_class) %>% 
    st_as_sf(merge = TRUE) %>% # this is the raster to polygons part
    st_cast("POLYGON")
  # remove very small polygons
  dem_areas <- dem_areas[st_area(dem_areas) %>% as.numeric() > 1000, ] %>% 
    sfheaders::sf_remove_holes() %>% 
    as("Spatial")
  factor_values <- factor(dem_areas$dem)
  levels(factor_values) <- intervalss_to_text
  dem_areas$dem_range <- factor_values %>% as.character()
  dem_areas
}

question_01_01 <- function() {
  codes <- "2  8272285 42 0 0 0 0"
  results_sf <- create_watershed_and_rivers(codes = codes)
  basin <- results_sf$basin
  # 3. rivers 
  # dem_raster <- download_dem(basin)
  dem_raster <- raster("data/dem.tif")
  dem_raster[dem_raster <= 0] = NA
  
  # Question N°1
  slope <- terrain(dem_raster, unit = "degrees")
  slope[is.nan(slope)] = NA
  # plot(slope)
  basinX <- basin %>% st_cast("LINESTRING")
  m1 <- mapview::mapview(slope, na.color = "#FFFFFF00")
  m2 <- mapview::mapview(basinX$geometry, color = "black", lwd = 3.5)
  m2 + m1
}

question_01_02 <- function() {
  dem_raster <- raster("data/dem.tif")
  dem_raster[dem_raster <= 0] = NA
  slope <- terrain(dem_raster, unit = "degrees")
  slope[is.nan(slope)] = NA
  hist(slope, main="", xlab="Values")
}

question_02_01 <- function() {
  codes <- "2  8272285 42 0 0 0 0"
  results_sf <- create_watershed_and_rivers(codes = codes)
  basin <- results_sf$basin
  basinX <- basin %>% st_cast("LINESTRING") %>% '['("geometry")
  pal <- colorRampPalette(c("red", "white", "blue"))
  no_curvature <- raster("data/cesar_relative_slope_position.tif")
  no_curvature[no_curvature <= 0] = NA
  relative_slope_position <- mask(no_curvature, as(basin, "Spatial"))
  m1 <- mapview::mapview(relative_slope_position, na.color = "#FFFFFF00", col.regions = pal(100))
  m2 <- mapview::mapview(basinX$geometry, color = "black", lwd = 3.5)
  (m2 + m1)
}

question_03_01 <- function() {
  dem_raster <- raster("data/dem.tif")
  dem_raster[dem_raster <= 0] = NA
  
  slope <- terrain(dem_raster, unit = "degrees")
  slope[is.nan(slope)] = NA
  
  dem_ranges <- create_dem_range(dem_raster)
  dem_areas_slope <- raster::extract(slope, dem_ranges, fun = mean, na.rm = TRUE, sp = TRUE)
  m1 <- mapview::mapview(dem_areas_slope, zcol = "slope", layer.name = "Slope - DEM each 200 meters.")
  m1
}

question_03_02 <- function() {
  dem_raster <- raster("data/dem.tif")
  dem_raster[dem_raster <= 0] = NA
  
  slope <- terrain(dem_raster, unit = "degrees")
  slope[is.nan(slope)] = NA
  
  dem_ranges <- create_dem_range(dem_raster)
  dem_areas_slope <- raster::extract(slope, dem_ranges, fun = mean, na.rm = TRUE, sp = TRUE)
  to_display <- dem_areas_slope[,2:3]@data
  to_display$dem_mean <- unlist(lapply(strsplit(to_display$dem_range,"-"), function(x) mean(as.numeric(x))))
  plot(to_display$dem_mean, to_display$slope, ylab="slope", xlab = "dem", lwd=5, pch=19)
  lines(to_display$dem_mean, to_display$slope)
}

question_03_03 <- function() {
  dem_raster <- raster("data/dem.tif")
  dem_raster[dem_raster <= 0] = NA
  
  slope <- terrain(dem_raster, unit = "degrees")
  slope[is.nan(slope)] = NA
  
  codes <- "2  8272285 42 0 0 0 0"
  results_sf <- create_watershed_and_rivers(codes = codes)
  basin <- results_sf$basin
  basinX <- basin %>% st_cast("LINESTRING") %>% '['("geometry")
  
  m1 <- mapview::mapview(slope, na.color = "#FFFFFF00", layer.name = "slope_100", legend = FALSE)
  m2 <- mapview::mapview(basinX$geometry, layer.name = "borders", color = "black", lwd = 3.5)
  m3 <- (m2 + m1)

  m4 <- mapview::mapview(raster::aggregate(slope, fact=4), na.color = "#FFFFFF00",
                         layer.name = "slope_1000", legend = FALSE)
  m5 <- (m2 + m4)
  m3 + m5  
}

