import csv
from gbif import buildCSV

def cleanCSV(file_name):
	obj = getObject(file_name)
	obj2 = removeIncompleteRecords(obj)
	obj3 = removeOutOfBoundingBox(obj2)
	splitname = file_name.split('.')
	splitname[1] = '_'.join([splitname[1],'corrected'])
	corrected_file = '.'.join(splitname)
	buildCorrectedCSV(obj3, corrected_file)
	
	return

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

def removeLonSwappedRecords(obj1):
	obj2 = [obj1[0]]
	for row in obj1[1:]:
		wrong = False
		
		lon = float(row[1])
		if lon>=0:
			wrong = True
		
		if wrong is False:
			obj2.append(row)
	return obj2

def removeOutOfBoundingBox(obj1):
	obj2 = [obj1[0]]
	for row in obj1[1:]:
		wrong = False
		
		lat = float(row[0])
		lon = float(row[1])
		maxlat = 18
		maxlon = -73
		minlat = -6
		minlon = -95
		
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
	#file_name = './data/gbif/Ara_ambiguus.csv'
	file_name = './data/gbif/Dipteryx_panamensis.csv'
	
	cleanCSV(file_name)
