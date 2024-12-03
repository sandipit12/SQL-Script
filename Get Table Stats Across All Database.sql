declare @SQL nvarchar(max)
DROP TABLE IF EXISTS  #temptable
CREATE TABLE #temptable ( [Database Name] varchar(50), [TableName] nvarchar(128), [SchemaName] nvarchar(128), [rows] bigint, [TotalSpaceGB] decimal(36,2), [Last ID Value] sql_variant, [MAX_LENGTH] bigint, [Percentage of IDs Used] decimal(5,2), [Remaining_IDs] BIGINT,
                          DB_Size_GB bigint )

set @SQL = ''
--select * from sys.databases 
select @SQL = @SQL + CHAR(13) + 'USE ' + QUOTENAME(d.[name]) + ';
INSERT INTO #temptable ([Database Name], [TableName], [SchemaName], [rows], [TotalSpaceGB], [Last ID Value], [MAX_LENGTH], [Percentage of IDs Used], [Remaining_IDs])

SELECT ' +quotename(d.[name],'''') + 'as [Database Name], t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows,    
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00 / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceGB,
	last_value AS [Last ID Value],     
    MAX_LENGTH,
    CAST(cast(last_value as bigint) / 2147483647.0 * 100.0 AS DECIMAL(5,2)) AS [Percentage of IDs Used], 
    2147483647 - cast(last_value as bigint) AS Remaining_IDs
	
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
Inner Join 
	sys.identity_columns SIC on SIC.object_id = t.object_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE ''dt%'' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows,last_value,MAX_LENGTH
ORDER BY 
    [TotalSpaceGB] DESC, t.Name
	' 
	FROM sys.databases  d --JOIN sys.master_files mf ON  d.database_id = mf.database_id
	WHERE (d.database_id) >5 AND d.state_desc = 'Online'

EXECUTE (@SQL)    


;WITH cte 
AS
(
 SELECT  d.NAME
        ,(SUM(CAST(mf.size AS BIGINT)) * 8 / 1024) / 1024 AS Size_GBs
FROM sys.master_files mf
INNER JOIN sys.databases d ON d.database_id = mf.database_id
WHERE d.database_id > 4 -- Skip system databases
GROUP BY d.NAME
)


UPDATE  #temptable set DB_Size_GB = Size_GBs
FROM #temptable t JOIN cte ON cte.name = t.[Database Name]
	
-- Top table by space across all DB
SELECT 'Top table by space across all DB', * FROM #temptable --WHERE-- [Database Name] IN (SELECT  DISTINCT [Database Name] FROM #temptable ORDER BY DB_Size_GB DESC)
ORDER BY TotalSpaceGB DESC,DB_Size_GB desc

--Top table Identity column usage and likely to fail when reach the limit 
SELECT TOP 10 'Top table by Identity column usage and likely to fail when reach the limit ',
  [Database Name],TableName,[Last ID Value],[Percentage of IDs Used] 
  FROM #temptable --WHERE-- [Database Name] IN (SELECT  DISTINCT [Database Name] FROM #temptable ORDER BY DB_Size_GB DESC)
  GROUP BY [Database Name],TableName,[Last ID Value],[Percentage of IDs Used]
ORDER BY [Percentage of IDs Used] DESC
