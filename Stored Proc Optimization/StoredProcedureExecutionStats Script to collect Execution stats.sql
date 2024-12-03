DROP TABLE IF EXISTS #temp
SELECT * INTO #temp
FROM 
(
SELECT CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END AS DBName
      ,OBJECT_SCHEMA_NAME(object_id,database_id) AS [SCHEMA_NAME]  
      ,OBJECT_NAME(object_id,database_id)AS [OBJECT_NAME]
      ,cached_time
      ,last_execution_time
      ,execution_count
	 -- ,execution_count/DATEDIFF ( MINUTE , cached_time , GETDATE() ) AVG_execution_Per_MINUTE
	  --,execution_count/DATEDIFF ( Day , cached_time , GETDATE() ) AVG_execution_Per_Day
      ,total_worker_time / execution_count AS AVG_CPU
	  ,(total_elapsed_time / execution_count)/1000000.00 AS AVG_ELAPSED_Sec
      ,total_logical_reads / execution_count AS AVG_LOGICAL_READS
      ,total_logical_writes / execution_count AS AVG_LOGICAL_WRITES
      ,total_physical_reads  / execution_count AS AVG_PHYSICAL_READS
	  ,max_elapsed_time/1000000.00 AS max_elapsed_time_Sec
	  ,max_logical_reads
	--  ,last_worker_time/1000000.00 TimeINSec_last_Worker_time--CPU time, in microseconds, that was consumed the last time the stored procedure was executed. 
	  ,last_elapsed_time/1000000.00 TimeINSec_last_elapsed_time_Sec -- Elapsed time, in microseconds, for the most recently completed execution of this stored procedure.
	  ,GETDATE() AS CollectionDate
FROM sys.dm_exec_procedure_stats
WHERE database_id <> 32767 AND database_id >4 and DB_NAME(database_id) <> 'Tools'
) A



INSERT INTO tools.[dbo].SandipCollectStoredProcedureExecutionStats
([DBName], [SCHEMA_NAME], [OBJECT_NAME], [cached_time], [last_execution_time], [execution_count], [AVG_CPU], [AVG_ELAPSED_Sec], [AVG_LOGICAL_READS], [AVG_LOGICAL_WRITES], [AVG_PHYSICAL_READS], [max_elapsed_time_Sec], [max_logical_reads], [TimeINSec_last_elapsed_time_Sec], [CollectionDate])
SELECT [DBName], [SCHEMA_NAME], [OBJECT_NAME], [cached_time], [last_execution_time], [execution_count], [AVG_CPU], [AVG_ELAPSED_Sec], [AVG_LOGICAL_READS], [AVG_LOGICAL_WRITES], [AVG_PHYSICAL_READS], [max_elapsed_time_Sec], [max_logical_reads], [TimeINSec_last_elapsed_time_Sec], [CollectionDate]
FROM #temp New WHERE NOT EXISTS (SELECT 1 FROM tools.[dbo].SandipCollectStoredProcedureExecutionStats Old WHERE New.[DBName] = Old.[DBName] AND New.[OBJECT_NAME] = Old.[OBJECT_NAME] )

UPDATE tools.[dbo].SandipCollectStoredProcedureExecutionStats 
SET 
	execution_count = 	CASE WHEN Old.[OBJECT_NAME] = New.[OBJECT_NAME] AND New.cached_time =  Old.cached_time THEN  New.execution_count -- When Cached time same then Stored Proc Excution Count latest will be selected 
						 WHEN Old.[OBJECT_NAME] = New.[OBJECT_NAME] AND New.cached_time  <> Old.cached_time THEN  New.execution_count + Old.execution_count -- When Cached time not same then Stored Proc Excution Count Start from 0 so we will add number to old vlaue
	                     END ,
	last_execution_time = new.last_execution_time,
	max_elapsed_time_Sec = Iif (new.max_elapsed_time_Sec > OLD.max_elapsed_time_Sec ,new.max_elapsed_time_Sec ,OLD.max_elapsed_time_Sec) ,
	TimeINSec_last_elapsed_time_Sec	= Iif (new.TimeINSec_last_elapsed_time_Sec > OLD.TimeINSec_last_elapsed_time_Sec ,new.TimeINSec_last_elapsed_time_Sec ,OLD.TimeINSec_last_elapsed_time_Sec),
	CollectionDate = New.CollectionDate
FROM 
		tools.[dbo].SandipCollectStoredProcedureExecutionStats OLD
		JOIN #temp New ON Old.[OBJECT_NAME] = New.[OBJECT_NAME]

;WITH CTE AS
(SELECT new.[OBJECT_NAME],
	[Update_AVG_CPU] =  AVG(CASE WHEN  Old.[OBJECT_NAME] = New.[OBJECT_NAME] AND New.cached_time =  Old.cached_time THEN  New.[AVG_CPU] -- When Cached time same then Stored Proc Excution Count latest will be selected 
				 ELSE New.[AVG_CPU] + Old.[AVG_CPU] -- When Cached time not same then Stored Proc Excution Count Start from 0  so we will Avg of Old and New Value
				 END),
	Update_AVG_ELAPSED_Sec = AVG(CASE WHEN  Old.[OBJECT_NAME] = New.[OBJECT_NAME] AND New.cached_time =  Old.cached_time THEN  New.AVG_ELAPSED_Sec -- When Cached time same then Stored Proc Excution Count latest will be selected 
					  ELSE New.AVG_ELAPSED_Sec + Old.AVG_ELAPSED_Sec -- When Cached time not same then Stored Proc Excution Count Start from 0  so we will Avg of Old and New Value
					  END),
	Update_AVG_LOGICAL_WRITES = AVG(CASE WHEN  Old.[OBJECT_NAME] = New.[OBJECT_NAME] AND New.cached_time =  Old.cached_time THEN  New.AVG_LOGICAL_WRITES -- When Cached time same then Stored Proc Excution Count latest will be selected 
						 ELSE New.AVG_LOGICAL_WRITES + Old.AVG_LOGICAL_WRITES -- When Cached time not same then Stored Proc Excution Count Start from 0  so we will Avg of Old and New Value
						 END),
	Update_AVG_LOGICAL_READS = AVG(CASE WHEN  Old.[OBJECT_NAME] = New.[OBJECT_NAME] AND New.cached_time =  Old.cached_time THEN  New.AVG_LOGICAL_READS -- When Cached time same then Stored Proc Excution Count latest will be selected 
						ELSE New.AVG_LOGICAL_READS + Old.AVG_LOGICAL_READS -- When Cached time not same then Stored Proc Excution Count Start from 0 so we will Avg of Old and New Value
						END),
	Update_AVG_PHYSICAL_READS = AVG(CASE WHEN  Old.[OBJECT_NAME] = New.[OBJECT_NAME] AND New.cached_time =  Old.cached_time THEN  New.AVG_PHYSICAL_READS -- When Cached time same then Stored Proc Excution Count latest will be selected 
						 ELSE New.AVG_PHYSICAL_READS + Old.AVG_PHYSICAL_READS -- When Cached time not same then Stored Proc Excution Count Start from 0  so we will Avg of Old and New Value
						 END)

FROM tools.[dbo].SandipCollectStoredProcedureExecutionStats OLD
JOIN #temp New ON Old.[OBJECT_NAME] = New.[OBJECT_NAME]
GROUP BY new.[OBJECT_NAME]
)
--SELECT * FROM cte

UPDATE tools.[dbo].SandipCollectStoredProcedureExecutionStats 
SET 
	[AVG_CPU] =  [Update_AVG_CPU],
	AVG_ELAPSED_Sec = Update_AVG_ELAPSED_Sec,
	AVG_LOGICAL_WRITES = Update_AVG_LOGICAL_WRITES,
	AVG_LOGICAL_READS = Update_AVG_LOGICAL_READS,
	AVG_PHYSICAL_READS = AVG_PHYSICAL_READS
FROM tools.[dbo].SandipCollectStoredProcedureExecutionStats OLD
JOIN cte New ON Old.[OBJECT_NAME] = New.[OBJECT_NAME]