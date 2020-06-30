rm(list = ls())
setwd("D:/Work/processing/ERA5land_fill/Results_Mean/")
library(data.table)
library(dplyr)

#####################
#Put together
#Paste together all years
list=2001:2015

#####################

###### FOR L1 #######

#####################
m=list()
#Convert vector into a string
jj=lapply(list, function(x) { toString(x) })
for(j in jj){
	#Extract daily raster to multiply it by the population weight
	df=fread(paste0("L1/L1_",j,".csv"))
	#df=df%>%dplyr::select("SALID1", "UXtemp_pw", "UXtemp_x", "date")
	print(paste0(j, ": ", nrow(df)))
	m[[j]] <- df
}

df_totals <-  (do.call(rbind,m))

s=list()
#Convert vector into a string
jj=lapply(list, function(x) { toString(x) })
for(j in jj){
	#Extract daily raster to multiply it by the population weight
	df=fread(paste0("L1/L1_",j,"_GUF.csv"))
	print(paste0(j, ": ", nrow(df)))
	s[[j]] <- df
}

df_final <-  (do.call(rbind,s))
head(df_final)
head(df_totals)
df_totals$V1=NULL

#Merge with previous file to replace wrong UXs
df1 <- left_join(df_totals,df_final, by = c("SALID1","date"))

head(df1)
df2=df1 %>%
	mutate(UXtemp_pw = ifelse(is.na(UXtemp_pw.y), UXtemp_pw.x, UXtemp_pw.y),
		   UXtemp_x = ifelse(is.na(UXtemp_x.y), UXtemp_x.x, UXtemp_x.y),
		   ADtemp_pw = ifelse(is.na(ADtemp_pw.y), ADtemp_pw.x, ADtemp_pw.y),
		   ADtemp_x = ifelse(is.na(ADtemp_x.y), ADtemp_x.x, ADtemp_x.y))

df2$UXtemp_pw.y=NULL
df2$UXtemp_pw.x=NULL
df2$UXtemp_x.y=NULL
df2$UXtemp_x.x=NULL
df2$ADtemp_pw.y=NULL
df2$ADtemp_pw.x=NULL
df2$ADtemp_x.y=NULL
df2$ADtemp_x.x=NULL
df2$V1.x=NULL
df2$V1.y=NULL

head(df2)

write.csv(df_totals, "L1/L1_ADUX_wp_2001_2015_v3.csv")
write.csv(df2, "L1/L1_ADUX_2001_2015_v3.csv")

#####################

###### FOR L2 #######

#####################
m=list()
#Convert vector into a string
jj=lapply(list, function(x) { toString(x) })
for(j in jj){
	#Extract daily raster to multiply it by the population weight
	df1=fread(paste0("L2/L2_",j,"_B1.csv"))
	df2=fread(paste0("L2/L2_",j,"_B2.csv"))
	df3=fread(paste0("L2/L2_",j,"_B3.csv"))
	df4=fread(paste0("L2/L2_",j,"_B4.csv"))
	df5=fread(paste0("L2/L2_",j,"_B5.csv"))
	df=rbind(df1,df2, df3, df4, df5)
	#df=df%>%dplyr::select("SALID1", "UXtemp_pw", "UXtemp_x", "date")
	print(paste0(j, ": ", nrow(df)))
	m[[j]] <- df
}

df_totals <-  (do.call(rbind,m))
df_totals$V1=NULL
head(df_totals)

s=list()
#Convert vector into a string
jj=lapply(list, function(x) { toString(x) })
for(j in jj){
	#Extract daily raster to multiply it by the population weight
	df1=fread(paste0("L2/L2_",j,"_B1.csv"))
	df2=fread(paste0("L2/L2_",j,"_B2.csv"))
	df3=fread(paste0("L2/L2_",j,"_B3.csv"))
	df4=fread(paste0("L2/L2_",j,"_GUF.csv"))
	df5=fread(paste0("L2/L2_",j,"_B5.csv"))
	df=rbind(df1,df2, df3, df4, df5)
	print(paste0(j, ": ", nrow(df)))
	s[[j]] <- df
}

df_final <-  (do.call(rbind,s))
df_final$V1=NULL
head(df_final)
head(df_totals)


#Merge with previous file to replace wrong UXs
df1_L2 <- left_join(df_totals,df_final, by = c("SALID2","date"))

head(df1_L2)
df2_L2=df1_L2 %>%
	mutate(L2temp_pw = ifelse(is.na(L2temp_pw.y), L2temp_pw.x, L2temp_pw.y),
		   L2temp_x = ifelse(is.na(L2temp_x.y), L2temp_x.x, L2temp_x.y))

head(df2_L2)

df2_L2$L2temp_pw.y=NULL
df2_L2$L2temp_pw.x=NULL
df2_L2$L2temp_x.y=NULL
df2_L2$L2temp_x.x=NULL

head(df2_L2)
head(df_totals)

write.csv(df_totals, "L2/L2_wp_2001_2015_v3.csv")
write.csv(df2_L2, "L2/L2_2001_2015_v3.csv")

#####################
