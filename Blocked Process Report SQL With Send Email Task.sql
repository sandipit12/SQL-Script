 SET NOCOUNT ON

-- Checked for currenlty running queries by putting data in temp table
SELECT s.session_id
    ,r.STATUS
    ,r.blocking_session_id
    ,r.wait_type
    ,wait_resource
    ,r.wait_time / (1000.0) 'WaitSec'
    ,r.cpu_time
    ,r.logical_reads
    ,r.reads
    ,r.writes
    ,r.total_elapsed_time / (1000.0) 'ElapsSec'
    ,Substring(st.TEXT, (r.statement_start_offset / 2) + 1, (
            (
                CASE r.statement_end_offset
                    WHEN - 1
                        THEN Datalength(st.TEXT)
                    ELSE r.statement_end_offset
                    END - r.statement_start_offset
                ) / 2
            ) + 1) AS statement_text
    ,Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' + Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text
    ,r.command
    ,s.login_name
    ,s.host_name
    ,s.program_name
    ,s.host_process_id
    ,s.last_request_end_time
    ,s.login_time
    ,r.open_transaction_count
INTO #temp_requests
FROM sys.dm_exec_sessions AS s
INNER JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE r.session_id != @@SPID
ORDER BY r.cpu_time DESC
    ,r.STATUS
    ,r.blocking_session_id
    ,s.session_id

IF (
        SELECT count(*)
        FROM #temp_requests
        WHERE blocking_session_id > 50
        ) <> 0
BEGIN
    -- blocking found, sent email. 
    DECLARE @tableHTML NVARCHAR(MAX);

    SET @tableHTML = N'<H1>Blocking Report</H1>' + N'<table border="1">' + N'<tr>' + N'<th>session_id</th>' + N'<th>Status</th>' + 
                     N'<th>blocking_session_id</th><th>wait_type</th><th>wait_resource</th>' + 
                     N'<th>WaitSec</th>' + N'<th>cpu_time</th>' + 
                     N'<th>logical_reads</th>' + N'<th>reads</th>' +
                     N'<th>writes</th>' + N'<th>ElapsSec</th>' + N'<th>statement_text</th>' + N'<th>command_text</th>' + 
                     N'<th>command</th>' + N'<th>login_name</th>' + N'<th>host_name</th>' + N'<th>program_name</th>' + 
                     N'<th>host_process_id</th>' + N'<th>last_request_end_time</th>' + N'<th>login_time</th>' + 
                     N'<th>open_transaction_count</th>' + '</tr>' + CAST((
                SELECT td = s.session_id
                    ,''
                    ,td = r.STATUS
                    ,''
                    ,td = r.blocking_session_id
                    ,''
                    ,td = r.wait_type
                    ,''
                    ,td = wait_resource
                    ,''
                    ,td = r.wait_time / (1000.0)
                    ,''
                    ,td = r.cpu_time
                    ,''
                    ,td = r.logical_reads
                    ,''
                    ,td = r.reads
                    ,''
                    ,td = r.writes
                    ,''
                    ,td = r.total_elapsed_time / (1000.0)
                    ,''
                    ,td = Substring(st.TEXT, (r.statement_start_offset / 2) + 1, (
                            (
                                CASE r.statement_end_offset
                                    WHEN - 1
                                        THEN Datalength(st.TEXT)
                                    ELSE r.statement_end_offset
                                    END - r.statement_start_offset
                                ) / 2
                            ) + 1)
                    ,''
                    ,td = Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) +
                        N'.' + Quotename(Object_name(st.objectid, st.dbid)), '')
                    ,''
                    ,td = r.command
                    ,''
                    ,td = s.login_name
                    ,''
                    ,td = s.host_name
                    ,''
                    ,td = s.program_name
                    ,''
                    ,td = s.host_process_id
                    ,''
                    ,td = s.last_request_end_time
                    ,''
                    ,td = s.login_time
                    ,''
                    ,td = r.open_transaction_count
                FROM sys.dm_exec_sessions AS s
                INNER JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
                CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
                WHERE r.session_id != @@SPID
                    AND blocking_session_id > 0
                ORDER BY r.cpu_time DESC
                    ,r.STATUS
                    ,r.blocking_session_id
                    ,s.session_id
                FOR XML PATH('tr')
                    ,TYPE
                ) AS NVARCHAR(MAX)) + N'</table>';

    EXEC msdb.dbo.sp_send_dbmail @body = @tableHTML
        ,@body_format = 'HTML'
        ,@profile_name = N'RS-DW03@ratesetter.com'
        ,@recipients = N'sandip.patel@ratesetter.com'
        ,@Subject = N'Blocking Detected'
END

DROP TABLE #temp_requests


--SELECT * FROM msdb.dbo.sysmail_profileRS-DW03@ratesetter.com