library("RPostgreSQL")
library("sf")
library("DBI")
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

# DBI::dbListTables(con)

# 3. Save shapefiles in PostGIS
# files_in <- list.files("data/","\\.shp$",full.names = TRUE)
# tables_names <- c("salzburg_buildings", "salzburg_districts", "salzburg_roads")
# for (index in seq_along(tables_names)) {
#   st_write(read_sf(files_in[index]), dsn = con, layer = tables_names[index]
#            , append = FALSE)
# }

# 4. Repeat the query with all buildings, which are of type church and then repeat 
#    the query to create a layer, which contains churches and schools.
query_01_01 <- "SELECT r.*, ST_Length(geometry) as length FROM salzburg_roads as r;"
slzg_church <- st_read(con, query = query_01_01)
plot(slzg_church$geometry)


query_01_02 <-
"SELECT r.*," %|%
  "CASE" %|% 
  "  WHEN ST_Length(geometry) <= 15 THEN 'very small'" %|%
  "  WHEN ST_Length(geometry) > 15 AND ST_Length(geometry) <= 40 THEN 'small'" %|% 
  "  WHEN ST_Length(geometry) > 40 AND ST_Length(geometry) <= 80 THEN 'medium'" %|% 
  "  WHEN ST_Length(geometry) > 80 AND ST_Length(geometry) <= 150 THEN 'large'" %|% 
  "  WHEN ST_Length(geometry) > 150 THEN 'very large'" %|% 
  "END AS road_category" %|%
"FROM" %|%
  " salzburg_roads AS r;"
slzg_cs <- st_read(con, query = query_01_02)

# 5. Extend the query and add a column that contains the calculated
#    area of the houses.
query_02_01 <- "SELECT * FROM salzburg_roads" %|%
  " WHERE fclass = 'motorway' OR fclass = 'motorway_link';"
slzg_area_school <- st_read(con, query = query_02_01)

query_02_02 <- "SELECT b.*, ST_Distance(m.geometry, b.geometry) as distance" %|%
  " FROM salzburg_buildings as b," %|%
  "  (SELECT ST_Union(geometry) as geometry" %|%
  "   FROM salzburg_roads" %|%
  "   WHERE fclass = 'motorway' OR fclass = 'motorway_link') as m;"
slzg_distance <- st_read(con, query = query_02_02)



query_03_01 <- "SELECT" %|% 
"  b.*" %|%   
"FROM" %|%
"  salzburg_buildings AS b," %|%
"  ( SELECT" %|%
"      ST_Buffer(ST_Union(r.geometry), 20, 'endcap=flat') AS buffer" %|%
"    FROM " %|%
"      salzburg_roads AS r) AS n" %|%
"WHERE" %|% 
"  ST_Intersects(n.buffer, b.geometry) IS FALSE"
slzg_distance <- st_read(con, query = query_03_01)


queryx <-
"SELECT" %|% 
"  r.*," %|% 
"  ST_Buffer(r.geometry, 20, 'endcap=flat') AS potential_noise" %|% 
"FROM" %|% 
"  salzburg_roads AS r;"
slzg_distance <- st_read(con, query = queryx)

query_03_02 <- 
  "SELECT" %|% 
  "  ST_Buffer(ST_Union(r.geometry), 20, 'endcap=flat') AS buffer" %|% 
  "INTO  potential_noise" %|%
  "FROM " %|%
  "  salzburg_roads AS r;"
slzg_distance <- st_read(con, query = query_03_02)


query_03_03 <- 
  "SELECT b.*" %|% 
  "FROM" %|% 
  " salzburg_buildings AS b," %|% 
  " potential_noise AS n" %|%
  "WHERE " %|%
  "  ST_Intersects(n.buffer, b.geometry) IS FALSE;"
slzg_distance <- st_read(con, query = query_03_03)
