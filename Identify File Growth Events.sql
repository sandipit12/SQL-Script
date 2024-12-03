---- Check If Default trace is On 
---- TraceID = 92 for Datfile AutoGraw 
---- TraceID = 93 for Logfile AotpGraw


DECLARE @current_tracefilename VARCHAR(500);
DECLARE @0_tracefilename VARCHAR(500);
DECLARE @indx INT;
DECLARE @database_name SYSNAME;
SET @database_name = ('AutoRek54catalog')
SELECT @current_tracefilename = path
FROM sys.traces
WHERE is_default = 1;
SET @current_tracefilename = REVERSE(@current_tracefilename);
SELECT @indx = PATINDEX('%\%', @current_tracefilename);
SET @current_tracefilename = REVERSE(@current_tracefilename);
SET @0_tracefilename = LEFT(@current_tracefilename, LEN(@current_tracefilename) - @indx) + '\log.trc';
SELECT DatabaseName,E.name
,Filename
,(Duration / 1000) AS 'TimeTaken(ms)'
,StartTime
,EndTime
,(IntegerData * 8.0 / 1024) AS 'ChangeInSize MB'
,ApplicationName
,HostName
,LoginName
FROM::fn_trace_gettable(@0_tracefilename, DEFAULT) t
INNER JOIN sys.trace_events E ON E.trace_event_id = E.trace_event_id
LEFT JOIN sys.databases AS d ON (d.NAME = @database_name)
WHERE EventClass >= 92
AND EventClass <= 95
AND E.trace_event_id IN (92,93)
AND ServerName = @@servername
AND DatabaseName IN( @database_name )
AND (d.create_date < EndTime)
ORDER BY t.StartTime DESC;