# Tableu dashboard project!

# My questions:
# 1. How much the system growth?
# 2. What are the most popular destination station?
# 3. What is the most recurrent travel?

library(tidyverse)
library(corrplot)
library(mapview)
library(raster)
library(sf)
library(sp)
source("scripts/functions.R")



# 1. Download data
download_data()
all_csvs <- list.files("data_trip/", "\\.csv$", full.names = TRUE)
read_files <- lapply(all_csvs, read_csv) 
read_files <- lapply(read_files[1:60], change_type)
final_db <- bind_rows(read_files[1:60])

# QUESTION n01: How much the system growth?
# ----------------------------------------------

number_of_trips <- sapply(seq_along(all_csvs), ntrip_fx)
dates <- as.Date(paste0(gsub("-.*|_.*", "", basename(all_csvs)),"01"), format = "%Y%m%d")
df_final_q1 <- data_frame(date = dates, trips = number_of_trips)
write_csv(df_final_q1, "results/question_01.csv")

# QUESTION n02: How much the system growth?
# ----------------------------------------------

final_db_subset <- final_db[c("end station name", "end station latitude", "start station longitude")]
colnames(final_db_subset) <- c("name", "y", "x")
final_db_subset <- final_db_subset[c("name", "x", "y")] 
final_db_subset_q2 <- final_db_subset %>%
  group_by(name) %>% 
  summarise_all(mean)
final_db_subset_q2$values <- as.numeric(table(final_db_subset$name))
question_02 <- final_db_subset_q2[-3,]
write_csv(question_02, "results/question_02.csv")

# coordinates(question_02) <- ~x+y
# final_db_subset_q2 <- st_as_sf(question_02)
# st_crs(final_db_subset_q2) <- 4326
# mapview(final_db_subset_q2, zcol = "values")

# QUESTION n03: What is the most recurrent travel?
# ----------------------------------------------
select_names <- final_db[c("start station name", "end station name")] %>% 
  count(`start station name`, `end station name`) %>% 
  arrange(desc(n)) %>% 
  '['(1:100, 'start station name') %>% 
  '[['(1)

question_03 <- final_db[final_db$"start station name" %in% select_names & final_db$"end station name" %in% select_names,] %>% 
  '['(c("start station name", "end station name")) %>% 
  count(`start station name`, `end station name`) %>% 
  arrange(desc(n)) 
write_csv(question_03, "results/question_03.csv")
  
