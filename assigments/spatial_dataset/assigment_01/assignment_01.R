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
  port = 5433
)

# 3. Create the table
# HINT: getSQL is a R function that permits us properly transform a sql file 
# into a character  
dbSendQuery(con, getSQL("E03_data.sql")) # Execute a query on the database

# 4. Send a query and retrieve results - I
dbGetQuery(con, "SELECT * FROM capitals_world;")

# 5. Send a query and retrieve results - II
dbGetQuery(con, "SELECT * FROM capitals_world ORDER BY population DESC;")

# 6. Send a query and retrieve results - II
dbGetQuery(con, "SELECT * FROM capitals_world ORDER BY population DESC LIMIT 20;")

# 7. Create a View
# %|% is a operator to concat characters
statement <- "CREATE VIEW capitals_tops_20 AS" %|%
  "SELECT * FROM capitals_world ORDER BY population DESC LIMIT 20;"
dbSendQuery(con, statement) # Execute a query on the database
# dbSendQuery(con, "DROP VIEW capitals_tops_20") # Execute a query on the database


# 8. Send a query and retrieve results - III
dbGetQuery(con, "SELECT * FROM capitals_tops_20;")


# 9. Updating a view
statement <- "UPDATE capitals_world" %|%
  "SET population = population + 300000" %|%
  "WHERE city = 'Singapore';"
dbSendQuery(con, statement) # Execute a query on the database

# 10. Send a query and retrieve results - IV
statement <- "SELECT AVG(population)" %|%
  "FROM capitals_world;" 
dbGetQuery(con, statement)

# 11. Send a query and retrieve results - V (WRONG)
statement <- "SELECT *" %|%
  "FROM capitals_world" %|%
  "WHERE population > AVG(population);"
dbGetQuery(con, statement)

# 12. Send a query and retrieve results - VI (Subquery)
statement <- "SELECT *" %|%
  "FROM capitals_world" %|%
  "WHERE population > (" %|%
  "  SELECT AVG(population)" %|%
  "  FROM capitals_world" %|%
  ");"
dbGetQuery(con, statement)

# 13. Send a query and retrieve results - VI (Subquery)
statement <- "SELECT *" %|%
  "FROM capitals_world" %|%
  "WHERE population > (" %|%
  "  SELECT AVG(population)" %|%
  "  FROM capitals_world" %|%
  ");"
dbGetQuery(con, statement)


# 14. Send a query and retrieve results - VII (Subquery)
statement <- "SELECT cap.*" %|%
  "FROM capitals_world as cap, (" %|%
  "  SELECT AVG(population) AS average_population" %|%
  "  FROM capitals_world) AS average" %|%
  "WHERE cap.population > average.average_population" %|% 
  ";"
dbGetQuery(con, statement)
