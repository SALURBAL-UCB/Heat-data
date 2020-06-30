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

BB <- read_sf("L2_/level2_gcs_modify4.shp")
BB <- BB%>%dplyr::filter(Country=="Mexico")

# Find "results Yang" in Google Drive
# temp <- raster("results_yang/2010_Q1.nc", varname='t2m')
# wpop=read_sf("worldpoppers_bueno_convec.shp")
# rt <- fasterize(wpop, temp, field = "sum", fun="sum")
# 
# out_s<- (velox(rt))$extract(sp = as_Spatial(BB), small=T)
# sum_out <- (velox(rt))$extract(sp= as_Spatial(BB), small=T, fun = function(x) sum(x, na.rm = TRUE))
# result = mapply(FUN = `/`, lapply(out_s, function(x) { x } ),sum_out, SIMPLIFY = FALSE)
# save.image(file='pw_L2_3_leap.RData') 

load('pw_L2_3_leap.RData')
each_year_L2B3_leap=function(year){
  grids=c((paste0(year,"_Q1.nc")), (paste0(year,"_Q2.nc")),(paste0(year,"_Q3.nc")), (paste0(year,"_Q4.nc")))
  s <- stack(paste0("./results_yang/", grids))
  
  m=list()
  for(j in 1:366){
    #Extract daily raster to multiply it by the population weight
    out2<- (velox(s[[j]]))$extract(sp = as_Spatial(BB), small=T)
    result_f = mapply(FUN = `*`, result, out2, SIMPLIFY = FALSE)
    
    
    df2 <- data.frame(SALID2=BB$SALID2, SUM=unlist(lapply(result_f, sum,  na.rm=TRUE))-273.15,
                      mean=unlist(lapply(out2, mean, na.rm=TRUE))-273.15, j)
    
    m[[j]] <- df2
  }
  
  df_total <-  (do.call(rbind,m))
  
  values = seq(from = as.Date(paste0(year,"-01-01")), to = as.Date(paste0(year,"-12-31")), by = 'day')
  vv=as.data.frame(rep(values, each=406))
  colnames(vv)="date"
  dff=cbind(df_total,vv)
  
  colnames(dff)=c("SALID2","L2temp_pw","L2temp_x","time","date")
  
  dff=dff[-4]
  print(year)
  write.csv(dff,paste0("final_results/L2/L2_",year,"_B3.csv"))
  
}

start_time <- Sys.time()
each_year_L2B3_leap("2004")
each_year_L2B3_leap("2008")
each_year_L2B3_leap("2012")
end_time <- Sys.time()
end_time - start_time


#For years that are not leap


each_year_L2B3_1=function(year){
  grids=c((paste0(year,"_Q1.nc")), (paste0(year,"_Q2.nc")),(paste0(year,"_Q3.nc")), (paste0(year,"_Q4.nc")))
  s <- stack(paste0("./2001_Q/", grids))
  
  m=list()
  for(j in 1:365){
    #Extract daily raster to multiply it by the population weight
    out2<- (velox(s[[j]]))$extract(sp = as_Spatial(BB), small=T)
    result_f = mapply(FUN = `*`, result, out2, SIMPLIFY = FALSE)
    
    
    df2 <- data.frame(SALID2=BB$SALID2, SUM=unlist(lapply(result_f, sum,  na.rm=TRUE))-273.15,
                      mean=unlist(lapply(out2, mean, na.rm=TRUE))-273.15, j)
    
    m[[j]] <- df2
  }
  
  df_total <-  (do.call(rbind,m))
  
  values = seq(from = as.Date(paste0(year,"-01-01")), to = as.Date(paste0(year,"-12-31")), by = 'day')
  vv=as.data.frame(rep(values, each=406))
  colnames(vv)="date"
  dff=cbind(df_total,vv)
  
  colnames(dff)=c("SALID2","L2temp_pw","L2temp_x","time","date")
  
  dff=dff[-4]
  print(year)
  write.csv(dff,paste0("final_results/L2/L2_",year,"_B3.csv"))
  
}

start_time <- Sys.time()
each_year_L2B3_1("2001")
each_year_L2B3_1("2002")
each_year_L2B3_1("2003")
each_year_L2B3_1("2005")
each_year_L2B3_1("2006")
each_year_L2B3_1("2007")
each_year_L2B3_1("2009")
each_year_L2B3_1("2010")
each_year_L2B3_1("2011")
each_year_L2B3_1("2013")
each_year_L2B3_1("2014")
each_year_L2B3_1("2015")
end_time <- Sys.time()
end_time - start_time

