SET TRAN ISOLATION LEVEL READ UNCOMMITTED
DROP TABLE IF EXISTS #temp
SELECT * INTO #temp
FROM
(
SELECT TOP 10  object_name ,package_name,DATENAME(WEEKDAY,start_time) AS [WeekDay],message,message_time,message_source_name,execution_path,start_time,end_time 
 FROM    SSISDB.[catalog].[event_messages] 
 JOIN SSISDB.[catalog].[operations]  ON operations.operation_id = event_messages.operation_id
 WHERE  message_type = 40 AND message_time > '20230305' AND 
        package_name  IN ('Transfer tables-daily-Snapshot.dtsx')
)A

SELECT   LEFT(RIGHT (MESSAGE,13), NULLIF(LEN(RIGHT (MESSAGE,13))-1,-1)), * FROM #temp


