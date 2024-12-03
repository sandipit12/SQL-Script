EXEC sys.xp_fixeddrives


DECLARE @ScriptToExecute VARCHAR(MAX);
SET @ScriptToExecute = '';

SELECT
@ScriptToExecute = @ScriptToExecute +
'USE ['+ d.name +']; CHECKPOINT; DBCC SHRINKFILE ('+f.name+');'
FROM sys.master_files f
INNER JOIN sys.databases d ON d.database_id = f.database_id
WHERE f.type = 1 AND d.database_id > 4
AND d.state_desc ='ONLINE'
-- AND d.name = 'NameofDB'
SELECT @ScriptToExecute ScriptToExecute
EXEC (@ScriptToExecute)

------------------------------------------------------------------------------------------------

	EXEC sys.xp_fixeddrives
