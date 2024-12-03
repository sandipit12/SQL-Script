DECLARE @OldestParitionDate DATE;
DECLARE @Parition_to_Switch INT;
DECLARE @FileGroup VARCHAR(50);

SELECT @OldestParitionDate = DATEADD(M, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)); -- Get the Partition Range Value for 7th month from today 


SELECT pstats.row_count,
       pstats.row_count AS PartitionRowCount,
       CAST(prv.value AS DATE) AS PartitionBoundaryValue,
       pstats.partition_number AS PartitionNumber,
       OBJECT_SCHEMA_NAME(pstats.object_id) AS SchemaName,
       OBJECT_NAME(pstats.object_id) AS TableName,
       ds.name AS PartitionFilegroupName,
       CASE pf.boundary_value_on_right
           WHEN 0 THEN
               'Range Left'
           ELSE
               'Range Right'
       END AS PartitionFunctionRange,
       CASE pf.boundary_value_on_right
           WHEN 0 THEN
               'Upper Boundary'
           ELSE
               'Lower Boundary'
       END AS PartitionBoundary,
       c.name AS PartitionKey,
       CASE
           WHEN pf.boundary_value_on_right = 0 THEN
               c.name + ' > '
               + CAST(ISNULL(   LAG(prv.value) OVER (PARTITION BY pstats.object_id
                                                     ORDER BY pstats.object_id,
                                                              pstats.partition_number
                                                    ),
                                'Infinity'
                            ) AS VARCHAR(100)) + ' and ' + c.name + ' <= '
               + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100))
           ELSE
               c.name + ' >= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) + ' and ' + c.name + ' < '
               + CAST(ISNULL(   LEAD(prv.value) OVER (PARTITION BY pstats.object_id
                                                      ORDER BY pstats.object_id,
                                                               pstats.partition_number
                                                     ),
                                'Infinity'
                            ) AS VARCHAR(100))
       END AS PartitionRange,
       p.data_compression_desc AS DataCompression
FROM sys.dm_db_partition_stats AS pstats
    INNER JOIN sys.partitions AS p
        ON pstats.partition_id = p.partition_id
    INNER JOIN sys.destination_data_spaces AS dds
        ON pstats.partition_number = dds.destination_id
    INNER JOIN sys.data_spaces AS ds
        ON dds.data_space_id = ds.data_space_id
    INNER JOIN sys.partition_schemes AS ps
        ON dds.partition_scheme_id = ps.data_space_id
    INNER JOIN sys.partition_functions AS pf
        ON ps.function_id = pf.function_id
    INNER JOIN sys.indexes AS i
        ON pstats.object_id = i.object_id
           AND pstats.index_id = i.index_id
           AND dds.partition_scheme_id = i.data_space_id
           AND i.type <= 1 /* Heap or Clustered Index */
    INNER JOIN sys.index_columns AS ic
        ON i.index_id = ic.index_id
           AND i.object_id = ic.object_id
           AND ic.partition_ordinal > 0
    INNER JOIN sys.columns AS c
        ON pstats.object_id = c.object_id
           AND ic.column_id = c.column_id
    LEFT JOIN sys.partition_range_values AS prv
        ON pf.function_id = prv.function_id
           AND pstats.partition_number = (CASE pf.boundary_value_on_right
                                              WHEN 0 THEN
                                                  prv.boundary_id
                                              ELSE
        (prv.boundary_id + 1)
                                          END
                                         )
WHERE OBJECT_NAME(p.object_id) = 'RequestContentEntities'
      AND prv.value <= @OldestParitionDate;

SELECT DISTINCT o.name as table_name, rv.value as partition_range, fg.name as file_groupName, p.partition_number, p.rows as number_of_rows
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id
INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number
INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id 
LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
WHERE o.object_id = OBJECT_ID('UserPageRequests');