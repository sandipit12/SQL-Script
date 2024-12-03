SELECT 'EXEC dbo.AutoRestore_RestoreLatestBackup
 @DataBaseName    = '''+name+'''
,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\ '+name+'\FULL\'' 
,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\ '+name+'\DIFF\''
,@RestoreDataPath = D:\Data\
,@RestoreLogPath  = +''D:\Log\'''
FROM Sys.databases 
WHERE database_id >5 AND name NOT IN ('Tools','Venus_Live_snapshot')

