### Load Libraries
library(dismo)
library(rgdal)
library(maptools)
library(sp)
library(raster)
system("java -version")
library(rJava)

### Species Name
#species_name = 'Dipteryx panamensis'
#species_name = 'Ara ambiguus'

### Get Present Conditions
getP <- function() {

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
    return(bioclimP)
}

### Get Future Conditions
getF <- function() {

    data_folder = '/home/jotegui/Desktop/NESCentBHLEOL/EOLBHL/data/'

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
    return(bioclimF)
}

### Get Elevation Data
getE <- function() {

    ### Load Elevation Data
    data_folder = '/home/jotegui/Desktop/NESCentBHLEOL/EOLBHL/data/'
    setwd(paste(data_folder,"bioclim/elevation", sep="/"))
    ele <- brick("./alt.bil")
    return(ele)
}

### Get Data Points
getDFromFile <- function(species_name) {
    ### Load GBIF points
    data_folder = '/home/jotegui/Desktop/NESCentBHLEOL/EOLBHL/data/'
    setwd(paste(data_folder,"gbif", sep="/"))
    species_file <- paste(sub(" ", "_", species_name),"csv", sep="_corrected.")
    speciesPts <- read.csv(species_file)
    speciesPts <- as.data.frame(cbind(speciesPts$latitude, speciesPts$longitude))
    colnames(speciesPts) <- c("latitude", "longitude")
    coordinates(speciesPts)<-c("longitude", "latitude")
    return(speciesPts)
}
getD <- function(latitudes, longitudes) {
    speciesPts <- as.data.frame(cbind(latitudes, longitudes))
    colnames(speciesPts) <- c('latitude','longitude')
    coordinates(speciesPts) <- c('longitude','latitude')
    return(speciesPts)
}

### Rasterize species points
rasterPoints <- function(speciesPts) {
    speciesRaster = rasterize(speciesPts, raster())
    return(speciesRaster)
}

### Build Prediction Map (a.k.a. run MaxEnt)
runMaxent <- function(bioclim, speciesPts) {
    ### Present condition MaxEnt map
    bioClim_Species<- extract(bioclim, speciesPts, method='bilinear', buffer=NULL, fun=NULL, df=TRUE)
    group <- kfold(bioClim_Species, 5)
    pres_train <- speciesPts[group !=1,]
    pres_test <- speciesPts[group ==1,]
    bg <- randomPoints(bioclim, n=1000)
    colnames(bg) <- c('longitude', 'latitude')
    group <- kfold(bg,5)
    bg_train <-bg[group !=1,]
    bg_test <- bg[group ==1,]
    run<- maxent(bioclim, pres_train, a=bg, removeDuplicates=TRUE, args=c("-J"))
    pred_map <- predict(run, bioclim)
    return(run)
}

mapMaxent <- function(run, bioclim, file_name) {
    pred_map <- predict(run, bioclim)
    setwd('/home/jotegui/Desktop/NESCentBHLEOL/EOLBHL/data/')
    save(pred_map, file=file_name)
    print("Map generated and stored in the file:")
    print(file_name)
    return(pred_map)
}
