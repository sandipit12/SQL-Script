DECLARE @command varchar(4000)
SELECT @command = '
USE [?] 
SELECT 
distinct  db_name() as [DatabaseName], 
s.name As SchemaName,
object_name(o.object_id) AS [TableName], 
c.column_id,
c.name AS [ColumnName]
FROM sys.columns c 
join sys.objects o ON c.object_id = o.object_id
INNER JOIN sys.types t ON t.system_type_id = c.user_type_id 
inner join sys.schemas s on s.schema_ID = o.schema_ID
WHERE o.type IN (''U'',''V'') 

AND db_name()+''.''+ s.name+''.''+object_name(o.object_id) 
	NOT IN (''DataScience_Yesterday.dbo.Lokiv2ResultsTODELETE'',
	        ''DataScience_Yesterday.dbo.LRFraudScore_times''
			) /* tables and views Not To include in Obfuscation */
AND (c.name like ''%mail%''
OR c.name like ''%first%name%''
OR c.name like ''%Post%Code%''
OR c.name like ''%last%name%''
OR c.name like ''%Username%''
OR c.name like ''%birth%''
OR c.name like ''%Password%''
OR c.name like ''%sex%''
OR c.name like ''%Gender%''
OR c.name like ''%UserLogin%''
OR c.name like ''%address%''
OR c.name like ''%phone%''
OR c.name like ''%social%''
OR c.name like ''%NINumber%''
OR c.name like ''%Sort%Code%''
OR c.name like ''%Bank%Account%''
OR c.name like ''%gender%'') 
AND db_name() NOT IN (''msdb'',''tempdb'',''master'',''Venus_Tuesday'',''Venus_Tuesday'',''Venus_Midday'',''Venus_Thursday'',''Venus_Friday'',''Venus_DB_2181'',''Venus_Sunday'',''Venus_DB-2067'',''Venus_Yesterday_snapshot'',''Venus_Wednesday'',''Venus_Yesterday'',''Venus_Monday'')
AND  c.name NOT in (''emailConfirmedDate'',''lastPasswordChangeDate'',''passwordConfig'',''lastPasswordChangeDate'')'

