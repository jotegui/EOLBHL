import json
import urllib2
from urllib import urlencode

base_url = 'http://api.gbif.org'
version = 'v0.9'
species_service = 'species'
occurrence_service = 'occurrence'

def getTaxonIDs(taxon_name):
	preurl = '/'.join([base_url,version,species_service])
	limit = 20
	ids = []
	
	endOfRecords = False
	while endOfRecords is False:
		posturl = urlencode({'name':taxon_name, 'limit':limit, 'offset':0})
		url = '?'.join([preurl, posturl])
		raw = json.loads(urllib2.urlopen(url).read())
		
		endOfRecords = raw['endOfRecords']
		limit +=20
		
		for rec in raw['results']:
			ids.append(rec['key'])
		
	return ids


if __name__ == '__main__':
	taxon_name = 'Ara ambiguus'
	
	taxonIDs = getTaxonIDs(taxon_name)
