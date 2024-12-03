--SQL Server Database Files Wise I/O Latency Details PART#1
/*
I/O Latency Threshold Value:
You might be wondering what would be I/O latency threshold for the DMF. It will be the same threshold value what we have for the performance counter. To know the threshold value, you can follow the below threshold values or  Paul’s blog;
< 1ms  – – – – – – – ->Excellent
< 5ms  – – – – – – – ->Very good
5 – 10ms  – – – – – – >Good
10 – 20ms – – – – – ->Poor
20 – 100ms – – – – ->Bad
100 – 500ms – – – ->Shockingly bad
> 500ms – – – – – – >God Bless the storage system
The DMF shows values since the database came online. Therefore, the spikes of poor performance will be masked by the overall aggregation. It is recommended to capture the I/O statistics from the DMF over a  period of time and do a through comparison before reach at conclusion.
*/
SELECT
DB_NAME(fs.database_id) AS [database name],
CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms],
CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms],
CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)
/(1.0 + fs.num_of_reads + fs.num_of_writes) 
AS NUMERIC(10,1)) AS [avg_io_stall_ms],
CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)],
mf.physical_name,
mf.type_desc,
fs.io_stall_read_ms,
fs.num_of_reads,
fs.io_stall_write_ms,
fs.num_of_writes,
fs.io_stall_read_ms + fs.io_stall_write_ms AS [io_stalls],
fs.num_of_reads + fs.num_of_writes AS [total_io]
FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK) ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]
ORDER BY avg_io_stall_ms DESC OPTION (RECOMPILE);