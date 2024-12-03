USE DWH_Test


DROP TABLE IF EXISTS #TempTableStats
CREATE TABLE #TempTableStats ([DBName] VARCHAR(30),TableName VARCHAR(100),[NumRows] VARCHAR(100) ,[SizeMB] VARCHAR(100) ,CollectionDate  DATETIME)


        DROP TABLE IF EXISTS #RowCountsAndSizes
		CREATE TABLE #RowCountsAndSizes (TableName NVARCHAR(128),rows CHAR(11), 
		reserved VARCHAR(18),data VARCHAR(18),index_size VARCHAR(18), 
		unused VARCHAR(18) )

		--TRUNCATE TABLE  #TempTableStats

		EXEC sp_MSForEachTable 'INSERT INTO #RowCountsAndSizes EXEC sp_spaceused ''?'' '

		; WITH TABLES_ROWS_AND_SIZE AS
		(
		SELECT TableName
		, NumberOfRows = CONVERT(bigint,rows)
		, SizeinMB = CONVERT(bigint,left(reserved,len(reserved)-3))
		, CONVERT(bigint,left(reserved,len(reserved)-3)) as SizeInMBForOrderby 
		FROM #RowCountsAndSizes 
		)


		
		SELECT DB_NAME(), TableName,	NumRows = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,NumberOfRows),1), '.00',''),SizeinMB = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,SizeinMB/1000),1), '.00',''),GETDATE()
		FROM TABLES_ROWS_AND_SIZE
		WHERE TableName LIKE '%MasterUserSnapshot%'
		ORDER BY SizeInMBForOrderby DESC
		DROP TABLE #RowCountsAndSizes
		GO

--DWH_Test	FactMasterUserSnapshot			33,570,569	171,435	2024-03-12 11:11:38.277
--DWH_Test	MasterUserSnapshot				244,306,741	126,743	2024-03-12 11:11:38.277
--DWH_Test	DimMasterUserSnapshotProfile	72			0		2024-03-12 11:11:38.277
