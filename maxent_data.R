###Code for Environmental Data and Formatting species data....
###NESCent workshop

###Three pounds for comments
#One pound for code

###Load libraries
#library(dismo)
#library(rgdal)
#library(maptools)
#library(sp)
#library(raster)

#############################################################################
### download all worldclim data
###Present

### Below is all of the data for 2.5 degree minute data (~4.5 km). If we want 30 sec (~1km), then we'll have to specify tiles with the species extent.

setwd("C:/Users/Nicole/Desktop/wc2-5")
bioclimP <- brick("wc2-5.grd")
plot(bioclimP)

###Future
setwd("C:/Users/Nicole/Desktop/future_bioclim")
bioclimF <- stack("future_bioclim")

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

bioclim8<-("./cc26bi508.tif")
raster(bioclim8)

bioclim9<-("./cc26bi509.tif")
raster(bioclim9)

bioclim10<-("./cc26bi5010.tif")
raster(bioclim10)

bioclim11<-("./cc26bi5011.tif")
raster(bioclim11)

bioclim12<-("./cc26bi5012.tif")
raster(bioclim12)

bioclim13<-("./cc26bi5013.tif")
raster(bioclim13)

bioclim14<-("./cc26bi5014.tif")
raster(bioclim14)

bioclim15<-("./cc26bi5015.tif")
raster(bioclim15)

bioclim16<-("./cc26bi5016.tif")
raster(bioclim16)

bioclim17<-("./cc26bi5017.tif")
raster(bioclim17)

bioclim18<-("./cc26bi5018.tif")
raster(bioclim18)

bioclim19<-("./cc26bi5019.tif")
raster(bioclim19)

bioclimF<-stack(bioclim1,bioclim2,bioclim3,bioclim4,bioclim5,bioclim6,bioclim7,bioclim8,bioclim9,bioclim10,bioclim11,bioclim12,bioclim13,bioclim14, bioclim15, bioclim16, bioclim17, bioclim18,bioclim19)
bioclimF<-brick(bioclim1,bioclim2,bioclim3,bioclim4,bioclim5,bioclim6,bioclim7,bioclim8,bioclim9,bioclim10,bioclim11,bioclim12,bioclim13,bioclim14, bioclim15, bioclim16, bioclim17, bioclim18,bioclim19)

bioclimF<-brick(bioclimF)
bioclimF
writeRaster(bioclimF, filename="bioclimFuture")

plot(bioclimF)

###Elevation (same in present and future)
setwd("C:/Users/Nicole/Desktop/elevation")
ele <- brick("./alt.bil")
plot(ele)


#############################################################################
### Need a raster object or need to make a raster object from Gbif species extent
# dataSpp<-load(species raster)
#speciesRaster <- raster("") 

### Need two columns of lat long pts for Gbif species 

###Name columns for coordinates for each
#coordinates(speciesPts)<-c("lon", "lat")

#############################################################################
#### find extent of species. Project correctly.
#Find coord.ref of speciesRaster. If it matches bioclim, ok. If not, then use line below.
#species<- projectRaster(speciesRaster,crs="+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs")

#############################################################################
### Crop extent of species with worldclim data by forcing extent and size
### For PRESENT and FUTURE
# bioClimP_file<- resample(bioclimP, speciesRaster)
# bioClimF_file<- resample(bioclimF, speciesRaster)

#############################################################################
###  Extract points for each species
#bioClim_Species<- extract(bioClimP_file, speciesPts, method='bilinear', buffer=NULL, fun=NULL, df=TRUE)

#############################################################################
### Training and testing set of presence data:
#group <- kfold(speciesPts, 5)
#pres_train <- speciesPts[group !=1,]
#pres_test <- speciesPts[group ==1,]

###Background samples for training and testing
#bg <- randomPoints(bioClimP_file, n=1000, ext=e)
#colnames(bg) <- c('lon', 'lat')
#group <- kfold(bg,5)
#bg_train <-bg[group !=1,]
#bg_test <- bg[group ==1,]


#############################################################################
### Run Maxent
### For PRESENT and FUTURE
#runP<- maxent(bioclimP, pres_train, a=bg, removeDuplicates=TRUE, args=c("-J"))
###Evaluate?
eRunP<-evaluate(pres_test, runP, bioclimP)
###Map?
pred_map <- predict(runP, bioclim)




