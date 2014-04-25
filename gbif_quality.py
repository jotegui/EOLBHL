import csv
from gbif import buildCSV

def cleanCSV(file_name):
    obj = getObject(file_name)
    clean_obj = cleanOccs(obj)
    splitname = file_name.split('.')
    splitname[1] = '_'.join([splitname[1],'corrected'])
    corrected_file = '.'.join(splitname)
    buildCorrectedCSV(clean_obj, corrected_file)
    return

def cleanOccs(obj, bbox = None):
    obj2 = removeIncompleteRecords(obj)
    if bbox is None:
        bbox = {
            'maxlat': 90,
            'minlat': -90,
            'maxlon': 180,
            'minlon': -180
        }
    obj3 = removeOutOfBoundingBox(obj2, bbox)
    return obj3


def getObject(file_name):
    with open(file_name, 'rb') as f:
        reader = csv.reader(f)
        data = []
        for row in reader:
            data.append(row)
    return data
                
def removeIncompleteRecords(obj1):
    obj2 = []
    for row in obj1:
        wrong = False
        for field in row:
            if field == '':
                wrong = True
        if wrong is False:
            obj2.append(row)
    return obj2

def removeOutOfBoundingBox(obj1, bbox):
    obj2 = [obj1[0]]
    for row in obj1[1:]:
        wrong = False
        
        lat = float(row[0])
        lon = float(row[1])
        maxlat = bbox['maxlat']
        maxlon = bbox['maxlon']
        minlat = bbox['minlat']
        minlon = bbox['minlon']
        
        if lat>=maxlat or lat<=minlat or lon>=maxlon or lon<=minlon:
            wrong = True
        
        if wrong is False:
            obj2.append(row)
    return obj2

def buildCorrectedCSV(occs, file_name):
    with open(file_name,'wb') as f:
        writer = csv.writer(f)
        writer.writerows(occs)
    
    return

if __name__ == '__main__':
    taxon_name = 'Dipteryx panamensis'
    #taxon_name = 'Ara ambiguus'    
    file_name = '{0}.csv'.format(taxon_name.replace(' ' ,'_'))
    file_path = os.path.join(os.path.abspath('./'),'data','gbif',file_name)
    
    cleanCSV(file_path)
