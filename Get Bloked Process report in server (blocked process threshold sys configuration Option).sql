USE master 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----  Chanage server configuration for Blocked Procee. Default is Zero whihc means no blocked report is Produced.
----  Below script set it to 20 sec means every 20 sec thead will check and report any blocked Process. This use Deadlock monitor backgroud thread to detect blocked Process. 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sp_configure 'show advanced options', 1 ;  
GO  
RECONFIGURE ;  
GO  
sp_configure 'blocked process threshold', 20 ;  
GO  
RECONFIGURE ;  
GO  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----  CREATE Trace  which will capture Event 137 which is Blocked Process Report 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
declare @DateTime datetime
 
---------Added a function here:
set @DateTime = DATEADD(mi,5,getdate()); /* Run for five minutes */
set @maxfilesize = 5
 
-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share
 
-----------Set my filename here:
exec @rc = sp_trace_create @TraceID output, 0, N'E:\BlockedProcessReportDemo', @maxfilesize, @Datetime ---- Specify File Path for Trace file 
if (@rc != 0) goto error
 
-- Client side File and Table cannot be scripted
 
-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 137, 1, @on
exec sp_trace_setevent @TraceID, 137, 12, @on
 
-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint
 
-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1
 
-- display trace id for future references
select TraceID=@TraceID
goto finish
 
error:
select ErrorCode=@rc
 
finish:
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----  CREATE Stored Proc which will read Trace file Above
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




USE [Tools]
GO

/****** Object:  StoredProcedure [dbo].[sp_blocked_process_report_viewer]    Script Date: 13/03/2018 12:20:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_blocked_process_report_viewer]
(
	@Source NVARCHAR(MAX),
	@Type VARCHAR(10) = 'FILE' 
)

AS

SET NOCOUNT ON

-- Validate @Type
IF (@Type NOT IN ('FILE', 'TABLE', 'XMLFILE', 'XESESSION'))
	RAISERROR ('The @Type parameter must be ''FILE'', ''TABLE'', ''XESESSION'' or ''XMLFILE''', 11, 1)

IF (@Source LIKE '%.trc' AND @Type <> 'FILE')
	RAISERROR ('Warning: You specified a .trc trace. You should also specify @Type = ''FILE''', 10, 1)

IF (@Source LIKE '%.xml' AND @Type <> 'XMLFILE')
	RAISERROR ('Warning: You specified a .xml trace. You should also specify @Type = ''XMLFILE''', 10, 1)

IF (@Type = 'XESESSION' AND NOT EXISTS (
	SELECT * 
	FROM sys.server_event_sessions es
	JOIN sys.server_event_session_targets est
		ON es.event_session_id = est.event_session_id
	WHERE est.name in ('event_file', 'ring_buffer')
	  AND es.name = @Source ) 
)
	RAISERROR ('Warning: The extended event session you supplied does not exist or does not have an "event_file" or "ring_buffer" target.', 10, 1);
		

CREATE TABLE #ReportsXML
(
	monitorloop nvarchar(100) NOT NULL,
	endTime datetime NULL,
	blocking_spid INT NOT NULL,
	blocking_ecid INT NOT NULL,
	blocked_spid INT NOT NULL,
	blocked_ecid INT NOT NULL,
	blocked_hierarchy_string as CAST(blocked_spid as varchar(20)) + '.' + CAST(blocked_ecid as varchar(20)) + '/',
	blocking_hierarchy_string as CAST(blocking_spid as varchar(20)) + '.' + CAST(blocking_ecid as varchar(20)) + '/',
	bpReportXml xml not null,
	primary key clustered (monitorloop, blocked_spid, blocked_ecid),
	unique nonclustered (monitorloop, blocking_spid, blocking_ecid, blocked_spid, blocked_ecid)
)

DECLARE @SQL NVARCHAR(max);
DECLARE @TableSource nvarchar(max);

-- define source for table
IF (@Type = 'TABLE')
BEGIN
	-- everything input by users get quoted
	SET @TableSource = ISNULL(QUOTENAME(PARSENAME(@Source,4)) + N'.', '')
		+ ISNULL(QUOTENAME(PARSENAME(@Source,3)) + N'.', '')
		+ ISNULL(QUOTENAME(PARSENAME(@Source,2)) + N'.', '')
		+ QUOTENAME(PARSENAME(@Source,1));
END

-- define source for trc file
IF (@Type = 'FILE')
BEGIN	
	SET @TableSource = N'sys.fn_trace_gettable(N' + QUOTENAME(@Source, '''') + ', -1)';
END

-- load table or file
IF (@Type IN ('TABLE', 'FILE' ))
BEGIN
	SET @SQL = N'		
		INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			monitorloop,bpReportXml,endTime)
		SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			COALESCE(monitorloop, CONVERT(nvarchar(100), endTime, 120), cast(newid() as nvarchar(100))),
			bpReportXml,EndTime
		FROM ' + @TableSource + N'
		CROSS APPLY (
			SELECT CAST(TextData as xml)
			) AS bpReports(bpReportXml)
		CROSS APPLY (
			SELECT 
				monitorloop = bpReportXml.value(''(//@monitorLoop)[1]'', ''nvarchar(100)''),
				blocked_spid = bpReportXml.value(''(/blocked-process-report/blocked-process/process/@spid)[1]'', ''int''),
				blocked_ecid = bpReportXml.value(''(/blocked-process-report/blocked-process/process/@ecid)[1]'', ''int''),
				blocking_spid = bpReportXml.value(''(/blocked-process-report/blocking-process/process/@spid)[1]'', ''int''),
				blocking_ecid = bpReportXml.value(''(/blocked-process-report/blocking-process/process/@ecid)[1]'', ''int'')
			) AS bpShredded
		WHERE EventClass = 137
		  AND blocking_spid is not null
		  AND blocked_spid is not null';
		
	EXEC (@SQL);

END 


IF (@Type = 'XESESSION')
BEGIN
	DECLARE @SessionType nvarchar(max);
	DECLARE @SessionId int;
	DECLARE @SessionTargetId int;
	DECLARE @FilenamePattern nvarchar(max);

	SELECT TOP ( 1 ) 
		@SessionType = est.name,
		@SessionId = est.event_session_id,
		@SessionTargetId = est.target_id
	FROM sys.server_event_sessions es
	JOIN sys.server_event_session_targets est
		ON es.event_session_id = est.event_session_id
	WHERE est.name in ('event_file', 'ring_buffer')
		AND es.name = @Source;

	IF (@SessionType = 'event_file')
	BEGIN
		 
		SELECT @filenamePattern = REPLACE( CAST([value] AS nvarchar(max)), '.xel', '*xel' )
		FROM sys.server_event_session_fields
		WHERE event_session_id = @SessionId
		  AND [object_id] = @SessionTargetId
		  AND name = 'filename'

		IF (@filenamePattern not like '%xel')
			set @filenamePattern += '*xel';

		INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			monitorloop,bpReportXml,endTime)
		SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			COALESCE(monitorloop, CONVERT(nvarchar(100), eventDate, 120), cast(newid() as nvarchar(100))),
			bpReportXml,eventDate
		FROM sys.fn_xe_file_target_read_file ( @filenamePattern, null, null, null) 
			as event_file_value
		CROSS APPLY ( SELECT CAST(event_file_value.[event_data] as xml) ) 
			as event_file_value_xml ([xml])
		CROSS APPLY (
			SELECT 
				event_file_value_xml.[xml].value('(event/@timestamp)[1]', 'datetime') as eventDate,
				event_file_value_xml.[xml].query('//event/data/value/blocked-process-report') as bpReportXml	
		) as bpReports
		CROSS APPLY (
			SELECT 
				monitorloop = bpReportXml.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
				blocked_spid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@spid)[1]', 'int'),
				blocked_ecid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@ecid)[1]', 'int'),
				blocking_spid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@spid)[1]', 'int'),
				blocking_ecid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@ecid)[1]', 'int')
			) AS bpShredded
		WHERE blocking_spid is not null
		  AND blocked_spid is not null;

	END

	ELSE IF (@SessionType = 'ring_buffer')
	BEGIN
		-- get data from ring buffer
		INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			monitorloop,bpReportXml,endTime)
		SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
			COALESCE(monitorloop, CONVERT(nvarchar(100), bpReportEndTime, 120), cast(newid() as nvarchar(100))),
			bpReportXml,bpReportEndTime
		FROM sys.dm_xe_session_targets st
		JOIN sys.dm_xe_sessions s 
			ON s.address = st.event_session_address
		CROSS APPLY 
			( SELECT CAST(st.target_data AS XML) ) 
			AS TargetData ([xml])
		CROSS APPLY 
			TargetData.[xml].nodes('/RingBufferTarget/event[@name="blocked_process_report"]') 
			AS bpNodes(bpNode)
		CROSS APPLY 
			bpNode.nodes('./data[@name="blocked_process"]/value/blocked-process-report')
			AS bpReportXMLNodes(bpReportXMLNode)
		CROSS APPLY
			(
			  SELECT 
				bpReportXml = CAST(bpReportXMLNode.query('.') as xml),
				bpReportEndTime = bpNode.value('(./@timestamp)[1]', 'datetime'),
				monitorloop = bpReportXMLNode.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
				blocked_spid = bpReportXMLNode.value('(./blocked-process/process/@spid)[1]', 'int'),
				blocked_ecid = bpReportXMLNode.value('(./blocked-process/process/@ecid)[1]', 'int'),
				blocking_spid = bpReportXMLNode.value('(./blocking-process/process/@spid)[1]', 'int'),
				blocking_ecid = bpReportXMLNode.value('(./blocking-process/process/@ecid)[1]', 'int')
			) AS bpShredded
		WHERE s.name = @Source
		OPTION (MAXDOP 1);
	END

END



IF (@Type = 'XMLFILE')
BEGIN
	CREATE TABLE #TraceXML (
		id int identity primary key,
		ReportXML xml NOT NULL	
	)
	
	SET @SQL = N'
		INSERT #TraceXML(ReportXML)
		SELECT col FROM OPENROWSET (
				BULK ' + QUOTENAME(@Source, '''') + N', SINGLE_BLOB
			) as xmldata(col)';

	EXEC (@SQL);
	
	CREATE PRIMARY XML INDEX PXML_TraceXML ON #TraceXML(ReportXML);

	WITH XMLNAMESPACES 
	(
		'http://tempuri.org/TracePersistence.xsd' AS MY
	),
	ShreddedWheat AS 
	(
		SELECT
			bpShredded.blocked_ecid,
			bpShredded.blocked_spid,
			bpShredded.blocking_ecid,
			bpShredded.blocking_spid,
			bpShredded.monitorloop,
			bpReports.bpReportXml,
			bpReports.bpReportEndTime
		FROM #TraceXML
		CROSS APPLY 
			ReportXML.nodes('/MY:TraceData/MY:Events/MY:Event[@name="Blocked process report"]')
			AS eventNodes(eventNode)
		CROSS APPLY 
			eventNode.nodes('./MY:Column[@name="EndTime"]')
			AS endTimeNodes(endTimeNode)
		CROSS APPLY
			eventNode.nodes('./MY:Column[@name="TextData"]')
			AS bpNodes(bpNode)
		CROSS APPLY (
			SELECT CAST(bpNode.value('(./text())[1]', 'nvarchar(max)') as xml),
				CAST(LEFT(endTimeNode.value('(./text())[1]', 'varchar(max)'), 19) as datetime)
		) AS bpReports(bpReportXml, bpReportEndTime)
		CROSS APPLY (
			SELECT 
				monitorloop = bpReportXml.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
				blocked_spid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@spid)[1]', 'int'),
				blocked_ecid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@ecid)[1]', 'int'),
				blocking_spid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@spid)[1]', 'int'),
				blocking_ecid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@ecid)[1]', 'int')
		) AS bpShredded
	)
	INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
		monitorloop,bpReportXml,endTime)
	SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
		COALESCE(monitorloop, CONVERT(nvarchar(100), bpReportEndTime, 120), 'unknown'),
		bpReportXml,bpReportEndTime
	FROM ShreddedWheat;
	
	DROP TABLE #TraceXML

END

-- Organize and select blocked process reports
;WITH Blockheads AS
(
	SELECT blocking_spid, blocking_ecid, monitorloop, blocking_hierarchy_string
	FROM #ReportsXML
	EXCEPT
	SELECT blocked_spid, blocked_ecid, monitorloop, blocked_hierarchy_string
	FROM #ReportsXML
), 
Hierarchy AS
(
	SELECT monitorloop, blocking_spid AS spid, blocking_ecid AS ecid, 
		CAST('/' + blocking_hierarchy_string AS VARCHAR(MAX)) AS chain,
		0 AS level
	FROM Blockheads
	
	UNION ALL
	
	SELECT irx.monitorloop, irx.blocked_spid, irx.blocked_ecid,
		CAST(h.chain + irx.blocked_hierarchy_string AS VARCHAR(MAX)),
		h.level+1
	FROM #ReportsXML irx
	JOIN Hierarchy h
		ON irx.monitorloop = h.monitorloop
		AND irx.blocking_spid = h.spid
		AND irx.blocking_ecid = h.ecid
)
SELECT 
	ISNULL(CONVERT(NVARCHAR(30), irx.endTime, 120), 
		'Lead') AS traceTime,
	SPACE(4 * h.level) 
		+ CAST(h.spid AS VARCHAR(20)) 
		+ CASE h.ecid 
			WHEN 0 THEN ''
			ELSE '(' + CAST(h.ecid AS VARCHAR(20)) + ')' 
		END AS blockingTree,
	irx.bpReportXml
FROM Hierarchy h
LEFT JOIN #ReportsXML irx
	ON irx.monitorloop = h.monitorloop
	AND irx.blocked_spid = h.spid
	AND irx.blocked_ecid = h.ecid
ORDER BY h.monitorloop, h.chain

DROP TABLE #ReportsXML
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----  SELECT * from Sys.traces will get all the traces avialbe at your server 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT * FROM sys.traces


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Disable or Remove trace froms server Exec sp_trace_setstatus @traceid , @Status 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Plug in the correct traceid from the query above
EXEC sp_trace_setstatus @traceid =2, @status = 0; -- stop trace (assuming it's trace ID 2)
GO
EXEC sp_trace_setstatus @traceid =2, @status = 2; -- close trace (assuming it's trace ID 2)
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Disable or Remove trace froms server Exec sp_trace_setstatus @traceid , @Status 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


USE Tools
exec dbo.sp_blocked_process_report_viewer
@Source='E:\BlockedProcessReportDemo.trc';


