
-- Get top total logical reads queries for entire instance (Query 46) (Top Logical Reads Queries)
SELECT  DB_NAME(t.[dbid]) AS [Database Name],
REPLACE(REPLACE(LEFT(t.[text], 255), CHAR(10),''), CHAR(13),'') AS [Short Query Text],
OBJECT_NAME(object_id,database_id)AS StoredProcName,
qs.total_logical_reads AS [Total Logical Reads],
qs.min_logical_reads AS [Min Logical Reads],
qs.total_logical_reads/qs.execution_count AS [Avg Logical Reads],
qs.max_logical_reads AS [Max Logical Reads],   
qs.min_worker_time AS [Min Worker Time],
qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
qs.max_worker_time AS [Max Worker Time], 
qs.min_elapsed_time AS [Min Elapsed Time], 
qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
qs.max_elapsed_time AS [Max Elapsed Time],
qs.execution_count AS [Execution Count], qs.creation_time AS [Creation Time]
-- ,t.[text] AS [Complete Query Text], qp.query_plan AS [Query Plan] -- uncomment out these columns if not copying results to Excel
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
LEFT JOIN sys.dm_exec_procedure_stats  ps ON ps.plan_handle = qs.plan_handle
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS t 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp 
ORDER BY qs.total_logical_reads DESC OPTION (RECOMPILE);
------

-- Get top total worker time queries for entire instance (Query 41) (Top Worker Time Queries)
SELECT TOP(50) DB_NAME(t.[dbid]) AS [Database Name], 
REPLACE(REPLACE(LEFT(t.[text], 255), CHAR(10),''), CHAR(13),'') AS [Short Query Text],  
qs.total_worker_time AS [Total Worker Time], qs.min_worker_time AS [Min Worker Time],
qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
qs.max_worker_time AS [Max Worker Time], 
qs.min_elapsed_time AS [Min Elapsed Time], 
qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
qs.max_elapsed_time AS [Max Elapsed Time],
qs.min_logical_reads AS [Min Logical Reads],
qs.total_logical_reads/qs.execution_count AS [Avg Logical Reads],
qs.max_logical_reads AS [Max Logical Reads], 
qs.execution_count AS [Execution Count], qs.creation_time AS [Creation Time]
--,t.[text] AS [Query Text], qp.query_plan AS [Query Plan] -- uncomment out these columns if not copying results to Excel
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);

-- Get top average elapsed time queries for entire instance (Query 47) (Top Avg Elapsed Time Queries)
SELECT TOP(50) DB_NAME(t.[dbid]) AS [Database Name], 
REPLACE(REPLACE(LEFT(t.[text], 255), CHAR(10),''), CHAR(13),'') AS [Short Query Text],  
qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time],
qs.min_elapsed_time, qs.max_elapsed_time, qs.last_elapsed_time,
qs.execution_count AS [Execution Count],  
qs.total_logical_reads/qs.execution_count AS [Avg Logical Reads], 
qs.total_physical_reads/qs.execution_count AS [Avg Physical Reads], 
qs.total_worker_time/qs.execution_count AS [Avg Worker Time],
qs.creation_time AS [Creation Time]
, qp.query_plan AS [Query Plan] -- comment out this column if copying results to Excel
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
--ORDER BY qs.total_elapsed_time/qs.execution_count DESC OPTION (RECOMPILE);


-- Top Cached SPs By Execution Count (Query 52) (SP Execution Counts)
SELECT TOP(100) p.name AS [SP Name], qs.execution_count,
ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], qs.total_worker_time AS [TotalWorkerTime],  
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time],
qs.cached_time
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
AND DATEDIFF(Minute, qs.cached_time, GETDATE()) > 0
ORDER BY qs.execution_count DESC OPTION (RECOMPILE);
------
------