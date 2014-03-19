#!/usr/bin/python
import os,sys,sqlite3,subprocess

class Database:
	def __init__(self):
		self.path = os.path.dirname(os.path.abspath(__file__))+'/.tag/tag.db'
		self.conn = sqlite3.connect(self.path)

	def getPath(self): return self.path
	def getConnection(self): return self.conn

	def create(self):
		self.conn.execute('CREATE TABLE files(file TEXT UNIQUE);')
		self.conn.execute('CREATE TABLE tags(tag TEXT UNIQUE);')
		self.conn.execute('CREATE TABLE file_tag(fileid INT,tagid INT);')

	def recreate(self):
		self.conn.execute('DROP TABLE tags;')
		self.conn.execute('DROP TABLE files;')
		self.conn.execute('DROP TABLE file_tag;')
		self.create()

if len(sys.argv) > 1:
	if (sys.argv[1]):
		if(sys.argv[1]=='create'):
			Database().create()
		elif(sys.argv[1]=='recreate'):
			Database().recreate()
		elif(sys.argv[1]=='add'):
			if(len(sys.argv)==4):
				db = Database().getConnection()
				pwd = subprocess.check_output('pwd')[:-1] #remove trailing /n
				ta = sys.argv[2]
				fi = pwd+'/'+sys.argv[3]
				
				fiid = 0
				cursor = db.cursor()
				cursor.execute('SELECT rowid FROM files WHERE file=?',(fi,))
				temp = cursor.fetchone()
				if temp != None:
					fiid = temp[0]
				else:
					cursor = db.cursor()
					cursor.execute('INSERT INTO files(file) VALUES(?);',(fi,))
					fiid = cursor.lastrowid
				
				taid = 0
				cursor = db.cursor()
				cursor.execute('SELECT rowid FROM tags WHERE tag=?',(ta,))
				temp = cursor.fetchone()
				if temp != None:
					taid = temp[0]
				else:
					cursor.execute('INSERT INTO tags(tag) VALUES(?);',(ta,))
					taid = cursor.lastrowid
				
				db.execute('INSERT OR IGNORE INTO file_tag VALUES(?,?);',(fiid,taid))
				db.commit()
			else:
				print 'Usage: tag add [tag name] [file name]'
		elif(sys.argv[1]=='list'):
			if(len(sys.argv)==3):
				if(sys.argv[2]=='all'):
					cursor = Database().getConnection().cursor()
					cursor.execute("""SELECT file, GROUP_CONCAT(tag) FROM file_tag 
								INNER JOIN files ON (file_tag.fileid = files.rowid) 
								INNER JOIN tags ON (file_tag.tagid = tags.rowid) 
								GROUP BY file;""")
					for row in cursor:
						print "FILE = ", row[0]
						tags = row[1].split(',')
						print "TAGS = ", 
						for tag in tags:
							print tag+", ",
						print
				else:
					print 'Files with tag "%s":' % sys.argv[2]
					cursor = Database().getConnection().cursor()
					cursor.execute("""SELECT file FROM file_tag 
								INNER JOIN files ON (file_tag.fileid = files.rowid) 
								INNER JOIN tags ON (file_tag.tagid = tags.rowid) 
								WHERE tags.tag=?""",(sys.argv[2],))
					for row in cursor:
						print row[0]
			else:
				print 'Usage: tag list [all|tag name]'
else:
	print '-h for help'
