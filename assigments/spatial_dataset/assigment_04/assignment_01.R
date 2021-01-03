library("sf")
library("RPostgreSQL")
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
# files_in <- list.files("data/","\\.shp$",full.names = TRUE)
# tables_names <- c("salzburg_buildings", "salzburg_districts", "salzburg_roads")
# for (index in seq_along(tables_names)) {
#   sf_f <- read_sf(files_in[index])
#   sf_f$id <- seq_along(nrow(sf_f)) 
#   st_write(sf_f, dsn = con, layer = tables_names[index]
#            , append = FALSE)
# }
# salzburg_buildings <- st_read(con, query = "SELECT * FROM salzburg_buildings;")


# 4. Alter the database schema
# HINT: getSQL is a R function that permits us properly transform a sql file 
# into a character  
dbSendQuery(con, getSQL("E10-db-change.sql")) # Execute a query on the database

user_01 <- "CREATE ROLE carto_csa LOGIN PASSWORD 'map';"
user_02 <- "CREATE ROLE inter_csa LOGIN PASSWORD 'intern' VALID UNTIL '2021-03-01';"

dbSendQuery(con, user_01)
dbSendQuery(con, user_02)


user_01_01 <- "GRANT SELECT ON salzburg_buildings TO carto_csa;"
dbSendQuery(con, user_01_01)


query_01 <- 
"CREATE OR REPLACE VIEW intern_view AS" %|% 
  "SELECT"  %|% 
  "b.id," %|% 
  "b.name," %|% 
  "b.geometry," %|% 
  "b.osm_id," %|% 
  "b.code," %|% 
  "b.fclass," %|% 
  "b.type" %|% 
"FROM" %|%
"salzburg_buildings AS b;"

dbSendQuery(con, query_01)


query_02 <- 
"CREATE OR REPLACE VIEW intern_view AS" %|%
  "SELECT" %|%
    "b.id," %|%
    "b.name," %|%
    "b.geometry," %|%
    "b.osm_id," %|%
    "b.code," %|%
    "b.fclass," %|%
    "b.type" %|%
  "FROM" %|%
    "salzburg_buildings AS b," %|%
    "(SELECT geom FROM security_geofence WHERE project = 'intern') AS i" %|%
  "WHERE" %|%
    "st_intersects(ST_SetSRID(b.geometry,32633), i.geom);"

query_03 <- "GRANT SELECT ON intern_view TO inter_csa;"
dbSendQuery(con, query_02)
dbSendQuery(con, query_03)



salzburg_buildings <- st_read(con, query = "SELECT * FROM intern_view;")
plot(salzburg_buildings["type"])



query_04 <- 
  "CREATE OR REPLACE VIEW intern_neq_view AS" %|%
  "SELECT" %|%
  "b.id," %|%
  "b.name," %|%
  "b.security_level," %|%
  "b.geometry," %|%
  "b.osm_id," %|%
  "b.code," %|%
  "b.fclass," %|%
  "b.type" %|%
  "FROM" %|%
  "salzburg_buildings AS b," %|%
  "(SELECT geom FROM security_geofence WHERE project = 'intern') AS i" %|%
  "WHERE" %|%
  "st_intersects(ST_SetSRID(b.geometry,32633), i.geom);"

query_05 <- "GRANT SELECT ON intern_neq_view TO inter_csa;"
dbSendQuery(con, query_04)
dbSendQuery(con, query_05)
