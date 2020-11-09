library(rgee)
library(plotly)
library(leaflet)
library(htmltools)
library(mapview)
library(sf)

# Init Earth Engine -------------------------------------------------------
ee_Initialize(email = "csaybar", gcs = TRUE, drive = TRUE)

# Define viz parameters ---------------------------------------------------
visualization <- list(
  bands = "population",
  min = 0.0,
  max = 50.0,
  palette = c('24126c', '1fff4f', 'd4ff50')
)

# Download population data ------------------------------------------------
sf_mydata <- read_sf("data/scity.shp") %>% 
  st_cast("POLYGON") %>% 
  '['("NAME")

for (index in seq_len(nrow(sf_mydata))) {
  print(index)
  ee_mydata <- sf_mydata[index, ] %>% sf_as_ee()
  name_dist <- sf_mydata[index, ]$NAME
  
  world_data <- ee$ImageCollection("WorldPop/GP/100m/pop") %>% 
    ee$ImageCollection$filterBounds(ee_mydata) %>% 
    ee$ImageCollection$filterMetadata("country", "equals", "AUT")
  
  pop_data <- ee_extract(world_data$toBands(), ee_mydata, ee$Reducer$sum(), scale = 100)
  base_case <- data.frame(name = name_dist, pop_data)
  colnames(base_case) <- c("name", 2000:2020)
  sf_base_case <- st_sf(
    base_case, 
    geometry = sf_mydata[index, ]$geometry
  )
  if (index == 1) {
    sf_init_case <- sf_base_case
  } else {
    sf_init_case <- rbind(sf_init_case, sf_base_case)
  }
}

# Write results as geojson  -----------------------------------------------
mean_pop <- apply(st_drop_geometry(sf_init_case[as.character(2000:2019)]), 1, mean)
sf_init_case2 <- sf_init_case[as.character(2000:2019)]
sf_init_case$density <- as.numeric(mean_pop/(st_area(sf_init_case2)/1000000))
# mapview(sf_init_case["density"])
write_sf(sf_init_case, "salzburg_population.geojson",delete_dsn = TRUE)

