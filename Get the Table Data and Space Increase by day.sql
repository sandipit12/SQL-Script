

DROP TABLE IF EXISTS #TempTableStats
CREATE TABLE #TempTableStats ([DBName] varchar(30),TableName VARCHAR(100),[NumRows] VARCHAR(100) ,[SizeMB] VARCHAR(100) ,CollectionDate  Datetime)

USE RSLogs
        DROP TABLE IF EXISTS #RowCountsAndSizes
		CREATE TABLE #RowCountsAndSizes (TableName NVARCHAR(128),rows CHAR(11), 
		reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18), 
		unused VARCHAR(18))

		--TRUNCATE TABLE  #TempTableStats

		EXEC sp_MSForEachTable 'INSERT INTO #RowCountsAndSizes EXEC sp_spaceused ''?'' '

		; WITH TABLES_ROWS_AND_SIZE AS
		(
		SELECT TableName
		, NumberOfRows = CONVERT(bigint,rows)
		, SizeinMB = CONVERT(bigint,left(reserved,len(reserved)-3))
		FROM #RowCountsAndSizes 
		)


		INSERT INTO  #TempTableStats( [DBName], [TableName], [NumRows], [SizeMB],[CollectionDate])
		SELECT 'RSlogs', TableName,	NumRows = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,NumberOfRows),1), '.00',''),SizeinMB = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,SizeinMB/1000),1), '.00',''),GETDATE()
		FROM TABLES_ROWS_AND_SIZE

		DROP TABLE #RowCountsAndSizes
		GO

USE Venus_Live
         CREATE TABLE #RowCountsAndSizes (TableName NVARCHAR(128),rows CHAR(11), 
		reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18), 
		unused VARCHAR(18))

		--TRUNCATE TABLE  #TempTableStats

		EXEC sp_MSForEachTable 'INSERT INTO #RowCountsAndSizes EXEC sp_spaceused ''?'' '

		; WITH TABLES_ROWS_AND_SIZE AS
		(
		SELECT TableName
		, NumberOfRows = CONVERT(bigint,rows)
		, SizeinMB = CONVERT(bigint,left(reserved,len(reserved)-3))
		FROM #RowCountsAndSizes 
		)

		INSERT INTO #TempTableStats( [DBName], [TableName], [NumRows], [SizeMB],[CollectionDate])
		SELECT 'Venus_Live', TableName,	NumRows = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,NumberOfRows),1), '.00',''),SizeinMB = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,SizeinMB/1000),1), '.00',''),GETDATE()
		FROM TABLES_ROWS_AND_SIZE

		DROP TABLE #RowCountsAndSizes
GO

USE RSDocuments
         CREATE TABLE #RowCountsAndSizes (TableName NVARCHAR(128),rows CHAR(11), 
		reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18), 
		unused VARCHAR(18))

		--TRUNCATE TABLE  #TempTableStats

		EXEC sp_MSForEachTable 'INSERT INTO #RowCountsAndSizes EXEC sp_spaceused ''?'' '

		; WITH TABLES_ROWS_AND_SIZE AS
		(
		SELECT TableName
		, NumberOfRows = CONVERT(bigint,rows)
		, SizeinMB = CONVERT(bigint,left(reserved,len(reserved)-3))
		FROM #RowCountsAndSizes 
		)

		INSERT INTO #TempTableStats( [DBName], [TableName], [NumRows], [SizeMB],[CollectionDate])
		SELECT 'RSDocuments', TableName,	NumRows = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,NumberOfRows),1), '.00',''),SizeinMB = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,SizeinMB/1000),1), '.00',''),GETDATE()
		FROM TABLES_ROWS_AND_SIZE

		DROP TABLE #RowCountsAndSizes
GO

		

USE DecisionEngine

         CREATE TABLE #RowCountsAndSizes (TableName NVARCHAR(128),rows CHAR(11), 
		reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18), 
		unused VARCHAR(18))

		--TRUNCATE TABLE  #TempTableStats

		EXEC sp_MSForEachTable 'INSERT INTO #RowCountsAndSizes EXEC sp_spaceused ''?'' '

		; WITH TABLES_ROWS_AND_SIZE AS
		(
		SELECT TableName
		, NumberOfRows = CONVERT(bigint,rows)
		, SizeinMB = CONVERT(bigint,left(reserved,len(reserved)-3))
		FROM #RowCountsAndSizes 
		)

		INSERT INTO #TempTableStats( [DBName], [TableName], [NumRows], [SizeMB],[CollectionDate])
		SELECT 'DecisionEngine', TableName,	NumRows = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,NumberOfRows),1), '.00',''),SizeinMB = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,SizeinMB/1000),1), '.00',''),GETDATE()
		FROM TABLES_ROWS_AND_SIZE

		DROP TABLE #RowCountsAndSizes
GO
USE Venus_LogsAdmin

        CREATE TABLE #RowCountsAndSizes (TableName NVARCHAR(128),rows CHAR(11), 
		reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18), 
		unused VARCHAR(18))

		--TRUNCATE TABLE  #TempTableStats

		EXEC sp_MSForEachTable 'INSERT INTO #RowCountsAndSizes EXEC sp_spaceused ''?'' '

		; WITH TABLES_ROWS_AND_SIZE AS
		(
		SELECT TableName
		, NumberOfRows = CONVERT(bigint,rows)
		, SizeinMB = CONVERT(bigint,left(reserved,len(reserved)-3))
		FROM #RowCountsAndSizes 
		)

		INSERT INTO #TempTableStats( [DBName], [TableName], [NumRows], [SizeMB],[CollectionDate])
		SELECT 'Venus_LogsAdmin', TableName,	NumRows = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,NumberOfRows),1), '.00',''),SizeinMB = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,SizeinMB/1000),1), '.00',''),GETDATE()
		FROM TABLES_ROWS_AND_SIZE

		DROP TABLE #RowCountsAndSizes

		GO  


		




	


;with minmax as ( -- subquery to get min / max data per user
    select
        temp.dbname,temp.tablename
        ,min(t.Collectiondate) as minCollectiondate
        ,min(t.NumRows) as minNumRows
		,min(t.SizeMB) as minSizeMB
        ,max(temp.Collectiondate) as maxCollectiondate
        ,MAX(temp.NumRows) as MaxNumRows
		,MAX(temp.SizeMB) as MaxSizeMB
    from
        #TempTableStats temp LEFT JOIN [Tools].[dbo].[TableSizeAndSpace] t  ON t.dbname = temp.dbname AND t.tablename = temp.tablename
	WHERE CAST(REPLACE(temp.NumRows,',','' ) AS Bigint )  <> 0 AND  CAST(REPLACE(temp.SizeMB,',','' ) AS Bigint )  <> 0
    group BY temp.dbname,temp.tablename 
)
,averageincrease as ( -- subquery to calculate average daily increase
    select
         dbname,tablename
        ,datediff(DAY, minCollectiondate, maxCollectiondate) as numdays
        , CAST(REPLACE(MaxNumRows,',','' ) AS Bigint ) - CAST(REPLACE( minNumRows,',','') AS BIGINT) AS totalincrease_NumRows
		, CAST(REPLACE(MaxSizeMB ,',','' ) AS Bigint ) - CAST(REPLACE( minSizeMB ,',','') AS BIGINT) AS totalincrease_SizeMB
        ,(CAST(REPLACE(MaxSizeMB ,',','' ) AS Bigint ) - CAST(REPLACE( minSizeMB ,',','') AS BIGINT)) / datediff(DAY, minCollectiondate, maxCollectiondate) AS averagedailyincrease_SizeMB
		,(CAST(REPLACE(MaxNumRows,',','' ) AS Bigint ) - CAST(REPLACE( minNumRows,',','') AS BIGINT)) / datediff(DAY, minCollectiondate, maxCollectiondate) AS averagedailyincrease_NumRows
    from
        minmax

)
-- pull results together, with highest average daily increase first
SELECT
    *
FROM
    averageincrease
ORDER BY averageincrease.totalincrease_NumRows desc



