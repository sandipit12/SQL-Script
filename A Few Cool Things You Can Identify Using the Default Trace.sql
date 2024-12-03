--http://www.databasejournal.com/features/mssql/a-few-cool-things-you-can-identify-using-the-default-trace.html

-- checks if Default trace is running 

--SELECT* FROM sys.configurations WHERE configuration_id = 1568  
--SELECT * FROM sys.traces




--If not running then Enable it by following 

--sp_configure 'show advanced options',1;
--GO
--RECONFIGURE;
--Go
--sp_configure 'Default trace enabled',1;
--GO
--RECONFIGURE;
--GO


 SELECT  TE.name AS [EventName] ,
         v.subclass_name ,
         T.DatabaseName ,
         t.DatabaseID ,
         t.NTDomainName ,
         t.ApplicationName ,
         t.LoginName ,
         t.SPID ,
         t.StartTime ,
         t.RoleName ,
         t.TargetUserName ,
         t.TargetLoginName ,
         t.SessionLoginName
 FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                               f.[value]
                                                       FROM    sys.fn_trace_getinfo(NULL) f
                                                       WHERE   f.property = 2
                                                     )), DEFAULT) T
         JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
         JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                             AND v.subclass_value = t.EventSubClass
											 WHERE T.EventClass =47  -- 47 is Object:Deleted Event Class
 --WHERE   te.name IN ( 'Audit Addlogin Event', 'Audit Add DB User Event',
 --                     'Audit Add Member to DB Role Event' )
 --        AND v.subclass_name IN ( 'add', 'Grant database access', 'drop', 'Revoke database access')

----SELECT * FROM fn_trace_getinfo(NULL)
----Property of the trace:
----1= Trace options. For more information, see @options in sp_trace_create (Transact-SQL).
----2 = File name
----3 = Max size
----4 = Stop time
----5 = Current trace status. 0 = stopped. 1 = running.



