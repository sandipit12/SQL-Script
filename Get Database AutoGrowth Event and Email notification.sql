DECLARE @filename NVARCHAR(1000);
DECLARE @bc INT;
DECLARE @ec INT;
DECLARE @bfn VARCHAR(1000);
DECLARE @efn VARCHAR(10);
DECLARE @DL VARCHAR(1000); -- email distribution list
DECLARE @ReportHTML  NVARCHAR(MAX);
DECLARE @Subject NVARCHAR (250);

-- Set email distrubution list value
SET @DL = 'sandip.patel@ratesetter.com' -- Change these to the recipients you wish to get the email separated by a semi-colon

-- Get the name of the current default trace
SELECT @filename = CAST(value AS NVARCHAR(1000))
FROM ::fn_trace_getinfo(DEFAULT)
WHERE traceid = 1 AND property = 2;

-- rip apart file name into pieces
SET @filename = REVERSE(@filename);
SET @bc = CHARINDEX('.',@filename);
SET @ec = CHARINDEX('_',@filename)+1;
SET @efn = REVERSE(SUBSTRING(@filename,1,@bc));
SET @bfn = REVERSE(SUBSTRING(@filename,@ec,LEN(@filename)));

-- set filename without rollover number
SET @filename = @bfn + @efn

-- Any Events Occur in the last day
IF EXISTS (SELECT *
             FROM ::fn_trace_gettable(@filename, DEFAULT) AS ftg 
               WHERE (EventClass = 92  -- Date File Auto-grow
                   OR EventClass = 93) -- Log File Auto-grow
                  AND StartTime > DATEADD(dy,-30,GETDATE())) 
BEGIN -- If there are autogrows in the last day 
  SET @ReportHTML =
    N'<H1>' + N'Auto-grow Events for ' + 
   CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + 
    + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL 
           THEN ''  
           ELSE N'\' +  CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128)) 
      END +
    N'</H1>' +
    N'<table border="1">' +
    N'<tr><th>Start Time</th><th>Event Name</th>' +
    N'<th>Database Name</th><th>File Name</th><th>Growth in MB</th>' +
    N'<th>Duration in MS</th></tr>' +
    CAST((SELECT 
              td = ftg.StartTime, '',
              td = te.name, '',
              td = DB_NAME(ftg.databaseid), '',
              td = Filename, '',
              td =(ftg.IntegerData*8)/1024.0, '', 
              td = (ftg.duration/1000) 
          FROM ::fn_trace_gettable(@filename, DEFAULT) AS ftg 
               INNER JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
          WHERE (EventClass = 92  -- Date File Auto-grow
              OR EventClass = 93) -- Log File Auto-grow 
             AND StartTime > DATEADD(dy,-1,GETDATE()) -- Less than 1 day ago
          ORDER BY StartTime  
          FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;
    

    
    -- Build the subject line with server and instance name
    SET @Subject = 'Auto-grow Events in Last Day ' + 
                   CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + 
                 + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL 
                        THEN ''  
                        ELSE N'\' +  CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128)) 
                   END 

    -- Send email to distribution list.     
    
DECLARE @profile_name VARCHAR(100)	
SELECT @profile_name = name FROM msdb.dbo.sysmail_profile WHERE profile_id =1
    EXEC msdb.dbo.sp_send_dbmail @recipients=@DL,
           @subject = @Subject,  
           @body = @ReportHTML,
           @body_format = 'HTML',
           @profile_name=@profile_name ; -- Change this to your profile name
END; -- If there are autogrows in the last day

