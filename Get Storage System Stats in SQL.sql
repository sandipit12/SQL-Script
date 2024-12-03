/*https://www.sqlshack.com/how-to-analyze-storage-subsystem-performance-in-sql-server */

;WITH AggregateIOStatistics
AS
(
SELECT DB_NAME(database_id) AS [DB Name],FILE_ID,
CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
GROUP BY database_id,FILE_ID
)
SELECT 'I/O utilization by database files ',mf.physical_name,(cast(size as float)*8)/1024/1024 as FILE_SIZE_GB,ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank], [DB Name], io_in_mb AS [Total I/O (MB)],
       CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
FROM sys.master_files mf JOIN AggregateIOStatistics a ON a.[DB Name] = db_name(mf.database_id) AND mf.file_id = a.file_id
ORDER BY [I/O Rank] 

;WITH AggregateIOStatistics
AS
(SELECT DB_NAME(database_id) AS [DB Name],
CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
GROUP BY database_id)
SELECT 'I/O utilization by database',ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank], [DB Name], io_in_mb AS [Total I/O (MB)],
       CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
FROM AggregateIOStatistics
ORDER BY [I/O Rank] 

;WITH AggregateIOStatistics
AS
(
SELECT DB_NAME(database_id) AS [DB Name],FILE_ID,
CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
GROUP BY database_id,FILE_ID
),
CTE_Drive
AS 
(
SELECT LEFT(mf.physical_name,1)Drive,((cast(size as float)*8)/1024/1024) as FILE_SIZE_GB,
       (io_in_mb) AS [Total I/O (MB)],
       CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
FROM sys.master_files mf JOIN AggregateIOStatistics a ON a.[DB Name] = db_name(mf.database_id) AND mf.file_id = a.file_id
)

SELECT 'I/O utilization by database files ',Drive,SUM(CTE_Drive.FILE_SIZE_GB) TotalDBFileSize,SUM([Total I/O (MB)]) AS [Total I/O (MB)],SUM([I/O Percent]) [Total I/O Percent on Drive]
FROM CTE_Drive
GROUP BY CTE_Drive.Drive
ORDER BY [Total I/O Percent on Drive] desc

EXEC sys.xp_fixeddrives