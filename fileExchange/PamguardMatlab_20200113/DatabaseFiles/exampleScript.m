% read in data from the gpsData table in the database
% note that this requires 
dbFilename = 'exampleDatabase.sqlite3';
setdbprefs('datareturnformat', 'structure')
con = sqlitedatabase(dbFilename);
qStr = 'SELECT * FROM gpsData ORDER BY UTC';
q = exec(con, qStr);
q = fetch(q);
dbData = q.Data;
close(con)
dbDateTime = datenum([dbData.GpsDate]);
dbLat = [dbData.Latitude];
dbLong = [dbData.Longitude];
dbHeading = [dbData.Heading];
