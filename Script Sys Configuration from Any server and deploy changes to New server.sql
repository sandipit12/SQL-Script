EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure
GO

SELECT 'EXEC sp_configure ''' + name + ''', ' + CAST(value AS VARCHAR(100))
FROM sys.configurations
ORDER BY name
