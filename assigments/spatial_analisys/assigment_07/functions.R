library(tidyverse)
library(plotly)
library(raster)
library(mapview)
library(mapedit)
library(sf)

mapviewOptions(fgb = FALSE)

district <- read_sf("data/district.shp")["NAME"]
geology <- read_sf("data/geology.shp")["LITHOLOGIE"]
salzburg <- read_sf("data/salzburg_city.shp.shp")["geometry"]
landuse <- read_sf("data/land_use.shp")["ITEM"]

map_01 <- function() {
  m1 <- mapview(geology,legend=FALSE) + 
  mapview(st_cast(district$geometry, "MULTILINESTRING"),
          lwd=1,color="black", layer.name="district",
          legend=FALSE)
  m2 <- mapview(landuse,legend=FALSE) + 
    mapview(st_cast(district$geometry, "MULTILINESTRING"),
            lwd=1,color="black", layer.name="district",
            legend=FALSE)
  m1|m2
}

map_02 <- function() {
  filter <- landuse[which(landuse$ITEM == "Industrial, commercial, public, military and private units"),]
  m1 <- mapview(filter,legend=FALSE,layer.name="landuse_01")+ 
    mapview(st_cast(district$geometry, "MULTILINESTRING"),
            lwd=1,color="black", layer.name="district",
            legend=FALSE)
  m1
} 


map_03 <- function() {
  filter <- landuse[which(landuse$ITEM == "Industrial, commercial, public, military and private units"),]
  filter_intrs <- st_intersection(filter, geology)
  m1 <- mapview(st_cast(district$geometry, "MULTILINESTRING"),
            lwd=1,color="black", layer.name="district",
            legend=FALSE)+
    mapview(filter_intrs, zcol = "LITHOLOGIE",legend=FALSE,layer.name="landuse_01")
  m1
} 


map_04 <- function() {
  new_district <- agg_c(geology["LITHOLOGIE"], district)
  m1 <- mapview(st_cast(district$geometry, "MULTILINESTRING"),
                lwd=1,color="black", layer.name="district",
                legend=FALSE)+
    mapview(new_district, zcol = "LITHOLOGIE",legend=FALSE,layer.name="landuse_01")
  m1 | mapview(geology, zcol = "LITHOLOGIE",legend=FALSE,layer.name="landuse_01")
} 


Mode <- function(x, na.rm = FALSE) {
  if(na.rm){
    x = x[!is.na(x)]
  }
  
  ux <- unique(x)
  return(ux[which.max(tabulate(match(x, ux)))])
}

agg_c <- function(geom1,geom2,fun) {
  s_pop <- function(x) {
    inters <- st_intersection(geom1, geom2[x,])[1]
    inters$area <- st_area(inters)
    inters[[1]][which.max(inters[["area"]])]
  }
  geom2$LITHOLOGIE <- sapply(seq_len(nrow(geom2)), s_pop)
  geom2
}

