#.rs.restartR()
#rm(list = ls())
setwd('~/Downloads')
  
library(raster)
library(sf)
library(fasterize)
library(sp)
library(maptools)
library(rgdal)
library(data.table)
library(velox)

# Find "results Yang" in Google Drive
#GUF
# BB <- read_sf("L2_/level2_gcs_modify4.shp")
# BB_PANPERU <- BB%>%dplyr::filter(Country=="Peru"| Country=="Panama")
# gufy=sf::read_sf("guf_panperu_vectorized_complete.shp")
# temp <- raster("results_yang/2010_Q1.nc", varname='t2m')
# rt_guf <- fasterize(gufy, temp, field = "sum", fun="sum")

# out_guf <- (velox(rt_guf))$extract(sp=as_Spatial(BB_PANPERU), small=T)
# sum_out <- (velox(rt_guf))$extract(sp= as_Spatial(BB_PANPERU), small=T, fun = function(x) sum(x, na.rm = TRUE))
# result_guf = mapply(FUN = `/`, lapply(out_guf, function(x) { x } ),sum_out, SIMPLIFY = FALSE)

# save.image(file='pw_L2_guf.RData') 


load('pw_L2_guf.RData')
each_year_L2_GUF=function(year){
  grids=c((paste0(year,"_Q1.nc")), (paste0(year,"_Q2.nc")),(paste0(year,"_Q3.nc")), (paste0(year,"_Q4.nc")))
  s <- stack(paste0("./results_yang/", grids))
  
  #save.image(file='pw.RData')
  
  # 4. Loop to multiple by daily temperature
  k=list()
  #Change to 366 in leap years: 2004, 2008
  for(j in 1:365){
    #Extract daily raster to multiply it by the population weight
    #GUF
    out2_guf<- (velox(s[[j]]))$extract(sp = as_Spatial(BB_PANPERU), small=T)
    result_f_guf = mapply(FUN = `*`, result_guf, out2_guf, SIMPLIFY = FALSE)
    
    df2_guf <- data.frame(SALID2=BB_PANPERU$SALID2, SUM=unlist(lapply(result_f_guf, sum, na.rm=TRUE))-273.15,
                          mean=unlist(lapply(out2_guf, mean, na.rm=TRUE))-273.15, j)
    
    #Because Missing GUF data at 0512111 10510918 10511012 10511343 10511119 10511110 20610321, use unweighted mean
    df2_guf$SUM <- ifelse((df2_guf$SUM)<(-273), df2_guf$mean, df2_guf$SUM)
    
    k[[j]] <- df2_guf
    
    
  }
  
  df_total_guf <-  (do.call(rbind,k))
  
  values = seq(from = as.Date(paste0(year,"-01-01")), to = as.Date(paste0(year,"-12-31")), by = 'day')
  vv_guf=as.data.frame(rep(values, each=251))
  colnames(vv_guf)="date"
  dff_guf=cbind(df_total_guf,vv_guf)
  
  
  colnames(dff_guf)=c("SALID2","L2temp_pw","L2temp_x","time","date")
  
  dff_guf=dff_guf[-4]
  print(year)
  write.csv(dff_guf,paste0("final_results/L2/L2_",year,"_GUF.csv"))
  
}

start_time <- Sys.time()
each_year_L2_GUF("2001")
each_year_L2_GUF("2002")
each_year_L2_GUF("2003")
each_year_L2_GUF("2005")
each_year_L2_GUF("2006")
each_year_L2_GUF("2007")
each_year_L2_GUF("2009")
each_year_L2_GUF("2010")
each_year_L2_GUF("2011")
each_year_L2_GUF("2012")
each_year_L2_GUF("2013")
each_year_L2_GUF("2014")
each_year_L2_GUF("2015")
end_time <- Sys.time()
end_time - start_time


