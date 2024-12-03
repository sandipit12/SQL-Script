DROP TABLE IF EXISTS #temptable

CREATE TABLE #temptable ( [drive] nvarchar(1), [MB free] int )
INSERT INTO #temptable

EXEC sys.xp_fixeddrives 

;WITH CTE AS
(SELECT db.name AS [Database Name],
       db.recovery_model_desc,
       mf.name AS [Logical Name],
       mf.type_desc AS [File Type],
       mf.physical_name AS [Path],LEFT(mf.physical_name,1) [Drive],
       CAST((mf.size * 8) / 1024.0 AS DECIMAL(18, 1)) AS [Initial Size (MB)],
       'By '
       + IIF(mf.is_percent_growth = 1,
             CAST(mf.growth AS VARCHAR(10)) + '%',
             CONVERT(VARCHAR(30), CAST((mf.growth * 8) / 1024.0 AS DECIMAL(18, 1))) + ' MB') AS [Autogrowth],
       IIF(mf.max_size = 0,
           'No growth is allowed',
           IIF(mf.max_size = -1, 'Unlimited', CAST((CAST(mf.max_size AS BIGINT) * 8) / 1024 AS VARCHAR(30)) + ' MB')) AS [MaximumSize]
FROM sys.master_files AS mf
    INNER JOIN sys.databases AS db
        ON db.database_id = mf.database_id
WHERE mf.type_desc = 'Log'
),
CTE_CountDrive AS (SELECT COUNT(*) CountOfLogfileOnDrive,Drive FROM CTE GROUP BY CTE.Drive)

SELECT CountOfLogfileOnDrive,a.*,t.[MB free]/1024 [GB Free],t.[MB free] , 
      'ALTER DATABASE ' + a.[Database Name] + ' MODIFY FILE ( NAME = N'''+[Logical Name]+''', MAXSIZE = UNLIMITED, FILEGROWTH = 2048MB )'
FROM CTE a 
INNER JOIN #temptable t ON t.drive = a.Drive 
INNER JOIN CTE_CountDrive ON CTE_CountDrive.Drive = a.Drive

ORDER BY a.MaximumSize