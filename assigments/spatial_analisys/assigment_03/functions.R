create_meuse <- function() {
  data("meuse")
  coordinates(meuse) <- ~x + y
  suppressWarnings(
    crs(meuse) <- "+init=epsg:28992"
  )
  meuse
}

create_meusegrid <- function() {
  data("meuse.grid")
  coordinates(meuse.grid) <- ~x + y
  suppressWarnings(
    crs(meuse.grid) <- "+init=epsg:28992"
  )
  meuse.grid
}

fit_variog <- function() {
  meuse <- create_meuse()
  meusegrid <- create_meusegrid()
  lzn_vgm <- variogram(log(zinc)~1, meuse)
  lzn_fit <- fit.variogram(lzn_vgm, model = vgm(1, "Sph", 900, 1))
  list(exp = lzn_vgm, theo = lzn_fit)
}

zinc_kriging <- function() {
  meuse <- create_meuse()
  meusegrid <- create_meusegrid()
  lzn_vgm <- variogram(log(zinc)~1, meuse)
  lzn_fit <- fit.variogram(lzn_vgm, model = vgm(1, "Sph", 900, 1))
  lzn.kriged <- krige(log(zinc)~1, meuse, meusegrid, model = lzn_fit, debug.level	= 0)
  gridded(lzn.kriged) <- TRUE
  lzn.kriged_r <- stack(lzn.kriged)
  lzn.kriged_r
}


zinc_kriging_cv <- function() {
  meuse <- create_meuse()
  lzn_vgm <- variogram(log(zinc)~1, meuse)
  lzn_fit <- fit.variogram(lzn_vgm, model = vgm(1, "Sph", 900, 1))
  lzn.kriged <- krige.cv(log(zinc)~1, meuse, nfold = 5, debug.level	= 0)
  crs(lzn.kriged) <- crs(meuse)
  lzn.kriged
}


zinc_kriging_cv_npoints <- function() {
  meuse <- create_meuse()
  n_points <- c(25, 50,75,100,125,155)
  rmse_values_boostrap <- NULL
  for (variable in 1:10) {
    rmse_values <- NULL
    for (n_point in n_points) {
      meuse_sample <- meuse[sample(nrow(meuse),n_point),]
      lzn_vgm <- variogram(log(zinc)~1, meuse_sample)
      lzn_fit <- fit.variogram(lzn_vgm, model = vgm(1, "Sph", 900, 1))
      lzn.kriged <- krige.cv(log(zinc)~1, meuse_sample, nfold = 5, verbose	= 0)
      crs(lzn.kriged) <- crs(meuse)
      rmse_values <- append(rmse_values, mean(lzn.kriged$residual**2))
    }
    rmse_values_boostrap <- rbind(rmse_values_boostrap, rmse_values)
  }
  final_values <- apply(rmse_values_boostrap,2,mean)
  data.frame(npoints = n_points, error = final_values)
}



zinc_dranges <- function() {
  meuse <- create_meuse()
  meusegrid <- create_meusegrid()
  
  lzn_vgm <- variogram(log(zinc)~1, meuse)
  lzn_fit <- fit.variogram(lzn_vgm, model = vgm(1, "Sph", 900, 1))
  range_values <- c(200, 400, 600, 800, 1000, 1200)
  lzn.kriged_stack <- list()
  index <- 0
  for (range_value in range_values) {
    index <- index + 1
    lzn_fit$range <- c(0, range_value)
    lzn.kriged <- krige(log(zinc)~1, meuse, meusegrid, model = lzn_fit, debug.level	= 0)[1]
    gridded(lzn.kriged) <- TRUE
    lzn.kriged_r <- raster(lzn.kriged)
    lzn.kriged_stack[[index]] <- lzn.kriged_r 
  }
  interp_dranges <- stack(lzn.kriged_stack)
  names(interp_dranges) <- sprintf("zinc_%s.tif", range_values)
  interp_dranges
}




