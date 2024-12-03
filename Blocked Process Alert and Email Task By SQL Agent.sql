

USE Tools
GO

/****** Object:  Table [dbo].[dba_blockinfo]    Script Date: 03/04/2015 10:20:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[dba_blockinfo](
	[lock_type] [nvarchar](120) NULL,
	[database_id] [nvarchar](150) NULL,
	[blk_object] [bigint] NULL,
	[lock_req] [nvarchar](120) NULL,
	[wait_sid] [bigint] NULL,
	[wait_time] [sysname] NOT NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_batch] [varchar](max) NULL,
	[wait_stmt] [varchar](max) NULL,
	[block_stmt] [varchar](max) NULL,
	[blocker_sid] [bigint] NULL
) ON [PRIMARY]

GO


USE Tools
GO
/****** Object:  StoredProcedure [dbo].[dba_AlertBlocksWarning_csv]    Script Date: 03/10/2015 13:05:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		lcohan
-- Create date: 2011-12-16
-- Description:	Used to alert if severe Blocking/Locking occured.
-- Used By:     SQL Server scheduled job
-- Parameters:  
--				@profile_name_in = 'SQL Mail Profile', 
--				@recipients_in = 'recipient_mail@mail.com', 
--				@servername_in = 'SQL Server Cluster NNN'
-- Outputs:     email alert sent to the DBA as ATTACHMENT rather than HTML body
-- Execute:     exec [dbo].[dba_AlertBlocksWarning_csv]  @profile_name_in = 'SQL Mail Profile', @recipients_in = 'lcohan@mail.com', @servername_in = 'MySuper Cluster'; 
-- =============================================
CREATE PROCEDURE [dbo].[dba_AlertBlocksWarning_csv] 
	@profile_name_in nvarchar(100),
	@recipients_in nvarchar(500),
	@servername_in nvarchar(50) 

AS
SET NOCOUNT ON;

--send detailed blocking info if exsists
truncate table tools..dba_blockinfo;

insert into tools..dba_blockinfo
select t1.resource_type							as lock_type
	,db_name(resource_database_id)				as database_id
	,t1.resource_associated_entity_id			as blk_object
	,t1.request_mode							as lock_req	 -- lock requested
	,t1.request_session_id						as wait_sid  -- spid of waiter
	,t2.wait_duration_ms						as wait_time
	,t2.wait_type								as wait_type		
	,(select text from sys.dm_exec_requests	r  --- get sql for waiter
		cross apply sys.dm_exec_sql_text(r.sql_handle) 
		where r.session_id = t1.request_session_id) as wait_batch
	,(select substring(qt.text,r.statement_start_offset/2, 
			(case when r.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else r.statement_end_offset end - r.statement_start_offset)/2) 
		from sys.dm_exec_requests r
		cross apply sys.dm_exec_sql_text(r.sql_handle) qt
		where r.session_id = t1.request_session_id) as wait_stmt    --- this is the statement executing right now
	,(select text from sys.sysprocesses p		--- get sql for blocker
		cross apply sys.dm_exec_sql_text(p.sql_handle) 
		where p.spid = t2.blocking_session_id) as block_stmt
	,t2.blocking_session_id as blocker_sid -- spid of blocker
from 
	sys.dm_tran_locks t1, 
	sys.dm_os_waiting_tasks t2
where 
	t1.lock_owner_address = t2.resource_address

DECLARE @title nvarchar(500)
SET @title = 'Blocking occured on '+@@SERVERNAME+'. There are: '+cast((select count(*) from tools..dba_blockinfo) as sysname) + ' blocked processes at: '+cast(getdate() as sysname)

declare @sql_query nvarchar(1000);
--set @sql_query = N'set nocount on; SELECT * FROM tools.dbo.dba_blockinfo WHERE datalength(database_id) > 0;'
set @sql_query = N'set nocount on; 
SELECT  cast(left(ltrim(database_id),50) as nvarchar) as database_id, 
blocker_sid as blocker_SPID,
wait_sid as blocked_SPID,
blk_object,
cast(left(ltrim(lock_type),50) as nvarchar) as lock_type,
cast(left(ltrim(lock_req),50) as nvarchar) as lock_req,
cast(left(ltrim(wait_time),50) as nvarchar) as wait_time,
cast(left(ltrim(wait_type),50) as nvarchar) as wait_type, 
ltrim(replace(wait_batch,char(13),'' '')) as blocked_batch,
ltrim(replace(block_stmt,char(13),'' '')) as blocker_stmnt
FROM tools.dbo.dba_blockinfo WHERE datalength(database_id) > 0;';

IF (SELECT COUNT(*) FROM tools..dba_blockinfo WHERE datalength(database_id) > 0) > 3
BEGIN
	EXECUTE AS LOGIN = 'Domain\UserName'; -- must be sysadmin
	EXECUTE msdb.dbo.sp_send_dbmail 
		@profile_name = @profile_name_in,
        @recipients=@recipients_in,
        @subject = @title,  
		@body = 'Please see attchment for more details',    
		@body_format = 'Text',
		@query = @sql_query,
		@execute_query_database = 'tools',
		@query_result_header = 1,
		@attach_query_result_as_file = 1,
		@query_result_separator = '	',
		@query_result_no_padding = 1, 
		@query_attachment_filename = 'BlockingDetails.csv';    
	REVERT;
END

IF EXISTS(SELECT * FROM tools..dba_blockinfo WHERE datalength(database_id) > 0)
BEGIN
	--wait 2 minutes until next check...
	waitfor delay '00:02:00';
END

GO



USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Alert' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Alert'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Alert DBA - Blocking occured', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Alert', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLAlerts', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'send email alert', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=2, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE AS LOGIN = ''SA'';
exec [tools].[dbo].[dba_AlertBlocksWarning_csv]  @profile_name_in = ''SQL Mail Profile'', @recipients_in = ''lcohan@mail.com'', @servername_in = ''MySuper Cluster''; 
REVERT;
GO

', 
		@database_name=N'tools', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 10 seconds with 1 m inute delay', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150119, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO