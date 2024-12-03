--CREATE EVENT SESSION [Get Stored PROC Parameter] ON SERVER 
--ADD EVENT sqlserver.rpc_completed(
--WHERE ( [sqlserver].[like_i_sql_unicode_string](statement,N'%Affiliate_GetAll%')  -- This one is when Application call an Stored Proc 
--	)
--)	
--WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=10 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
--GO


--CREATE EVENT SESSION [Get Stored PROC Parameter 2] ON SERVER 
--ADD EVENT sqlserver.sql_batch_completed(
--WHERE ( [sqlserver].[like_i_sql_unicode_string]([sql_text],N'%Affiliate_GetAll%') -- When you calling fron SSMS
--	)
--)	
--WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
--GO


--CREATE EVENT SESSION [Get DML Statement On Live Database] ON SERVER 
--ADD EVENT sqlserver.sql_statement_completed
--(
--    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text,sqlserver.username)
--    WHERE (([sqlserver].[like_i_sql_unicode_string]([sql_text],N'%UPDATE%') 
--	    OR [sqlserver].[like_i_sql_unicode_string]([sql_text],N'%DELETE%') 
--		OR [sqlserver].[like_i_sql_unicode_string]([sql_text],N'%INSERT%')
--		  ) AND  [sqlserver].[database_id]>(5))
--)
--ADD TARGET package0.asynchronous_file_target(SET filename=N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\Get DML Statement On Live Database.xel'), --C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log
--ADD TARGET package0.ring_buffer
--WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
--GO
--USE [Tools]
--GO

--/****** Object:  Table [dbo].[GetDMLStatementOnLiveDatabase]    Script Date: 27/11/2018 13:50:41 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


--CREATE TABLE [dbo].[GetDMLStatementOnLiveDatabase](
--	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
--	[TargetData] [XML] NULL,
--	[SQLText] [VARCHAR](MAX) NULL,
--	[timestamp] [VARCHAR](50) NOT NULL,
--	[username] [VARCHAR](50) NULL,
--	[database_name] [VARCHAR](50) NULL,
--	[client_hostname] [VARCHAR](50) NULL,
--	[client_app_name] [VARCHAR](100) NULL,
--	[row_count] [BIGINT] NULL,
-- CONSTRAINT [PK_GetDMLStatementOnLiveDatabase] PRIMARY KEY CLUSTERED 
--(
--	[ID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
--GO


--CREATE INDEX IXN_GetDMLStatementOnLiveDatabase ON GetDMLStatementOnLiveDatabase (timestamp,client_hostname)

DROP TABLE IF EXISTS  #Temptable
SELECT * INTO #Temptable
FROM
(
	SELECT 
		TargetData,
		REPLACE(REPLACE(REPLACE(REPLACE(SQLText,'<data name="statement">',''),'<value>',''),'</value>',''),'</data>','') SQLText,
		[timestamp],
		REPLACE(REPLACE(REPLACE(REPLACE(username,'<action name="username" package="sqlserver">',''),'<value>',''),'</value>',''),'</action>','') username,
		REPLACE(REPLACE(REPLACE(REPLACE([database_name],'<action name="database_name" package="sqlserver">',''),'<value>',''),'</value>',''),'</action>','')[database_name],
		REPLACE(REPLACE(REPLACE(REPLACE(client_hostname,'<action name="client_hostname" package="sqlserver">',''),'<value>',''),'</value>',''),'</action>','') client_hostname,
		REPLACE(REPLACE(REPLACE(REPLACE(client_app_name,'<action name="client_app_name" package="sqlserver">',''),'<value>',''),'</value>',''),'</action>','') client_app_name,
		REPLACE(REPLACE(REPLACE(REPLACE(row_count,'<data name="row_count">',''),'<value>',''),'</value>',''),'</data>','') row_count
	FROM
	(
		SELECT CAST(event_data AS xml) AS TargetData,
			   CAST(CAST(event_data AS xml).value('(/event/@timestamp)[1]','VARCHAR(100)')AS VARCHAR(MAX)) AS [timestamp],
			   CAST(CAST(event_data AS xml).query('/event/data[@name="statement"]')AS VARCHAR(MAX)) AS SQLText,
			   CAST(CAST(event_data AS xml).query('/event/action[@name="username"]')AS VARCHAR(MAX)) AS username,
			   CAST(CAST(event_data AS xml).query('/event/action[@name="database_name"]')AS VARCHAR(MAX)) AS [database_name],
			   CAST(CAST(event_data AS xml).query('/event/action[@name="client_hostname"]')AS VARCHAR(MAX)) AS client_hostname,
			   CAST(CAST(event_data AS xml).query('/event/action[@name="client_app_name"]')AS VARCHAR(MAX)) AS client_app_name,
			   CAST(CAST(event_data AS xml).query('/event/data[@name="row_count"]')AS VARCHAR(MAX)) AS row_count
		FROM sys.fn_xe_file_target_read_file('C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\Get DML Statement On Live Database*.xel',NULL,NULL, NULL)
	)A WHERE REPLACE(REPLACE(REPLACE(REPLACE(SQLText,'<data name="statement">',''),'<value>',''),'</value>',''),'</data>','')  LIKE '%UPDATE %' OR
	         REPLACE(REPLACE(REPLACE(REPLACE(SQLText,'<data name="statement">',''),'<value>',''),'</value>',''),'</data>','')  LIKE '%INSERT %' OR
			 REPLACE(REPLACE(REPLACE(REPLACE(SQLText,'<data name="statement">',''),'<value>',''),'</value>',''),'</data>','')  LIKE '%DELETE %' 
)A


INSERT INTO tools.dbo.GetDMLStatementOnLiveDatabase
(TargetData,SQLText,timestamp,username,database_name,client_hostname,client_app_name,row_count)
SELECT TargetData,SQLText,timestamp,username,database_name,client_hostname,client_app_name,row_count
FROM #Temptable Temp 
WHERE
   NOT EXISTS (SELECT 1 FROM  tools.[dbo].[GetDMLStatementOnLiveDatabase] Main WHERE main.timestamp = Temp.timestamp AND Main.client_hostname = Temp.client_hostname)
    