kindergarden <- "https://services.arcgis.com/Sf0q24s0oDKgX14j/ArcGIS/rest/services/Kindergarten/FeatureServer/0/query"
kindergarden_out <- "/home/csaybar/Documents/Github/digitalearth/assigments/spatial_analisys/assigment_01/data/kindergarden.shp"
motorway <- "https://services.arcgis.com/Sf0q24s0oDKgX14j/arcgis/rest/services/Motorway/FeatureServer/0/query"
motorway_out <- "/home/csaybar/Documents/Github/digitalearth/assigments/spatial_analisys/assigment_01/data/motorway.shp"
salzburg_city <- "https://services.arcgis.com/Sf0q24s0oDKgX14j/arcgis/rest/services/Outline%20Salzburg%20City/FeatureServer/0/query"
salzburg_city_out <- "/home/csaybar/Documents/Github/digitalearth/assigments/spatial_analisys/assigment_01/data/salzburg_city.shp"
system(sprintf("python3 download_AGOnline.py %s %s", kindergarden, kindergarden_out))
system(sprintf("python3 download_AGOnline.py %s %s", motorway, motorway_out))
system(sprintf("python3 download_AGOnline.py %s %s", salzburg_city, salzburg_city_out))
