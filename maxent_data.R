###Code for Environmental Data and Formatting species data....
###NESCent workshop

###Three pounds for comments
#One pound for code

###Load libraries
rm(list=ls())
library(dismo)
library(rgdal)
library(maptools)
library(sp)
library(raster)
library(rJava)
#library(RCurl)

#############################################################################
### download all worldclim data
###Present

### Below is all of the data for 2.5 degree minute data (~4.5 km). If we want 30 sec (~1km), then we'll have to specify tiles with the species extent.

species_name = 'Dipteryx panamensis'

data_folder = '/home/jotegui/Desktop/NESCentBHLEOL/EOLBHL/data/'

### Present
setwd(paste(data_folder,"bioclim/wc2-5/wc2-5", sep="/"))

bioclim_P1<-("./bio1.bil")
raster(bioclim_P1)

bioclim_P2<-("./bio2.bil")
raster(bioclim_P2)

bioclim_P3<-("./bio3.bil")
raster(bioclim_P3)

bioclim_P4<-("./bio4.bil")
raster(bioclim_P4)

bioclim_P5<-("./bio5.bil")
raster(bioclim_P5)

bioclim_P6<-("./bio6.bil")
raster(bioclim_P6)

bioclim_P7<-("./bio7.bil")
raster(bioclim_P7)

bioclim_P12<-("./bio12.bil")
raster(bioclim_P12)

bioclim_P13<-("./bio13.bil")
raster(bioclim_P13)

bioclim_P14<-("./bio14.bil")
raster(bioclim_P14)

bioclim_P15<-("./bio15.bil")
raster(bioclim_P15)

bioclimP<-stack(bioclim_P1,bioclim_P2,bioclim_P3,bioclim_P4,bioclim_P5,bioclim_P6,bioclim_P7,bioclim_P12,bioclim_P13,bioclim_P14, bioclim_P15)
#plot(bioclimP)

###Future
setwd(paste(data_folder,"bioclim/future_bioclim", sep="/"))

#bioclimF <- stack("future_bioclim")

bioclim1<-("./cc26bi501.tif")
raster(bioclim1)

bioclim2<-("./cc26bi502.tif")
raster(bioclim2)

bioclim3<-("./cc26bi503.tif")
raster(bioclim3)

bioclim4<-("./cc26bi504.tif")
raster(bioclim4)

bioclim5<-("./cc26bi505.tif")
raster(bioclim5)

bioclim6<-("./cc26bi506.tif")
raster(bioclim6)

bioclim7<-("./cc26bi507.tif")
raster(bioclim7)

bioclim12<-("./cc26bi5012.tif")
raster(bioclim12)

bioclim13<-("./cc26bi5013.tif")
raster(bioclim13)

bioclim14<-("./cc26bi5014.tif")
raster(bioclim14)

bioclim15<-("./cc26bi5015.tif")
raster(bioclim15)

bioclimF<-stack(bioclim1,bioclim2,bioclim3,bioclim4,bioclim5,bioclim6,bioclim7,bioclim12,bioclim13,bioclim14,bioclim15)
#bioclimF<-brick(bioclim1,bioclim2,bioclim3,bioclim4,bioclim5,bioclim6,bioclim7,bioclim8,bioclim9,bioclim10,bioclim11,bioclim12,bioclim13,bioclim14, bioclim15, bioclim16, bioclim17, bioclim18,bioclim19)

#bioclimF<-brick(bioclimF)
#bioclimF
#writeRaster(bioclimF, filename="bioclimFuture")

#plot(bioclimF)

###Elevation (same in present and future)
#setwd("C:/Users/Nicole/Desktop/elevation")
setwd(paste(data_folder,"bioclim/elevation", sep="/"))
ele <- brick("./alt.bil")
#plot(ele)


#############################################################################
### Need a raster object or need to make a raster object from Gbif species extent
# dataSpp<-load(species raster) # No need for raster


### Need two columns of lat long pts for Gbif species 
setwd(paste(data_folder,"gbif", sep="/"))
species_file <- paste(sub(" ", "_", species_name),"csv", sep="_corrected.")
speciesPts <- read.csv(species_file)
speciesPts <- as.data.frame(cbind(speciesPts$latitude, speciesPts$longitude))
colnames(speciesPts) <- c("latitude", "longitude")
###Name columns for coordinates for each
coordinates(speciesPts)<-c("longitude", "latitude")
###Create Raster
speciesRaster = rasterize(speciesPts, raster())
#plot(speciesRaster)
#############################################################################
#### find extent of species. Project correctly.
###Find coord.ref of speciesRaster. If it matches bioclim, ok. If not, then use line below.
###No need, since already in WGS84
#species<- projectRaster(speciesRaster,crs="+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs")
#plot(speciesRaster)
#############################################################################
### Crop extent of species with worldclim data by forcing extent and size
### For PRESENT and FUTURE
### Warning: extent of speciesRaster is the same as bioclim*, so no resampling or cropping is done
#bioClimP_file<- crop(bioclimP, speciesRaster)
#bioClimF_file<- resample(bioclimF, speciesRaster)

#############################################################################
###  Extract bioclim variables in each point
bioClim_SpeciesP<- extract(bioclimP, speciesPts, method='bilinear', buffer=NULL, fun=NULL, df=TRUE)

#############################################################################
### Training and testing set of presence data:
groupP <- kfold(bioClim_SpeciesP, 5)
pres_trainP <- speciesPts[groupP !=1,]
pres_testP <- speciesPts[groupP ==1,]

###Background samples for training and testing
bgP <- randomPoints(bioclimP, n=1000)
colnames(bgP) <- c('longitude', 'latitude')
groupP <- kfold(bgP,5)
bg_trainP <-bg[groupP !=1,]
bg_testP <- bg[groupP ==1,]


#############################################################################
### Run Maxent
### For PRESENT
runP<- maxent(bioclimP, pres_trainP, a=bgP, removeDuplicates=TRUE, args=c("-J"))
###Evaluate?
#eRunP<-evaluate(pres_test, runP, bioclimP)
###Map?
pred_mapP <- predict(runP, bioclimP)
# 10.30 - 10.42
plot(pred_mapP)

### ...and FUTURE

#############################################################################
###  Extract bioclim variables in each point
bioClim_SpeciesF<- extract(bioclimF, speciesPts, method='bilinear', buffer=NULL, fun=NULL, df=TRUE)

#############################################################################
### Training and testing set of presence data:
groupF <- kfold(bioClim_SpeciesF, 5)
pres_trainF <- speciesPts[groupF !=1,]
pres_testF <- speciesPts[groupF ==1,]

###Background samples for training and testing
bgF <- randomPoints(bioclimF, n=1000)
colnames(bgF) <- c('longitude', 'latitude')
groupF <- kfold(bgF,5)
bg_trainF <-bg[groupF !=1,]
bg_testF <- bg[groupF ==1,]

#############################################################################
### Run Maxent
### For PRESENT
runF<- maxent(bioclimF, pres_trainF, a=bgF, removeDuplicates=TRUE, args=c("-J"))
###Evaluate?
#eRunF<-evaluate(pres_testF, runF, bioclimF)
###Map?
pred_mapF <- predict(runF, bioclimF)
# 10.30 - 10.42
plot(pred_mapF)
