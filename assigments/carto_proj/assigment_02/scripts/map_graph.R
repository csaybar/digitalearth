library(trend)
library(scales)
library(plotly)
library(tidyverse)
library(leaflet)
library(htmltools)
library(mapview)
library(sf)


source("functions.R")
# 1. Read Data
states <- read_sf("salzburg_population.geojson")

# 2. Create map
map_base(states)


# 3. Create trend and density columns -------------------------------------
states$tau <- map_create_trends(states, estimator = "tau")
states$slope <- map_create_trends(states, estimator = "slope")
map_tau(states)

# 4. Create a ggplot2
map_plotly_graph(states)
