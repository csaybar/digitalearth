download_data <- function(path = ".") {
  seq_month <- seq(as.Date("2015-01-01"), as.Date("2020-11-01"), "month") %>% format("%Y%m")
  tripdata1 <- sprintf("https://s3.amazonaws.com/hubway-data/%s-hubway-tripdata.zip", seq_month[1:40])
  tripdata2 <- sprintf("https://s3.amazonaws.com/hubway-data/%s-bluebikes-tripdata.zip", seq_month[41:length(seq_month)])
  to_downloads <- c(tripdata1, tripdata2)
  folder_path_name <- sprintf("%s/data_trip", path)
  dir.create(folder_path_name, showWarnings = FALSE)
  
  for (to_download in to_downloads) {
    folder_path_file <- sprintf("%s/%s", folder_path_name, basename(to_download))
    download.file(
      url = to_download,
      destfile = folder_path_file
    )
    unzip(folder_path_file, exdir = dirname(folder_path_file))
  }
  lapply(list.files(folder_path_name, "\\.zip$", full.names = TRUE), file.remove)
  TRUE
}

ntrip_fx <- function(x) read_csv(all_csvs[x]) %>% nrow()
change_type <- function(x) {
  x$`birth year` <- as.numeric(x$`birth year`)
}                                                                    
