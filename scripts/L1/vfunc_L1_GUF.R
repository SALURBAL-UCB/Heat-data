#.rs.restartR()
#rm(list = ls())
library(raster)
library(sf)
library(fasterize)
library(sp)
library(maptools)
library(rgdal)
library(data.table)
library(velox)
library(ncdf4)

setwd("D:/Work/processing/ERA5land_fill/Results_Mean/")

# Find "results Yang" in Google Drive
# temp <- raster("Results_v2/2010_Q1.nc", varname='t2m')
# wpop=read_sf("worldpoppers_bueno_convec.shp")
# BB <- read_sf("level1_gcs_modify3.shp")
# UX <- read_sf("level1_gcs_ux_modify4_20191127.shp")

# rt <- fasterize(wpop, temp, field = "sum", fun="sum")
# out_s<- (velox(rt))$extract(sp = as_Spatial(BB), small=T)
# sum_out <- (velox(rt))$extract(sp= as_Spatial(BB), small=T, fun = function(x) sum(x, na.rm = TRUE))
# result = mapply(FUN = `/`, lapply(out_s, function(x) { x } ),sum_out, SIMPLIFY = FALSE)

# out_s_UX<- (velox(rt))$extract(sp = as_Spatial(UX), small=T)
# sum_out_UX <- (velox(rt))$extract(sp= as_Spatial(UX), small=T, fun = function(x) sum(x, na.rm = TRUE))
# result_UX = mapply(FUN = `/`, lapply(out_s_UX, function(x) { x } ),sum_out_UX, SIMPLIFY = FALSE)
# save.image(file='pw_L1_leap.RData') 

load('pw_L1_guf.RData')
each_year_L1=function(year){
	start_time <- Sys.time()
	grids=c((paste0(year,"_Q1.nc")), (paste0(year,"_Q2.nc")),(paste0(year,"_Q3.nc")), (paste0(year,"_Q4.nc")))
	s <- stack(paste0("../Results_v2/", grids))
	
	#save.image(file='pw.RData')
	
	# 4. Loop to multiple by daily temperature
	k=list()
	#Change to 366 in leap years: 2004, 2008
	for(j in 1:365){
		#Extract daily raster to multiply it by the population weight
		out2_guf<- (velox(s[[j]]))$extract(sp = as_Spatial(BB_PANPERU), small=T)
		result_f_guf = mapply(FUN = `*`, result_guf, out2_guf, SIMPLIFY = FALSE)
		
		out2_guf_UX <- (velox(s[[j]]))$extract(sp = as_Spatial(UX_PANPERU), small=T)
		result_f_guf_UX = mapply(FUN = `*`, result_guf_UX, out2_guf_UX, SIMPLIFY = FALSE)
		

		df2_guf <- data.frame(SALID1=BB_PANPERU$SALID1, SUM=unlist(lapply(result_f_guf, sum, na.rm=TRUE))-273.15,
							  mean=unlist(lapply(out2_guf, mean, na.rm=TRUE))-273.15, j)
		
		df3_guf <- data.frame(SALID1=UX_PANPERU$SALID1, SUM_UX=unlist(lapply(result_f_guf_UX, sum, na.rm=T))-273.15,
							  mean_UX=unlist(lapply(out2_guf_UX, mean, na.rm=TRUE))-273.15, j)
		df4_guf=merge(df2_guf, df3_guf, by="SALID1")
		
		k[[j]] <- df4_guf
		
	}
	
	df_total <-  (do.call(rbind,k))
	end_time <- Sys.time()
	print(end_time - start_time)
	values = seq(from = as.Date(paste0(year,"-01-01")), to = as.Date(paste0(year,"-12-31")), by = 'day')
	vv=as.data.frame(rep(values, each=26))
	colnames(vv)="date"
	
	dff=cbind(df_total,vv)
	colnames(dff)=c("SALID1","ADtemp_pw","ADtemp_x","time1",
					"UXtemp_pw","UXtemp_x","time","date")
	
	dff=dff[-4]
	dff=dff[-6]
	print(year)
	
	write.csv(dff,paste0("L1/L1_",year,"_GUF.csv"))
	
}

start_time <- Sys.time()
each_year_L1("2001")
each_year_L1("2002")
each_year_L1("2003")
each_year_L1("2005")
each_year_L1("2006")
each_year_L1("2007")
each_year_L1("2009")
each_year_L1("2010")
each_year_L1("2011")
each_year_L1("2013")
each_year_L1("2014")
each_year_L1("2015")
end_time <- Sys.time()
print(end_time - start_time)
