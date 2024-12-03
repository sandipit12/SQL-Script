SELECT CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END AS DBName
      ,OBJECT_SCHEMA_NAME(object_id,database_id) AS [SCHEMA_NAME]  
      ,OBJECT_NAME(object_id,database_id)AS [OBJECT_NAME]
      ,cached_time
      ,last_execution_time
      ,execution_count
   --   ,total_worker_time / execution_count AS AVG_CPU
      ,total_elapsed_time / execution_count AS AVG_ELAPSED
	  ,(total_elapsed_time / execution_count)/1000000.00 AS AVG_ELAPSED_Sec
      ,total_logical_reads / execution_count AS AVG_LOGICAL_READS
      ,total_logical_writes / execution_count AS AVG_LOGICAL_WRITES
      ,total_physical_reads  / execution_count AS AVG_PHYSICAL_READS
	--  ,last_worker_time/1000000.00 TimeINSec_last_Worker_time--CPU time, in microseconds, that was consumed the last time the stored procedure was executed. 
	  ,last_elapsed_time/1000000.00 TimeINSec_last_elapsed_time -- Elapsed time, in microseconds, for the most recently completed execution of this stored procedure.
FROM sys.dm_exec_procedure_stats  
WHERE  DB_NAME(database_id) IN ('Venus_Live','RSLogs','RSDocuments','DecisionEngine','BorrowerLoan') --AND  (total_elapsed_time / execution_count)/1000000.00  > 30
AND OBJECT_NAME(object_id,database_id) ='MasterUser_SetSoftArchivedStatus'
ORDER BY (total_elapsed_time / execution_count)/1000000.00 ,execution_count DESC--,AVG_LOGICAL_READS DESC,


