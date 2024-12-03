DROP TABLE IF EXISTS #TempTable 
CREATE TABLE #TempTable ( DBName VARCHAR(100), 
                         [TableName] varchar(100),
						 ColumnName VARCHAR(100), 
						 [Log_MaxLength] bigint, 
						 [Log_RowCount] INT,
						 TABLESCHEMA Varchar(10),
						 Command varchar(Max),
						 character_maximum_length INT ) 
DROP TABLE IF EXISTS #TempTableFinalResult 
CREATE TABLE #TempTableFinalResult
                       ( DBName VARCHAR(100), 
                       [TableName] varchar(100),
						 ColumnName VARCHAR(100), 
						 [MaxLength] bigint, 
						 [RowCount] INT,
						 character_maximum_length INT) 

	DECLARE @DB_Name varchar(100)
	DECLARE @Command nvarchar(MAX) 
	DECLARE database_cursor CURSOR FOR
		SELECT name FROM MASTER.sys.sysdatabases
		WHERE dbid > 5 AND 
			  dbid NOT IN (19) AND 
			  name <> 'Venus_Live' 
	OPEN database_cursor FETCH NEXT
	FROM database_cursor INTO @DB_Name 
		WHILE @@FETCH_STATUS = 0 
			BEGIN
				SET @Command = 
				              'use ' + '' + @DB_Name + '' + '
					;WITH CTE_Tables (DBName,[TableName],[ColumnName],TABLESCHEMA,character_maximum_length)
					AS
					(
					   SELECT ''' + @DB_Name + ''',table_name,Column_Name,TABLE_SCHEMA,character_maximum_length
                       from information_schema.columns 
                       where data_type in ( ''nvarchar'',''varchar'') and Column_Name not in (''RequestBody_Old'',''RequestMetaData'',''ResponseBody_Old'',''RequestBody'',''ResponseBody'',
					                                                                          ''XMLLog'',''Log'',''NewValue'',''NewValue'',''DataFeedResponse'',''HTMLPageContent'',''StatisticsData'',
																							  ''SectionContent'',''ResponseMetaData'',''FileLog'',''Xml'',''OldValue'',''PageContent'',''Note'',''FinancialSummaryComments'',
																							  ''ConditionsToApprovalSummary'',''Message'',''NonFinancialsNotes'',''Proposal'',''PageContent'',''RawData'',''RequestKeyMetaData'',
																							  ''RisksMitigationsSummary'',''RepaymentsComments'',''OutputDataRaw'',''StackTrace'',''ErrorMessage'',''RequestHeaders'') 
                       and character_maximum_length=-1 AND TABLE_SCHEMA =''dbo''
                     )
					 Insert into #TempTable (DBName , tablename ,[ColumnName],TABLESCHEMA,character_maximum_length)
 SELECT DBName , tablename ,[ColumnName],TABLESCHEMA,character_maximum_length
 FROM CTE_Tables AS cte ' 
Exec (@Command) FETCH NEXT
FROM database_cursor INTO @DB_Name 
END 
CLOSE database_cursor 
DEALLOCATE database_cursor
          
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
DECLARE @Command1 nvarchar(MAX) 
DECLARE @DBName1 varchar(100)
DECLARE @tableName varchar(100)
DECLARE @columnName varchar(100) 
DECLARE @character_maximum_length varchar(10)
DECLARE database_cursor CURSOR FOR
	SELECT DBName,TableName,ColumnName,character_maximum_length FROM #TempTable
OPEN database_cursor FETCH NEXT
FROM database_cursor INTO @DBName1,@tableName,@columnName ,@character_maximum_length                 
WHILE @@FETCH_STATUS = 0 
			BEGIN
			SET @Command1 =  'insert into #TempTableFinalResult(DBName, [TableName], ColumnName, [MaxLength], [RowCount],character_maximum_length) 
			                  SELECT '''+ @DBName1 + ''', '''+ @tableName + ''', ''['+ @columnName + ']'', MAX(LEN(['+@columnName+'])) AS [MaxLength] ,COUNT(*) AS [RowCount], '''+ @character_maximum_length + '''From '+@DBName1+'.dbo.'+@tableName 
PRINT (@Command1) 
FETCH NEXT
FROM database_cursor INTO @DBName1,@TableName,@ColumnName,@character_maximum_length
END 
CLOSE database_cursor 
DEALLOCATE database_cursor


SELECT * FROM #TempTableFinalResult
ORDER BY maxlength DESC

