SELECT TOP 20
OBJECT_NAME(qt.objectid, qt.dbid),
SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_logical_reads DESC -- logical reads








/**********************************************************
*   top 10 procedures that use the most memory and disk IO on our system
***********************************************************/

SELECT TOP 10
     ObjectName         = OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
     ,DiskReadsPerExecution = qs.total_physical_reads  / qs.execution_count   -- The worst reads, disk reads
     ,MemoryReadsPerExecution = qs.total_logical_reads  / qs.execution_count  --Logical Reads are memory reads
     ,ReadsPerExecution  = NULLIF(qs.total_physical_reads +  qs.total_logical_reads,0) / qs.execution_count
     ,Executions         = qs.execution_count
     ,CPUTime            = qs.total_worker_time
     ,DiskWaitAndCPUTime = qs.total_elapsed_time
     ,MAXMemoryWrites_InSingleExecution     = qs.max_logical_writes --Maximum number of logical writes that this plan has ever performed during a single execution.
	 ,MAXMemoryRead_InSingleExecution        = qs.max_logical_reads --Maximum number of logical reads that this plan has ever performed during a single execution.
     ,DateCached         = qs.creation_time
     ,DatabaseName       = DB_Name(qt.dbid)
     ,LastExecutionTime  = qs.last_execution_time

 FROM sys.dm_exec_query_stats AS qs
 CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
  ORDER BY qs.total_physical_reads +  qs.total_logical_reads DESC


 SELECT CASE WHEN dbid = 32767 then 'Resource' ELSE DB_NAME(dbid)END AS DBName
      ,OBJECT_SCHEMA_NAME(objectid,dbid) AS [SCHEMA_NAME]  
      ,OBJECT_NAME(objectid,dbid)AS [OBJECT_NAME]
      ,MAX(qs.creation_time) AS 'cache_time'
      ,MAX(last_execution_time) AS 'last_execution_time'
      ,MAX(usecounts) AS [execution_count]
      ,SUM(total_worker_time) / SUM(usecounts) AS AVG_CPU
      ,SUM(total_elapsed_time) / SUM(usecounts) AS AVG_ELAPSED
      ,SUM(total_logical_reads) / SUM(usecounts) AS AVG_LOGICAL_READS
      ,SUM(total_logical_writes) / SUM(usecounts) AS AVG_LOGICAL_WRITES
      ,SUM(total_physical_reads) / SUM(usecounts)AS AVG_PHYSICAL_READS        
FROM sys.dm_exec_query_stats qs  
   join sys.dm_exec_cached_plans cp on qs.plan_handle = cp.plan_handle 
   CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) 
WHERE  text
       NOT LIKE '%CREATE FUNC%' 
       GROUP BY cp.plan_handle,DBID,objectid 



 /**********************************************************
*   top procedures memory consumption per execution
*   (this will show mostly reports &amp; jobs)
***********************************************************/
SELECT TOP 100 *
FROM 
(
    SELECT
         DatabaseName       = DB_NAME(qt.dbid)
        ,ObjectName         = OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
        ,DiskReads          = SUM(qs.total_physical_reads)   -- The worst reads, disk reads
        ,MemoryReads        = SUM(qs.total_logical_reads)    --Logical Reads are memory reads
        ,Executions         = SUM(qs.execution_count)
        ,IO_Per_Execution   = SUM((qs.total_physical_reads + qs.total_logical_reads) / qs.execution_count)
        ,CPUTime            = SUM(qs.total_worker_time)
        ,DiskWaitAndCPUTime = SUM(qs.total_elapsed_time)
        ,MemoryWrites       = SUM(qs.max_logical_writes)
        ,DateLastExecuted   = MAX(qs.last_execution_time)
        
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
    GROUP BY DB_NAME(qt.dbid), OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)

) T
ORDER BY IO_Per_Execution DESC

/**********************************************************
*   top procedures memory consumption total
*   (this will show more operational procedures)
***********************************************************/
SELECT TOP 100 *
FROM 
(
    SELECT
         DatabaseName       = DB_NAME(qt.dbid)
        ,ObjectName         = OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
        ,DiskReads          = SUM(qs.total_physical_reads)   -- The worst reads, disk reads
        ,MemoryReads        = SUM(qs.total_logical_reads)    --Logical Reads are memory reads
        ,Total_IO_Reads     = SUM(qs.total_physical_reads + qs.total_logical_reads)
        ,Executions         = SUM(qs.execution_count)
        ,IO_Per_Execution   = SUM((qs.total_physical_reads + qs.total_logical_reads) / qs.execution_count)
        ,CPUTime            = SUM(qs.total_worker_time)
        ,DiskWaitAndCPUTime = SUM(qs.total_elapsed_time)
        ,MemoryWrites       = SUM(qs.max_logical_writes)
        ,DateLastExecuted   = MAX(qs.last_execution_time)
        
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
    GROUP BY DB_NAME(qt.dbid), OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
) T
ORDER BY Total_IO_Reads DESC



/**********************************************************
*   top adhoc queries memory consumption total
***********************************************************/
SELECT TOP 100 *
FROM 
(
    SELECT
         DatabaseName       = DB_NAME(qt.dbid)
        ,QueryText          = qt.text       
        ,DiskReads          = SUM(qs.total_physical_reads)   -- The worst reads, disk reads
        ,MemoryReads        = SUM(qs.total_logical_reads)    --Logical Reads are memory reads
        ,Total_IO_Reads     = SUM(qs.total_physical_reads + qs.total_logical_reads)
        ,Executions         = SUM(qs.execution_count)
        ,IO_Per_Execution   = SUM((qs.total_physical_reads + qs.total_logical_reads) / qs.execution_count)
        ,CPUTime            = SUM(qs.total_worker_time)
        ,DiskWaitAndCPUTime = SUM(qs.total_elapsed_time)
        ,MemoryWrites       = SUM(qs.max_logical_writes)
        ,DateLastExecuted   = MAX(qs.last_execution_time)
        
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
    WHERE OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid) IS NULL
    GROUP BY DB_NAME(qt.dbid), qt.text, OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
) T
ORDER BY Total_IO_Reads DESC


/**********************************************************
*   top adhoc queries memory consumption per execution
***********************************************************/
SELECT TOP 100 *
FROM 
(
    SELECT
         DatabaseName       = DB_NAME(qt.dbid)
		 ,OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid) AS ProcName
        ,QueryText          = qt.text       
        ,Avg_DiskReads_Per_Excution          = SUM(qs.total_physical_reads)/qs.execution_count   -- The worst reads, disk reads
        ,Avg_MemoryReads_Per_Excution         = SUM(qs.total_logical_reads) /qs.execution_count   --Logical Reads are memory reads
        ,Avg_Total_IO_Reads_Per_Excution      = SUM(qs.total_physical_reads + qs.total_logical_reads)/qs.execution_count
        ,Executions         = SUM(qs.execution_count)
        ,Avg_IO_Per_Execution   = SUM((qs.total_physical_reads + qs.total_logical_reads) / qs.execution_count)
        ,Avg_CPUTime_Per_Excution             = SUM(qs.total_worker_time)/qs.execution_count
        ,Avg_DiskWaitAndCPUTime_Per_Excution  = SUM(qs.total_elapsed_time)/qs.execution_count
        ,MemoryWrites       = SUM(qs.max_logical_writes)
        ,DateLastExecuted   = MAX(qs.last_execution_time)
        
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
    WHERE OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)  IS NOT NULL
    GROUP BY DB_NAME(qt.dbid), qt.text, OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid),OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
) T
ORDER BY Executions DESC

/**********************************************************
*  show procedures that suffer from other wait types (disk, network, clr, parallelism, etc).
***********************************************************/


SELECT 
    OBJECT_NAME(objectid) 
    ,BlockTime = total_elapsed_time - total_worker_time
    ,execution_count 
    ,total_logical_reads 
FROM sys.dm_exec_query_stats qs
CROSS apply sys.dm_exec_sql_text(qs.sql_handle) 
WHERE OBJECT_NAME(objectid)  IS NOT NULL
ORDER BY total_elapsed_time - total_worker_time DESC



/**********************************************************
*  query shows the execution count of each stored procedure,
***********************************************************/


SELECT 
    DatabaseName        = DB_NAME(st.dbid) 
    ,SchemaName         = OBJECT_SCHEMA_NAME(st.objectid,dbid) 
    ,StoredProcedure    = OBJECT_NAME(st.objectid,dbid) 
    ,ExecutionCount     = MAX(cp.usecounts)
	
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE DB_NAME(st.dbid) IS NOT NULL 
AND cp.objtype = 'proc' AND OBJECT_NAME(st.objectid,dbid) = 'User_FraudScore_GetByUserID'
GROUP BY
    cp.plan_handle
    ,DB_NAME(st.dbid)
    ,OBJECT_SCHEMA_NAME(objectid,st.dbid)
    ,OBJECT_NAME(objectid,st.dbid) 
ORDER BY MAX(cp.usecounts) DESC



/***********************************************************
-- find counts of query re-use
***********************************************************/
SELECT * FROM
(
SELECT *, (SELECT object_name(objectid) FROM sys.dm_exec_sql_text(p.plan_handle)) AS SNAME
 FROM sys.dm_exec_cached_plans p 
 WHERE usecounts <= 1 
--and objtype != 'adhoc' --and objtype != 'prepared'
) t
WHERE SNAME IS NOT NULL
 ORDER BY usecounts, size_in_bytes DESC

/***********************************************************
-- find counts of query re-use
***********************************************************/

 SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name,
     ind.*,
     ic.*,
     col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
	  t.name LIKE 'ExcludedItem%'
ORDER BY 
     t.name, ind.name, ind.index_id, ic.index_column_id