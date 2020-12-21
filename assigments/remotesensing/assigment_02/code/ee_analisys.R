library(sf)
library(rgee)
ee_Initialize()

geoviz <- list(min = -25, max = 0, bands = c("VV","VH","VV/VH"))
images <- c(
  "S1B_IW_GRDH_1SDV_20170702T062605_20170702T062630_006305_00B160_6DA0",
  "S1B_IW_GRDH_1SDV_20170819T062608_20170819T062633_007005_00C576_066C"
)
full_id <- sprintf("COPERNICUS/S1_GRD/%s", images)



# 1. Compare SAR images before and after the fire
before_fire <- ee$Image(full_id[1])
bf_ratio <- before_fire$select("VV")$divide(before_fire$select("VH"))$rename("VV/VH")
before_fire <- before_fire$addBands(bf_ratio)

after_fire <- ee$Image(full_id[2])
af_ratio <- after_fire$select("VV")$divide(after_fire$select("VH"))$rename("VV/VH")
after_fire <- after_fire$addBands(af_ratio)


Map$setCenter(-6.63849, 37.70610, 11)
m1 <- Map$addLayer(before_fire, geoviz)
m2 <- Map$addLayer(after_fire, geoviz)
m1 | m2

# 2. Compare VH cross-pol of SAR images before and after
simple <- ee$Image$cat(
  before_fire$select("VH")$rename("VH_b"),
  after_fire$select("VH")$rename("VH_a")
)
Map$addLayer(simple, list(min = -25, max = -10))
