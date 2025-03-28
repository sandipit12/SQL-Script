USE Venus_Live
;WITH CTE_TableStats
AS 
(
SELECT DB_NAME() AS DatabaseName, 
    t.NAME AS TableName,i.type_desc index_type,
	i.name AS IndexName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,p.data_compression_desc,
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
	
GROUP BY 
    t.Name, s.Name, p.Rows,i.NAME ,p.data_compression_desc,i.type_desc 

),

/*
S: The percentage of scan operations on a table, index, or partition, relative to total operations on that object. The higher the value of S (that is, the table, index, or partition is mostly scanned), the better candidate it is for page compression.
To compute S, use the statistics in the DMV sys.dm_db_index_operational_stats. 
S is the ratio (expressed in percent) of scans performed on a table or index 
to the sum of all operations (scans + DMLs + lookups) on that table or index. 
In other words, S represents how heavily the table or index is scanned. 
The following query reports S for each table, index, and partition in the database.
*/

CTE_Scan 
AS
(
 
SELECT o.name AS [Table_Name], x.name AS [Index_Name],
i.partition_number AS [Partition],
i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
i.leaf_update_count * 100.0 / (i.range_scan_count + i.leaf_insert_count + i.leaf_delete_count + i.leaf_update_count + i.leaf_page_merge_count + i.singleton_lookup_count ) AS [Percent_Update],
sp.data_compression
FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.indexes x ON x.object_id = i.object_id AND x.index_id = i.index_id
JOIN sys.partitions sp ON sp.object_id = o.object_id AND sp.index_id = i.index_id
INNER JOIN sys.tables ST ON st.object_id = o.object_id 
WHERE (i.range_scan_count + i.leaf_insert_count + i.leaf_delete_count + leaf_update_count + i.leaf_page_merge_count + i.singleton_lookup_count) != 0
AND objectproperty(i.object_id,'IsUserTable') = 1 
),

----https://dzone.com/articles/when-to-use-row-or-page-compression-in-sql-server
/*

The percentage of update operations on a specific table, index, or partition, relative to total operations on that object. The lower the value of U (that is, the table, index, or partition is infrequently updated), the better candidate it is for page compression.
To compute U, use the statistics in the DMV sys.dm_db_index_operational_stats. 
U is the ratio (expressed in percent) of updates performed on a table or index
to the sum of all operations (scans + DMLs + lookups) on that table or index. 
The following query reports U for each table and index in the database. 
*/

CTE_Update
AS
(
SELECT o.name AS [Table_Name], x.name AS [Index_Name],
i.partition_number AS [Partition],
i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
i.range_scan_count * 100.0 / (i.range_scan_count + i.leaf_insert_count + i.leaf_delete_count + i.leaf_update_count + i.leaf_page_merge_count + i.singleton_lookup_count ) AS [Percent_Scan],
sp.data_compression
FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.indexes x ON x.object_id = i.object_id AND x.index_id = i.index_id
JOIN sys.partitions sp ON sp.object_id = o.object_id AND sp.index_id = i.index_id
INNER JOIN sys.tables ST ON st.object_id = o.object_id 
WHERE (i.range_scan_count + i.leaf_insert_count + i.leaf_delete_count + leaf_update_count + i.leaf_page_merge_count + i.singleton_lookup_count) != 0 
AND objectproperty(i.object_id,'IsUserTable') = 1

)
SELECT Tab.DatabaseName,Tab.TableName,TAB.IndexName,Tab.Index_type,Tab.RowCounts,Tab.TotalSpaceMB,data_compression_desc CurrentCompressionSetting,CTE_Scan.Percent_Update,CTE_Update.Percent_Scan FROM CTE_TableStats Tab 
LEFT JOIN CTE_Scan ON CTE_Scan.Table_Name = Tab.TableName AND CTE_Scan.Index_Name = tab.IndexName
LEFT JOIN CTE_Update ON CTE_Update.Table_Name = tab.TableName AND  CTE_Update.Index_Name = Tab.IndexName



--SELECT * FROM sys.partitions