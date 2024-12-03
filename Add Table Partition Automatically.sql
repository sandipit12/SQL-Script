-- find the partition functions which are required to be maintained
DROP TABLE IF EXISTS #temp
SELECT o.name as table_name, 
  pf.name as PartitionFunction, 
  ps.name as PartitionScheme, 
  MAX(rv.value) AS LastPartitionRange,
  CASE WHEN MAX(rv.value) <= DATEADD(MONTH, 2, GETDATE()) THEN 1 else 0 END AS isRequiredMaintenance
INTO #temp
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions pf ON pf.function_id = ps.function_id
INNER JOIN sys.partition_range_values rv ON pf.function_id = rv.function_id AND p.partition_number = rv.boundary_id
WHERE o.name  ='UserPageRequests'
GROUP BY o.name, pf.name, ps.name

--SELECT * FROM #temp

----insert information to the new temp table for those partition functions that are required to SPLIT
--SELECT * FROM Sys.master_files 
--WHERE DB_NAME(database_id) = 'Rslogs' AND file_id =1

DROP TABLE IF EXISTS #generateScript
SELECT table_name, 
  PartitionFunction, 
  PartitionScheme, 
  LastPartitionRange,
  CONVERT(VARCHAR, DATEADD(MONTH, 1, CAST(LastPartitionRange AS DATETIME)), 25) AS NewRange,
  'Rs_logs_'+table_name+'_' + LEFT(CONVERT(varchar, CAST(LastPartitionRange AS DATETIME),112),6) AS NewFileGroup,
  'Rs_logs_'+table_name+'_' + LEFT(CONVERT(varchar, CAST(LastPartitionRange AS DATETIME),112),6) AS FileName,
  'E:\' AS file_path
INTO #generateScript
FROM #temp
WHERE isRequiredMaintenance = 1
--SELECT * FROM #generateScript


DECLARE @filegroup NVARCHAR(MAX) = ''
DECLARE @file NVARCHAR(MAX) = ''
DECLARE @PScheme NVARCHAR(MAX) = ''
DECLARE @PFunction NVARCHAR(MAX) = ''
 
SELECT @filegroup = @filegroup + 
    CONCAT('IF NOT EXISTS(SELECT 1 FROM Rslogs.sys.filegroups WHERE name = ''',NewFileGroup,''')
    BEGIN
      ALTER DATABASE Rslogs ADD FileGroup ',NewFileGroup,' 
    END;'),
    @file = @file + CONCAT('IF NOT EXISTS(SELECT 1 FROM Rslogs.sys.database_files WHERE name = ''',FileName,''')
    BEGIN
    ALTER DATABASE Rslogs ADD FILE 
    (NAME = ''',FileName,''', 
    FILENAME = ''',File_Path,FileName,'.ndf'', 
    SIZE = 1MB024, MAXSIZE = UNLIMITED, 
    FILEGROWTH = 2048MB )
    TO FILEGROUP ',NewFileGroup, '
    END;'),
    @PScheme = @PScheme + CONCAT('ALTER PARTITION SCHEME ', PartitionScheme, ' NEXT USED ',NewFileGroup,';'),
    @PFunction = @PFunction + CONCAT('ALTER PARTITION FUNCTION ', PartitionFunction, '() SPLIT RANGE (''',NewRange,''');')
FROM #generateScript
 
EXEC (@filegroup)
EXEC (@file)
EXEC (@PScheme)
EXEC (@PFunction)

---- remove unused filegroups
--SELECT *
--FROM sys.filegroups fg
--LEFT OUTER JOIN sysfilegroups sfg
--    ON fg.name = sfg.groupname
--LEFT OUTER JOIN sysfiles f
--    ON sfg.groupid = f.groupid
--LEFT OUTER JOIN sys.allocation_units i
--    ON fg.data_space_id = i.data_space_id
--WHERE i.data_space_id IS NULL


--ALTER DATABASE Rslogs 
--REMOVE FILEGROUP Rslogs_RequestContentEntities_201911