DECLARE @DB_USers TABLE
(
    DBName sysname,
    UserName sysname,
    LoginType sysname,
    AssociatedRole VARCHAR(MAX),
    create_date DATETIME,
    modify_date DATETIME
);

INSERT @DB_USers
EXEC sp_MSforeachdb '
use [?]
SELECT ''?'' AS DB_Name,
case prin.name when ''dbo'' then prin.name + '' (''+ (select SUSER_SNAME(owner_sid) from master.sys.databases where name =''?'') + '')'' else prin.name end AS UserName,
prin.type_desc AS LoginType,
isnull(USER_NAME(mem.role_principal_id),'''') AS AssociatedRole ,create_date,modify_date
FROM sys.database_principals prin
LEFT OUTER JOIN sys.database_role_members mem ON prin.principal_id=mem.member_principal_id
WHERE prin.sid IS NOT NULL and prin.sid NOT IN (0x00) and
prin.is_fixed_role <> 1 AND prin.name NOT LIKE ''##%''';

SELECT DBName,
       UserName,
       LoginType,
       create_date,
       modify_date,
       STUFF(
       (
           SELECT ',' + CONVERT(VARCHAR(500), AssociatedRole)
           FROM @DB_USers user2
           WHERE user1.DBName = user2.DBName
                 AND user1.UserName = user2.UserName
           FOR XML PATH('')
       ),
       1,
       1,
       ''
            ) AS Permissions_user
FROM @DB_USers user1
GROUP BY DBName,
         UserName,
         LoginType,
         create_date,
         modify_date
ORDER BY DBName,
         UserName;


CREATE TABLE #temptable ( [DB_Name] varchar(50), [name] nvarchar(128), [type] char(10), [sid] varbinary(85), [SID_Len] int )
INSERT INTO #temptable ([DB_Name], [name], [type], [sid], [SID_Len])
EXEC sp_MSforeachdb  '	
use [?]
SELECT ''?'' AS DB_Name
-- find orphaned users from windows/certificate/asymmetric_key login
,  dp.name, dp.type, dp.sid, LEN(dp.sid) as [SID_Len] 
from sys.database_principals dp
left join sys.server_principals sp
on dp.sid = sp.sid
left join sys.certificates c
on dp.sid = c.sid
left join sys.asymmetric_keys a
on dp.sid = a.sid
where sp.sid is null and c.sid is null and a.sid is null
-- check dp.type, go to the following
--https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-database-principals-transact-sql
and dp.type in (''U'', ''S'', ''C'', ''K'') 
and dp.principal_id > 4 -- 0..4 are system users which will be ignored
and not (dp.type = ''S'' and LEN(dp.sid) = 28) -- to filter out the valid db users without login
'

SELECT 'DB User Without Login'AdditionalInfo,* FROM #temptable