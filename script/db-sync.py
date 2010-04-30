#!/usr/bin/python -u
#
# Nathan Reed, 2009-02-07

import MySQLdb
import re
import sys
import ConfigParser

def main():
	# load up the config file
	config = ConfigParser.ConfigParser()
	config.read('sync.config')
	sectionList = config.sections()
	
	configSection = sectionList[0]

	fromServer = config.get(configSection, 'fromServer')
	fromDbName = config.get(configSection, 'fromDbName')
	fromDbUser = config.get(configSection, 'fromDbUser')
	fromDbPass = config.get(configSection, 'fromDbPass')

	toServer = config.get(configSection, 'toServer')
	toDbName = config.get(configSection, 'toDbName')
	toDbUser = config.get(configSection, 'toDbUser')
	toDbPass = config.get(configSection, 'toDbPass')
		
	tableName = config.get(configSection, 'tableName')
	keyName   = config.get(configSection, 'keyName')
	
	try:
		print 'Connecting to Source Database: ' + fromServer
		srcDb = SyncDb(fromServer, fromDbUser, '', fromDbName, tableName, keyName)
	except MySQLdb.OperationalError, (ErrorNumber, ErrorMessage):
		print  'ERROR:', ErrorNumber, ErrorMessage
		quit()

	try:
		print 'Connecting to Destination: ' + toServer	
		destDb = SyncDb(toServer, toDbUser, toDbPass, toDbName, tableName, keyName)
	except MySQLdb.OperationalError, (ErrorNumber, ErrorMessage):
		print  'ERROR:', ErrorNumber, ErrorMessage
		quit()
	
	# set the timezone to utc for both connections
	srcDb.setTimezoneUTC();
	destDb.setTimezoneUTC();

	print 'Getting unsynced rows on "%s" using key "%s"...' % (tableName, keyName)
	destMaxKey = destDb.maxKey();
	syncData = srcDb.getRows(destMaxKey);

	# nothing to sync
	if(syncData == None):
		print "Databases in sync"
		return 0
	
	# generate a list of insert command strings
	inserts = generateInserts(syncData, tableName, 16);
	totalInserts = len(inserts)
	print "%d rows to sync, %d inserts" % (len(syncData), totalInserts)
	
	# run the inserts on the destination server
	print "starting sync";
	insertCount = 0
	cursor = destDb.dbconn.dbconn.cursor()
	
	for cmd in inserts:
		result = cursor.execute(cmd)
		
		#result = destDb.dbconn.simpleUpdate(cmd)
		if(result == False): break;
		sys.stdout.write('.')
		insertCount = insertCount + 1
		
	cursor.close()	
	
	# all good?
	if(result == False): print "SYNC FAILED!"
	else: print "\nsync complete"
		
	
	
def generateInserts(rows, tableName, maxRows):
	i = 0;
	strrows = [];
	inserts = [];
	
	if(rows != None and len(rows) > 0):
		fieldList = keyList(rows[0]);
		baseStr = "insert ignore into %s(%s) values\n" % (tableName, fieldList);
	
		for row in rows:
			strrows.append("(%s)\n" % valueList(row))
	
		while i < len(rows):
			inserts.append(baseStr + ", ".join(strrows[i:i+maxRows]));
			i += maxRows
		
	return inserts

def keyList(row):
	return ", ".join(row)
	
def valueList(row):
	return ", ".join(["'"+re.escape(str(row[k]))+"'" for k in row])

class SyncDb:
	def __init__(self, server, user, password, database, tablename, pk):
		self.dbconn = SimpleDb(server, user, password, database)
		self.tableName = tablename
		self.keyName = pk

	def setTimezoneUTC(self):
		self.dbconn.simpleQuery("SET time_zone = '+00:00'");
		
	def minKey(self):
		sqlData = self.dbconn.simpleQuery("select min(%s) as min from %s" % (self.keyName, self.tableName));
		return sqlData[0]['min']
		
	def maxKey(self):
		sqlData = self.dbconn.simpleQuery("select max(%s) as max from %s" % (self.keyName, self.tableName));
		return sqlData[0]['max']
		
	def getRows(self, startAt):
		"returns all the rows from the table starting at the given key value"
		if(startAt == None): startAt = 0
		sqlData = self.dbconn.simpleQuery("select * from %s where %s > %d order by %s desc limit 1000" % (self.tableName, self.keyName, startAt, self.keyName));
		return sqlData
		
	def insertRows(self, inserts):
		for cmd in inserts:
			result = self.dbconn.simpleUpdate(cmd)
			if(result == False): return False;
		
		return False	

class SimpleDb:
	def __init__(self, server, user, password, database):
		self.dbconn = MySQLdb.connect(server, user, password, database)
	
	def simpleUpdate(self, query, args=None):
		"send a non select query to the db, returns false on failure, otherwise the # rows affected"
		result = False

		try:
			cursor = self.dbconn.cursor()
			result = cursor.execute(query, args)
			cursor.close()
			self.dbconn.commit()
		except (MySQLdb.IntegrityError):
			pass;

		return result

	def simpleQuery(self, query, args=None):
		"send a select based query to the db, and return all the data as a dict"
		result = None;

		cursor = self.dbconn.cursor(MySQLdb.cursors.DictCursor)
		count = cursor.execute(query, args)
		if(count != 0):	result = cursor.fetchall()

		return result

	def close(self):
		self.dbconn.close();

	
main()
