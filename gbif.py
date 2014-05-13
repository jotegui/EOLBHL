import json
import urllib2
from urllib import urlencode
import csv

base_url = 'http://api.gbif.org'
version = 'v0.9'
species_service = 'species'
occurrence_service = 'occurrence'

def getOccurrencesFromTaxonName(taxon_name, field_list, file_name = None):
    #if file_name is None:
    #    file_name = "{0}.csv".format(taxon_name.replace(' ','_'))
    
    taxonIDList = getTaxonIDList(taxon_name)
    occs = getOccurrencesFromTaxonIDList(taxonIDList, field_list)
    print "{0} records in total".format(len(occs))
    occs.insert(0, field_list)
    if file_name is not None:
        buildCSV(occs, file_name)
        return
    else:
        return occs

def getTaxonIDList(taxon_name):
    preurl = '/'.join([base_url,version,species_service])
    limit = 20
    offset = 0
    ids = []
    
    endOfRecords = False
    while endOfRecords is False:
        posturl = urlencode({'name':taxon_name, 'limit':limit, 'offset':offset})
        url = '?'.join([preurl, posturl])
        raw = json.loads(urllib2.urlopen(url).read())
        
        endOfRecords = raw['endOfRecords']
        offset +=20
        
        for rec in raw['results']:
            ids.append(rec['key'])
        
    return ids

def getOccurrencesFromTaxonIDList(taxonIDList, field_list):
    occs = []
    for taxonID in taxonIDList:
        this_occs = getOccurrencesFromTaxonID(taxonID, field_list)
        for i in this_occs:
            occs.append(i)
    return occs
    
def getOccurrencesFromTaxonID(taxonID, field_list):
    preurl = '/'.join([base_url,version,occurrence_service,'search'])
    limit = 20
    offset = 0
    occs = []
    
    endOfRecords = False
    while endOfRecords is False:
        posturl = urlencode({'taxonKey':taxonID, 'limit':limit, 'offset':offset})
        url = '?'.join([preurl, posturl])
        raw = json.loads(urllib2.urlopen(url).read())
        
        endOfRecords = raw['endOfRecords']
        offset += 20
        
        for rec in raw['results']:
            r = []
            for field in field_list:
                try:
                    r.append(rec[field])
                except:
                    r.append('')
            occs.append(r)
    print len(occs),'records for taxonid',taxonID
    return occs

def buildCSV(occs, file_name):
    with open(file_name,'wb') as f:
        writer = csv.writer(f)
        writer.writerows(occs)
    
    return

if __name__ == '__main__':
    taxon_name = 'Dipteryx panamensis'
    file_name = '{0}.csv'.format(taxon_name.replace(' ' ,'_'))
    file_path = os.path.join(os.path.abspath('./'),'data','gbif',file_name)
    field_list = ['decimalLatitude','decimalLongitude','eventDate', 'countryCode']
    
    occs = getOccurrencesFromTaxonName(taxon_name, field_list, file_path)
    print occs
