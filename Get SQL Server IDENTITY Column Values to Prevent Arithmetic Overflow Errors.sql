USE Venus_Live

-- define the max value for each data type
CREATE TABLE #DataTypeMaxValue (DataType varchar(50), MaxValue bigint)

INSERT INTO #DataTypeMaxValue VALUES 
   ('tinyint' , 255),
   ('smallint' , 32767),
   ('int' , 2147483647),
   ('bigint' , 9223372036854775807)

-- retrieve identity column information
SELECT * FROM
(
SELECT 
   distinct OBJECT_NAME (IC.object_id) AS TableName,
   IC.name AS ColumnName,
   TYPE_NAME(IC.system_type_id) AS ColumnDataType,
   DTM.MaxValue AS MaxDataTypeValue,
   IC.seed_value IdentitySeed,
   IC.increment_value AS IdentityIncrement, 
   IC.last_value,IDX.type_desc,
   REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, DBPS.row_count),1), '.00','') NumberOfRow ,
   CAST(IC.last_value AS INT) - DBPS.row_count AS [Number Of Records deleted],
   REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,CAST(IC.last_value AS INT) - DBPS.row_count),1), '.00','') [Number Of Records deleted With thousand separators],
   (convert(decimal(18,2),CONVERT(bigint,IC.last_value)*100/DTM.MaxValue)) AS ReachMaxValuePercent 
FROM sys.identity_columns IC
   JOIN sys.tables TN ON IC.object_id = TN.object_id
   JOIN #DataTypeMaxValue DTM ON TYPE_NAME(IC.system_type_id)=DTM.DataType
   JOIN sys.dm_db_partition_stats DBPS ON DBPS.object_id =IC.object_id AND DBPS.index_id =1
   JOIN sys.indexes as IDX ON DBPS.index_id =IDX.index_id 
WHERE DBPS.row_count >0 
) A
WHERE a.type_desc = 'CLUSTERED'
ORDER BY [Number Of Records deleted]  DESC

DROP TABLE #DataTypeMaxValue

