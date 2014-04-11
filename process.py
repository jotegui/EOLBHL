import rpy2.robjects as robjects
from rpy2.robjects.packages import importr
from gbif import *
from gbif_quality import *

def run(taxon_name):

    # Define some variables
    field_list = ['decimalLatitude','decimalLongitude','eventDate']

    # Extract occurrence points (from gbif module)
    print "Extracting GBIF points"
    occs = getOccurrencesFromTaxonName(taxon_name, field_list)

    # Get clean records (from gbif_quality module)
    print "Cleaning GBIF points"
    bbox = {
        'maxlat': 18,
        'maxlon': -73,
        'minlat': -6,
        'minlon': -95
    }
    clean_occs = cleanOccs(occs, bbox)

    # Load R functions (from BuildModels library)
    print "Loading R functions"
    robjects.r('source(\'BuildModels.R\')')
    getP = robjects.globalenv['getP']
    getF = robjects.globalenv['getF']
    getE = robjects.globalenv['getE']
    getD = robjects.globalenv['getD']
    runMaxent = robjects.globalenv['runMaxent']
    mapMaxent = robjects.globalenv['mapMaxent']

    # Transform points to R data.frame
    print "Generating Coordinate Pair Objects in R"
    latitudes = []
    longitudes = []
    for line in clean_occs:
        if line[0] != 'decimalLatitude':
            latitudes.append(line[0])
            longitudes.append(line[1])
    latitudeV = robjects.FloatVector(latitudes)
    longitudeV = robjects.FloatVector(longitudes)

    # Extract Bioclim raster stacks
    print "Extracting Bioclim raster stacks"
    bioclimP = getP()
    bioclimF = getF()

    # Create Species points spatial object
    print "Creating Species points spatial objects"
    speciesPts = getD(latitudeV, longitudeV)

    # Run Maxent models for present and future
    print "Running MaxEnt model for present data"
    maxentPresent = runMaxent(bioclimP, speciesPts)
    print "Running MaxEnt model for future data"
    maxentFuture = runMaxent(bioclimF, speciesPts)

    # Map Maxent models
    print "Generating and storing model map for present data"
    mapMaxentPresent = mapMaxent(maxentPresent, bioclimP, 'map_{0}_present.RData'.format(taxon_name.replace(" ", "_")))
    print "Generating and storing model map for present data"
    mapMaxentFuture = mapMaxent(maxentFuture, bioclimF, 'map_{0}_future.RData'.format(taxon_name.replace(" ", "_")))
    
    return mapMaxentPresent, mapMaxentFuture
    
if __name__ == "__main__":
    #taxon_name = 'Ara ambiguus'
    taxon_name = 'Dipteryx panamensis'
    
    mapPresent, mapFuture = run(taxon_name)
