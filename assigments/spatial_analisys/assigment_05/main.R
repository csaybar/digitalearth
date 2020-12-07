library(raster)
library(stars)
library(rgee)
library(sf)

ee_Initialize()

dem_alos <- ee$Image("JAXA/ALOS/AW3D30/V2_2")

# 1. catchments and river 
codes <- "2  8272285 42 0 0 0 0"
results_sf <- create_watershed_and_rivers(codes = codes)
basin <- results_sf$basin
rivers <- results_sf$river

# 3. rivers 
# dem_raster <- download_dem(basin)
dem_raster <- raster("data/dem.tif")
dem_raster[dem_raster <= 0] = NA

# Question N°1
slope <- terrain(dem_raster, unit = "degrees")
slope[is.nan(slope)] = NA
# plot(slope)

# hist(getValues(slope))



# Question N°2
# austria_dem  <- raster("/home/csaybar/austria_dem10_wgs84.tif")
# dem10_value <- crop(austria_dem, basin)
# writeRaster(dem10_value, "/home/csaybar/tpi/sara_dem.tif", overwrite = TRUE)
basin_rsp <- mask(raster("data/cesar_relative_slope_position.tif"), basin)


# Question N°3
dem_ranges <- create_dem_range(dem_raster)
dem_areas_slope <- raster::extract(slope, dem_ranges, fun = mean, na.rm = TRUE, sp = TRUE)
# write_sf(st_as_sf(dem_ranges), "data/dem_ranges.shp")

plot(dem_areas_slope)
plot(dem_areas_slope$slope, type = "l")