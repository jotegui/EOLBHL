#library(dismo)
#library(rgdal)
#library(maptools)
#library(sp)
#library(raster)
#library(rJava)
library(RCurl)

base_url <- 'https://api.github.com'
user <- 'jotegui'
repo <- 'EOLBHL'

bioclim_current_folder <- 'data/bioclim/wc2-5/wc2-5'
bioclim_future_folder <- 'data/bioclim/future_bioclim'
elevation_folder <- 'data/bioclim/elevation'
gbif_points_folder <- 'data/gbif'

ex_file <- 'bio1.bil'

url <- paste(base_url, 'repos', user, repo, 'contents', bioclim_current_folder, ex_file, sep='/')

content <- getURLContent(url, httpheader=c(User-Agent = "@jotegui"))
