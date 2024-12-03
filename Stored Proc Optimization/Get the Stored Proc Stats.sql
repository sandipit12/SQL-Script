USE Venus_Live


DECLARE @StoredProcName VARCHAR(255) = 'AutoRek_DailyLenderBalances'
;WITH CTE_CreateDate
AS 
(
SELECT Name AS name,create_date,modify_date FROM sys.procedures

)

SELECT CTE_CreateDate.create_date,CTE_CreateDate.modify_date,
      CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END AS DBName
      ,OBJECT_NAME(object_id,database_id)AS [OBJECT_NAME]
      ,cached_time
      ,last_execution_time
      ,execution_count
	  ,(last_elapsed_time )/1000000.00 AS Last_ELAPSED_Sec
	  --,execution_count/DATEDIFF ( MINUTE , cached_time , GETDATE() ) AVG_execution_Per_MINUTE
	  --,execution_count/DATEDIFF ( Day , cached_time , GETDATE() ) AVG_execution_Per_Day
      ,total_worker_time / execution_count AS AVG_CPU
	  ,(total_elapsed_time / execution_count)/1000000.00 AS AVG_ELAPSED_Sec,max_elapsed_time/1000000.00 AS max_elapsed_time_Sec,min_elapsed_time/1000000.00 AS min_elapsed_time_Sec
      ,total_logical_reads / execution_count AS AVG_LOGICAL_READS,max_logical_reads,min_logical_reads
      ,total_logical_writes / execution_count AS AVG_LOGICAL_WRITES
      ,total_physical_reads  / execution_count AS AVG_PHYSICAL_READS

FROM sys.dm_exec_procedure_stats  
INNER JOIN CTE_CreateDate ON CTE_CreateDate.name = OBJECT_NAME(object_id,database_id)
WHERE OBJECT_NAME(object_id,database_id) = 'UserActionRequest_GetAllByFilter'
ORDER BY (total_elapsed_time / execution_count)/1000000.00 desc ,execution_count DESC--,AVG_LOGICAL_READS DESC,


--SP_helptext BorrowerLoans_InDefault
return

DECLARE @VersionDate DATETIME;
EXEC tools.dbo.sp_BlitzCache @StoredProcName ='UserActionRequest_GetAllByFilter'

return

SELECT * FROM sys.objects WHERE name ='UserActionRequest_GetAllByFilter' 


SELECT * FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily
WHERE StoredProcName ='UserActionRequest_GetAllByFilter'
ORDER BY CollectionDate DESC

EXEC UserActionRequest_GetAllByFilter @UserId =0