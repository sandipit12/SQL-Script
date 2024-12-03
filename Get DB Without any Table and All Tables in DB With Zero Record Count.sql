declare @SQL nvarchar(max)
DROP TABLE IF EXISTS #temptable
CREATE TABLE #temptable ( [Database Name] varchar(100), [Table Name] nvarchar(128), [RowCount] int )

set @SQL = ''
--select * from sys.databases 
select @SQL = @SQL + CHAR(13) + 'USE ' + QUOTENAME([name]) + ';
INSERT INTO #temptable ([Database Name], [Table Name], [RowCount])
SELECT ' +quotename([name],'''') + 'as [Database Name], so.name AS [Table Name],   
    rows AS [RowCount]   
FROM sysindexes AS si   
    join sysobjects AS so on si.id = so.id   
WHERE indid IN (0,1) and  so.name  <> ''__EFMigrationsHistory''
    AND xtype = ''U''' from sys.databases WHERE database_id > 4

execute (@SQL) 


SELECT DISTINCT [Database Name] ,'With Table but no Records in the table' [desc]
FROM #temptable 
WHERE [RowCount]  = 0 
    AND [Database Name] NOT IN (SELECT DISTINCT [Database Name] FROM #temptable WHERE [RowCount] <> 0 )
UNION 
SELECT name,'Without any Table' [desc] FROM Sys.databases WHERE name NOT IN (SELECT DISTINCT [Database Name] FROM #temptable)  and database_id > 4