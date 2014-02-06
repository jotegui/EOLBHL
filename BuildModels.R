### Load Libraries
library(dismo)
library(rgdal)
library(maptools)
library(sp)
library(raster)
library(rJava)

### Species Name
#species_name = 'Dipteryx panamensis'
species_name = 'Ara ambiguus'

### Data Folder (to be changed with on-the-fly download from GitHub)
data_folder = '/home/jotegui/Desktop/NESCentBHLEOL/EOLBHL/data/'

### Load Current Condition BIOCLIM data
setwd(paste(data_folder,"bioclim/wc2-5/wc2-5", sep="/"))
bioclim_P1<-("./bio1.bil")
bioclim_P2<-("./bio2.bil")
bioclim_P3<-("./bio3.bil")
bioclim_P4<-("./bio4.bil")
bioclim_P5<-("./bio5.bil")
bioclim_P6<-("./bio6.bil")
bioclim_P7<-("./bio7.bil")
bioclim_P12<-("./bio12.bil")
bioclim_P13<-("./bio13.bil")
bioclim_P14<-("./bio14.bil")
bioclim_P15<-("./bio15.bil")
bioclimP<-stack(bioclim_P1,bioclim_P2,bioclim_P3,bioclim_P4,bioclim_P5,bioclim_P6,bioclim_P7,bioclim_P12,bioclim_P13,bioclim_P14, bioclim_P15)

### Load Future Condition BIOCLIM data
setwd(paste(data_folder,"bioclim/future_bioclim", sep="/"))
bioclim1<-("./cc26bi501.tif")
bioclim2<-("./cc26bi502.tif")
bioclim3<-("./cc26bi503.tif")
bioclim4<-("./cc26bi504.tif")
bioclim5<-("./cc26bi505.tif")
bioclim6<-("./cc26bi506.tif")
bioclim7<-("./cc26bi507.tif")
bioclim12<-("./cc26bi5012.tif")
bioclim13<-("./cc26bi5013.tif")
bioclim14<-("./cc26bi5014.tif")
bioclim15<-("./cc26bi5015.tif")
bioclimF<-stack(bioclim1,bioclim2,bioclim3,bioclim4,bioclim5,bioclim6,bioclim7,bioclim12,bioclim13,bioclim14,bioclim15)

### Load Elevation Data
setwd(paste(data_folder,"bioclim/elevation", sep="/"))
ele <- brick("./alt.bil")

### Load GBIF points
setwd(paste(data_folder,"gbif", sep="/"))
species_file <- paste(sub(" ", "_", species_name),"csv", sep="_corrected.")
speciesPts <- read.csv(species_file)
speciesPts <- as.data.frame(cbind(speciesPts$latitude, speciesPts$longitude))
colnames(speciesPts) <- c("latitude", "longitude")
coordinates(speciesPts)<-c("longitude", "latitude")
speciesRaster = rasterize(speciesPts, raster())

### Present condition MaxEnt map
bioClim_SpeciesP<- extract(bioclimP, speciesPts, method='bilinear', buffer=NULL, fun=NULL, df=TRUE)
groupP <- kfold(bioClim_SpeciesP, 5)
pres_trainP <- speciesPts[groupP !=1,]
pres_testP <- speciesPts[groupP ==1,]
bgP <- randomPoints(bioclimP, n=1000)
colnames(bgP) <- c('longitude', 'latitude')
groupP <- kfold(bgP,5)
bg_trainP <-bgP[groupP !=1,]
bg_testP <- bgP[groupP ==1,]
runP<- maxent(bioclimP, pres_trainP, a=bgP, removeDuplicates=TRUE, args=c("-J"))
pred_mapP <- predict(runP, bioclimP)
### Save Map and/or model

### Present condition MaxEnt map
bioClim_SpeciesF<- extract(bioclimF, speciesPts, method='bilinear', buffer=NULL, fun=NULL, df=TRUE)
groupF <- kfold(bioClim_SpeciesF, 5)
pres_trainF <- speciesPts[groupF !=1,]
pres_testF <- speciesPts[groupF ==1,]
bgF <- randomPoints(bioclimF, n=1000)
colnames(bgF) <- c('longitude', 'latitude')
groupF <- kfold(bgF,5)
bg_trainF <-bgF[groupF !=1,]
bg_testF <- bgF[groupF ==1,]
runF<- maxent(bioclimF, pres_trainF, a=bgF, removeDuplicates=TRUE, args=c("-J"))
pred_mapF <- predict(runF, bioclimF)
### Save Map and/or model

### Convert to T/F. Threshold = 0.6
pred_mapP2 <- pred_mapP
pred_mapP2[pred_mapP2>=0.6]<-1
pred_mapP2[pred_mapP2<0.6]<-NA
present_cells <- cellStats(pred_mapP2, 'sum')

pred_mapF2 <- pred_mapF
pred_mapF2[pred_mapF2>=0.6]<-1
pred_mapF2[pred_mapF2<0.6]<-NA
future_cells <- cellStats(pred_mapF2, 'sum')

persistence_map <- mask(pred_mapP2, pred_mapF2)
persistent_cells <- cellStats(persistence_map, 'sum')
persistence <- (persistent_cells*1.0/present_cells)