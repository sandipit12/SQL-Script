 --Creates the ALTER TABLE Statements

SET NOCOUNT ON

SELECT i.index_id,
   'ALTER TABLE [' 
   + s.[name] 
   + '].[' 
   + o.[name] 
   + '] REBUILD WITH (DATA_COMPRESSION=PAGE);'
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
   ON o.[object_id] = i.[object_id]
INNER JOIN sys.schemas AS s WITH (NOLOCK)
   ON o.[schema_id] = s.[schema_id]
INNER JOIN sys.dm_db_partition_stats AS ps WITH (NOLOCK)
   ON i.[object_id] = ps.[object_id]
AND ps.[index_id] = i.[index_id]
INNER JOIN sys.partitions SP 
	ON sp.object_id = i.object_id and sp.index_id = i.index_id
WHERE o.[type] = 'U' AND sp.data_compression =  0
--AND s.Name LIKE '%%'   -- filter by table name
--AND o.Name LIKE '%%'   -- filter by schema name
ORDER BY ps.[reserved_page_count]

SET NOCOUNT OFF


--Creates the ALTER INDEX Statements

SET NOCOUNT ON

SELECT i.index_id,
   'ALTER INDEX [' 
   + i.[name] 
   + '] ON [' 
   + s.[name] 
   + '].[' 
   + o.[name] 
   + '] REBUILD WITH (DATA_COMPRESSION=PAGE);'
FROM sys.objects AS o WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK)
   ON o.[object_id] = i.[object_id]
INNER JOIN sys.schemas s WITH (NOLOCK)
   ON o.[schema_id] = s.[schema_id]
INNER JOIN sys.dm_db_partition_stats AS ps WITH (NOLOCK)
   ON i.[object_id] = ps.[object_id]
AND ps.[index_id] = i.[index_id]
INNER JOIN sys.partitions SP 
	ON sp.object_id = i.object_id and sp.index_id = i.index_id
WHERE o.type = 'U' 
AND i.[index_id] >0
--AND i.Name LIKE '%%'   -- filter by index name
--AND o.Name LIKE '%LoanContractPayments%'   -- filter by table name
AND sp.data_compression = 0
ORDER BY ps.[reserved_page_count]

SET NOCOUNT OFF