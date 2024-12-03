DROP TABLE IF EXISTS #temptable
CREATE TABLE #temptable ( [DBNAME] nvarchar(128), [actual_state_desc] nvarchar(60), [desired_state_desc] nvarchar(60), [max_storage_size_mb] bigint, [current_storage_size_mb] bigint, [flush_interval_seconds] bigint, [max_plans_per_query] bigint, [interval_length_minutes] bigint, [query_capture_mode_desc] nvarchar(60), [stale_query_threshold_days] bigint, [size_based_cleanup_mode_desc] nvarchar(60), [wait_stats_capture_mode_desc] nvarchar(60), [readonly_reason] int )

DECLARE @command VARCHAR(1000) 
SELECT @command = ' USE ? INSERT INTO #temptable SELECT DB_NAME()DBNAME,[actual_state_desc],
       [desired_state_desc],
       max_storage_size_mb,  --default value is 100MB
       current_storage_size_mb,
       flush_interval_seconds, -- frequncy of data get persisted to disk 
       max_plans_per_query, -- number plan per Query default 200 plan per query
	   interval_length_minutes, -- Data point default 60 min.Can be reduce to 30 min to get more granular level fixed values for this settings (1, 5, 10, 15, 30, 60, 1440)
       query_capture_mode_desc, -- All Will capture everything. Should Chnage to Auto that filter out ad-hoc queries with small resource consumption.
       stale_query_threshold_days, -- 300 days should  be okm
       size_based_cleanup_mode_desc,--recommended to leave this set to AUTO 
       wait_stats_capture_mode_desc,
       readonly_reason
FROM [sys].[database_query_store_options];
' 
EXEC sp_MSforeachdb @command 
SELECT * FROM #temptable ORDER BY DBNAME




SELECT p.plan_id, p.query_id, q.object_id as containing_object_id,
    force_failure_count, last_force_failure_reason_desc
FROM sys.query_store_plan AS p
JOIN sys.query_store_query AS q on p.query_id = q.query_id
WHERE is_forced_plan = 1;





