-- Latest Log Restored 

SELECT 
 rh.destination_database_name AS [Database],
  CASE WHEN rh.restore_type = 'D' THEN 'Full Databse'
  WHEN rh.restore_type = 'F' THEN 'File'
   WHEN rh.restore_type = 'I' THEN 'Differential'
  WHEN rh.restore_type = 'L' THEN 'Log'
    ELSE rh.restore_type 
 END AS [Restore Type],
 rh.restore_date AS [Restore Date],
 bmf.physical_device_name AS [Source], 
-- rf.destination_phys_name AS [Restore File],
 rh.user_name AS [Restored By]
FROM msdb.dbo.restorehistory rh
 INNER JOIN msdb.dbo.backupset bs ON rh.backup_set_id = bs.backup_set_id
 INNER JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id = bs.media_set_id
 WHERE rh.destination_database_name = 'Venus_Live'
 ORDER BY [Restore Date] desc
GO
-- Check same from Logshipping table 

SELECT * FROM
(
SELECT CASE WHEN FILEname LIKE '%Full%' THEN 'Full'
            WHEN FileName LIKE '%Diff%' THEN 'Diff'
			WHEN FILEname LIKE '%Log%' THEN 'Log' END AS RestoreType, 
			CONVERT(time, DATEADD(s, DATEDIFF(s, RestoreStartTime,RestoreEndTime),CAST('1900-01-01 00:00:00' as datetime) )) [HH:MM:SS],
			FileName,FileTimeStamp RestoredBackup,RestoreStatus, LastRestoredLSN,
			ISNULL(CONVERT(VARCHAR,RestoreStartTime),'No backups') AS RestoreStartTime,
			ISNULL(CONVERT(VARCHAR,RestoreStartTime),'No backups') AS RestoreEndTime,
			ROW_NUMBER() OVER(PARTITION BY DatabaseName,CASE WHEN FILEname LIKE '%Full%' THEN 'Full'WHEN FileName LIKE '%Diff%' THEN 'Diff' WHEN FILEname LIKE '%Log%' THEN 'Log' END ORDER BY RestoreStartTime desc) Lastest
FROM LogShipping.dbo.LogShippingRestoreLog
WHERE DatabaseName = 'Venus_Live'
)A
WHERE a.Lastest <=5
ORDER BY A.RestoredBackup desc 


--Checks for Active records in LogShippingConfiguration
USE LogShipping

SELECT LSC.DatabaseName, LSC.LogBackupPath, LSC.LogFileNamePattern
FROM dbo.LogShippingConfiguration AS LSC
WHERE LSC.IsActive = 1


--UPDATE CONFIGURATION TABLE TO ACTIVATE DATABASES YOU WANT TO RESTART THE RESTORING PROCESS FOR

UPDATE LogShipping.dbo.LogShippingConfiguration SET IsActive = 1 WHERE DatabaseName = 'Venus_Live'

-- Once we activate database restore SQL Agent Job Will runs every 2 min and Keep on appling Logs backing up on Current Prod 
USE Msdb
EXEC dbo.sp_update_job @job_name = '#AG_Custom Log Shipping - Main',@enabled =1

-- Get the Lasted backup File from Current Prod Node B Where Log back taken.

USE Tools

SELECT * FROM 
(
SELECT CommandType,DatabaseName,CONVERT(time, DATEADD(s,     DATEDIFF(s,       startTime,       EndTime),      CAST('1900-01-01 00:00:00' as datetime)   )) [HH:MM:SS],
      StartTime,EndTime,CASE WHEN Command LIKE '%DIFF%' THEN 'DIFF'WHEN Command LIKE '%Full%' THEN 'Full'WHEN Command LIKE '%Log%' THEN 'Log' END BackTpye ,Command,
	  ROW_NUMBER() OVER(PARTITION BY DatabaseName ORDER BY StartTime desc) Lastest
FROM tools.dbo.CommandLog 
WHERE CommandType = 'BACKUP_LOG' AND DatabaseName = 'Venus_Live' 
AND StartTime > DateAdd ( DAY,-1,CAST(GETDATE() AS DATE))
)A
WHERE a.Lastest <=5


-- When Lastest Restore on New Cluster matches with Lasted Backup On Current PRod

-- (PRIMARY ONLY) 
--Step 1. UPDATE CONFIGURATION TABLE TO BRING THE DATABASES ONLINE (PRIMARY ONLY) 
		-- UPDATE LogShipping.dbo.LogShippingConfiguration SET RstoreWithRecovery = 1 WHERE IsActive = 1