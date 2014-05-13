import csv
from gbif import buildCSV
import requests
import json

class CleaningError(Exception):
    def __init__(self,value):
        self.value=value
    def __str__(self):
        return repr(self.value)

def removeIncompleteRecords(obj):
    obj2 = []
    for row in obj:
        wrong = False
        for field in row:
            if field == '':
                wrong = True
        if wrong is False:
            obj2.append(row)
    return obj2

def cleanWithAPI(obj, taxon_name):
    obj2 = []
    checked = {}
    for i in obj:
        if i[0] == 'decimalLatitude':
            obj2.append(i)
            continue
        lat = str(i[0])
        lon = str(i[1])
        country = i[3]
        print '{0}, {1} = {2}'.format(lat, lon, country)
        if (lat, lon, country) not in checked:
            url = 'https://jot-mol-qualityapi.appspot.com/_ah/api/qualityapi/v1/geospatial'
            url = '/'.join([url, lat, lon, country, taxon_name])
            print url
            r = requests.get(url)
            if r.status_code == 200:
                flags = json.loads(r.content)
                if flags['isZero'] is False and flags['distanceToCountry']<=1:
                    checked[(lat, lon, country)] = 1
                    obj2.append(i)
                else:
                    checked[(lat, lon, country)] = 0
            else:
                checked[(lat, lon, country)] = 0
                continue
        else:
            if checked[(lat, lon, country)] == 1:
                obj2.append(i)
    return obj2

def countUniqueLocalities(obj):
    locs = {}
    # Count the number of times each latlon appears and store in locs
    for i in obj:
        lat = i[0]
        lon = i[1]
        if (lat, lon) not in locs:
            locs[(lat, lon)] = 1
        else:
            locs[(lat, lon)] += 1
    # return object only if there are more than 20 different localities
    if len(locs.keys()) < 20:
        raise CleaningError('There are only {0} different localities for this species'.format(len(locs.keys())))



##########################
##  OBSOLETE FUNCTIONS  ##
##########################

#def cleanOccs(obj, bbox = None):
#    obj2 = removeIncompleteRecords(obj)
#    if bbox is None:
#        bbox = {
#            'maxlat': 90,
#            'minlat': -90,
#            'maxlon': 180,
#            'minlon': -180
#        }
#    obj3 = removeOutOfBoundingBox(obj2, bbox)
#    return obj3

#def cleanCSV(file_name):
#    obj = getObject(file_name)
#    clean_obj = cleanOccs(obj)
#    splitname = file_name.split('.')
#    splitname[1] = '_'.join([splitname[1],'corrected'])
#    corrected_file = '.'.join(splitname)
#    buildCorrectedCSV(clean_obj, corrected_file)
#    return

#def getObject(file_name):
#    with open(file_name, 'rb') as f:
#        reader = csv.reader(f)
#        data = []
#        for row in reader:
#            data.append(row)
#    return data

#def removeOutOfBoundingBox(obj1, bbox):
#    obj2 = [obj1[0]]
#    for row in obj1[1:]:
#        wrong = False
#        
#        lat = float(row[0])
#        lon = float(row[1])
#        maxlat = bbox['maxlat']
#        maxlon = bbox['maxlon']
#        minlat = bbox['minlat']
#        minlon = bbox['minlon']
#        
#        if lat>=maxlat or lat<=minlat or lon>=maxlon or lon<=minlon:
#            wrong = True
#        
#        if wrong is False:
#            obj2.append(row)
#    return obj2

#def buildCorrectedCSV(occs, file_name):
#    with open(file_name,'wb') as f:
#        writer = csv.writer(f)
#        writer.writerows(occs)
#    
#    return

if __name__ == '__main__':
    taxon_name = 'Dipteryx panamensis'
    #taxon_name = 'Ara ambiguus'    
    file_name = '{0}.csv'.format(taxon_name.replace(' ' ,'_'))
    file_path = os.path.join(os.path.abspath('./'),'data','gbif',file_name)
    
    cleanCSV(file_path)
