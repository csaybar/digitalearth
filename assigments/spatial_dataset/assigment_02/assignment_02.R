library("RPostgreSQL")
library("sf")
source("../postgis/utils.R") # Utils to use POSTGIS with R!

# 1. load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# 2. create a connection to the postgres database
con <- RPostgreSQL::dbConnect(
  drv = drv, 
  dbname = "spdb_course",
  host = "localhost", 
  user = "csaybar", 
  password = "csaybar",
  port = 5432
)

# 3. Save shapefiles in PostGIS
files_in <- list.files("data/","\\.shp$",full.names = TRUE)
tables_names <- c("salzburg_buildings", "salzburg_districts", "salzburg_roads")
for (index in seq_along(tables_names)) {
  st_write(read_sf(files_in[index]), dsn = con, layer = tables_names[index]
           , append = FALSE)
}

# 4. Repeat the query with all buildings, which are of type church and then repeat 
#    the query to create a layer, which contains churches and schools.
query_01_01 <- "SELECT * FROM salzburg_buildings WHERE type='church';"
slzg_church <- st_read(con, query = query_01_01)

query_01_02 <- "SELECT * FROM salzburg_buildings WHERE type='church' OR type='school';"
slzg_cs <- st_read(con, query = query_01_02)

# 5. Extend the query and add a column that contains the calculated
#    area of the houses.
query_02_01 <- "SELECT b.*, ST_Area(b.geometry) as area" %|%
  " FROM salzburg_buildings AS b WHERE type='school';"
slzg_area_school <- st_read(con, query = query_02_01)

query_02_02 <- "SELECT b.*, ST_Distance(b.geometry, g.geometry) as distance" %|%
  " FROM salzburg_buildings as b," %|%
  " (SELECT geometry FROM salzburg_buildings WHERE name = 'Glockenturm') as g;"
slzg_distance <- st_read(con, query = query_02_02)
plot(slzg_distance["distance"], main = "",
     lwd=0.1, key.pos = NULL, reset = FALSE,
     pal = viridis::viridis)

query_02_03 <- "SELECT COUNT(b.*)" %|%
  "FROM salzburg_buildings AS b," %|%
  "(SELECT geometry FROM salzburg_buildings WHERE name = 'Glockenturm') AS g" %|%
  "WHERE ST_Distance(b.geometry, g.geometry) < 500;"
slzg_df <- st_read(con, query = query_02_03)
slzg_df$count

# 6. Of course it is also possible to combine spatial operations and filters. What is
#    the average size of all buildings, which are within 1km distance to the fortress
#    (including the fortress itself)? Make a screenshot, which shows the query and
#    the result. and explain in your own words how the query works.
query_03_01 <- "SELECT AVG(ST_Area(b.geometry))" %|%
  "FROM salzburg_buildings AS b," %|%
  "(SELECT geometry FROM salzburg_buildings WHERE name = 'Glockenturm') AS g" %|%
  "WHERE ST_Distance(b.geometry, g.geometry) < 1000;"
slzg_df_avg <- st_read(con, query = query_03_01)
slzg_df_avg$avg


