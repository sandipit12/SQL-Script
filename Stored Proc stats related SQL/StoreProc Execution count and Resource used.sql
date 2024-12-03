WITH CTE_CreateDate
AS 
(
SELECT 'dbo.'+Name AS name,create_date,modify_date FROM sys.procedures

)

SELECT CTE_CreateDate.create_date,CTE_CreateDate.modify_date,main.* FROM
(

SELECT TOP 1000 *
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
	--WHERE OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid) = 'dbo.CommercialApplicationDetails_GetByBrokerID'
    GROUP BY DB_NAME(qt.dbid), OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)

) T
)Main
INNER JOIN CTE_CreateDate ON CTE_CreateDate.name = ObjectName
ORDER BY 
--CTE_CreateDate.create_date DESC,
CTE_CreateDate.modify_date DESC 
