DECLARE @DATE DATE = GETDATE() - 45
DECLARE @FolderName VARCHAR(50) = 'DWH_Test'
DECLARE @ProjName VARCHAR(50) = 'DWH_SSIS1'

SELECT  executable_statistics.start_time,executable_statistics.end_time
      ,  [executions].[folder_name]
      , [executions].[project_name]
      , [executions].[package_name]
      , [executable_statistics].[execution_path]
      , DATEDIFF(minute, [executable_statistics].[start_time], [executable_statistics].[end_time]) AS 'execution_time[min]'
FROM [SSISDB].[catalog].[executions]
INNER JOIN [SSISDB].[catalog].[executable_statistics]
    ON [executions].[execution_id] = [executable_statistics].[execution_id]
WHERE [executions].[start_time] >= @DATE
AND [folder_name] =  @folderName
AND executions.project_name = @ProjName
AND executable_statistics.execution_path ='\Transfer tables-daily\Sequence Container\Other\Transfer tables-daily-Other'
ORDER BY [executable_statistics].[start_time] 