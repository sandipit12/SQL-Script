
SELECT CommandType,DatabaseName,CONVERT(time, 
  DATEADD(s, 
    DATEDIFF(s, 
      startTime, 
      EndTime), 
     CAST('1900-01-01 00:00:00' as datetime)
   )) [HH:MM:SS],StartTime,EndTime,CASE WHEN Command LIKE '%DIFF%' THEN 'DIFF'
                                        WHEN Command LIKE '%Full%' THEN 'Full'
										WHEN Command LIKE '%Log%' THEN 'Log' END BackTpye 
,Command
FROM tools.dbo.CommandLog 
WHERE (CommandType like '%BACKUP_DATABASE%' OR CommandType LIKE '%Backup_log%')
AND DatabaseName NOT IN ( 'master','model','msdb')
AND CASE WHEN Command LIKE '%DIFF%' THEN 'DIFF'
                                        WHEN Command LIKE '%Full%' THEN 'Full'
										WHEN Command LIKE '%Log%' THEN 'Log' END = 'Full'
										and startTime > dateadd (day,-7,cast(GETDATE() as DATE))
ORDER BY StartTime desc

