library(dplyr)
library(kableExtra)
library(formattable)
library(crayon)

features <- c(
  "Image Clipping",
  "Cloud Masks",
  "Radiometric Correction",
  "Atmospheric Correction",
  "Pixel Alignment",
  "Sensor Alignment",
  "Products"
)
ARD <- c("CEOS", "Planet", "USGS")
table_q1 <- matrix(1, length(ARD), length(features))  %>% as.data.frame()
colnames(table_q1) <- features
rownames(table_q1) <- ARD

table_q1$"Image Clipping" <- c(1, 1, 1)
table_q1$"Cloud Masks" <- c(1, 1, 0)
table_q1$"Radiometric Correction" <- c(1, 1, 1)
table_q1$"Atmospheric Correction" <- c(1, 0, 1)
table_q1$"Pixel Alignment" <- c(1, 1, 0)
table_q1$"Sensor Alignment" <- c(1, 1, 1)
table_q1$"Products" <- c("-", "Planetscope, RapideEye and Skysat", "Landsat")

table_q1[table_q1 == 0] = cell_spec("x", color = "red", bold = T, align = "center")
table_q1[table_q1 == 1] = cell_spec("✓", color = "green", bold = T, align = "center")

kbl(table_q1, escape = F) %>% 
  kable_paper("hover", full_width = F) %>% 
  column_spec(5, width = "3cm")

