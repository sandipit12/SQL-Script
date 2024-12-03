-- File names and paths for all user and system databases on instance  (Query 25) (Database Filenames and Paths)
SELECT DB_NAME([database_id]) AS [Database Name], 
       [file_id], [name], physical_name, [type_desc], state_desc,
	   is_percent_growth, growth,
	   CONVERT(bigint, growth/128.0) AS [Growth in MB], 
       CONVERT(bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE  DB_NAME([database_id]) NOT IN ('master','Model','tempdb','msdb')
ORDER BY DB_NAME([database_id]), [file_id] OPTION (RECOMPILE);