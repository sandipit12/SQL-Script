SELECT * FROM sys.dm_hadr_cluster -- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-hadr-cluster-transact-sql?view=sql-server-2017
SELECT * FROM sys.dm_hadr_cluster_members  -- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-hadr-cluster-members-transact-sql?view=sql-server-2017


-- Health of the AGs
SELECT ag.name agname, ags.* FROM sys.dm_hadr_availability_group_states ags INNER JOIN sys.availability_groups ag ON ag.group_id = ags.group_id -- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-hadr-availability-replica-cluster-states-transact-sql?view=sql-server-2017

-- Health and status of AG replicas, run this on the primary replica. 
-- On secondary this will only show info for that instance
SELECT * FROM sys.dm_hadr_availability_replica_states 

-- Health and status of AG replics from the WsFC perspective
SELECT ar.replica_server_name,harc.* FROM sys.dm_hadr_availability_replica_cluster_states harc INNER JOIN  sys.availability_replicas ar ON ar.replica_id = harc.replica_id

-- Health and status of AG databases from the WSFC perspective
SELECT replica_server_name,* FROM sys.dm_hadr_database_replica_cluster_states a INNER JOIN sys.availability_replicas r ON r.replica_id = a.replica_id


-- Health and status of AG databases, run this on the primary replica. 
-- On secondary this will only show info for that instance
SELECT  ag.name ag_name ,
        ar.replica_server_name ,
        adc.database_name ,
        hdrs.database_state_desc ,
        hdrs.synchronization_state_desc ,
        hdrs.synchronization_health_desc ,
        agl.dns_name ,
        agl.port
-- ,*
FROM    sys.dm_hadr_database_replica_states hdrs
        LEFT JOIN sys.availability_groups ag ON hdrs.group_id =ag.group_id
        LEFT  JOIN sys.availability_replicas ar ON ag.group_id = ar.group_id
                                                   AND ar.replica_id = hdrs.replica_id
        LEFT  JOIN sys.availability_databases_cluster adc ON adc.group_id = ag.group_id
                                                             AND adc.group_database_id = hdrs.group_database_id
        LEFT  JOIN sys.availability_group_listeners agl ON agl.group_id = ag.group_id

ORDER BY ag.name , adc.database_name



-- Health and status of AG listeners
SELECT agl.dns_name, agl.port, aglia.* FROM sys.availability_group_listener_ip_addresses aglia INNER JOIN sys.availability_group_listeners agl ON agl.listener_id = aglia.listener_id


--Show Availability groups visible to the Server and Replica information such as Which server is the Primary
--Sync and Async modes , Readable Secondary and Failover Mode, these can all be filtered using a Where clause
--if you are running some checks, no Where clause will show you all of the information.
WITH AGStatus AS(SELECT name as AGname,replica_server_name,CASE WHEN  (primary_replica  = replica_server_name) THEN  1 ELSE  '' END AS IsPrimaryServer,
                      secondary_role_allow_connections_desc AS ReadableSecondary,[availability_mode]  AS [Synchronous],failover_mode_desc
                 FROM master.sys.availability_groups Groups
					INNER JOIN master.sys.availability_replicas Replicas ON Groups.group_id = Replicas.group_id
					INNER JOIN master.sys.dm_hadr_availability_group_states States ON Groups.group_id = States.group_id
                 )
SELECT [AGname],[Replica_server_name],[IsPrimaryServer],[Synchronous],[ReadableSecondary],[Failover_mode_desc]
FROM AGStatus
--WHERE
--IsPrimaryServer = 1
--AND Synchronous = 1
ORDER BY
AGname ASC,
IsPrimaryServer DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SET NOCOUNT ON;
 
DECLARE @AGname NVARCHAR(128);
 
DECLARE @SecondaryReplicasOnly BIT;
 
SET @AGname = 'AG01';        --SET AGname for a specific AG for SET to NULL for ALL AG's
 
IF OBJECT_ID('TempDB..#tmpag_availability_groups') IS NOT NULL
DROP TABLE [#tmpag_availability_groups];
 
SELECT *
INTO [#tmpag_availability_groups]
FROM   [master].[sys].[availability_groups];
 
IF(@AGname IS NULL
OR EXISTS
(
SELECT [Name]
FROM   [#tmpag_availability_groups]
WHERE  [Name] = @AGname
))
BEGIN
 
IF OBJECT_ID('TempDB..#tmpdbr_availability_replicas') IS NOT NULL
DROP TABLE [#tmpdbr_availability_replicas];
 
IF OBJECT_ID('TempDB..#tmpdbr_database_replica_cluster_states') IS NOT NULL
DROP TABLE [#tmpdbr_database_replica_cluster_states];
 
IF OBJECT_ID('TempDB..#tmpdbr_database_replica_states') IS NOT NULL
DROP TABLE [#tmpdbr_database_replica_states];
 
IF OBJECT_ID('TempDB..#tmpdbr_database_replica_states_primary_LCT') IS NOT NULL
DROP TABLE [#tmpdbr_database_replica_states_primary_LCT];
 
IF OBJECT_ID('TempDB..#tmpdbr_availability_replica_states') IS NOT NULL
DROP TABLE [#tmpdbr_availability_replica_states];
 
SELECT [group_id],
[replica_id],
[replica_server_name],
[availability_mode],
[availability_mode_desc]
INTO [#tmpdbr_availability_replicas]
FROM   [master].[sys].[availability_replicas];
 
SELECT [replica_id],
[group_database_id],
[database_name],
[is_database_joined],
[is_failover_ready]
INTO [#tmpdbr_database_replica_cluster_states]
FROM   [master].[sys].[dm_hadr_database_replica_cluster_states];
 
SELECT *
INTO [#tmpdbr_database_replica_states]
FROM   [master].[sys].[dm_hadr_database_replica_states];
 
SELECT [replica_id],
[role],
[role_desc],
[is_local]
INTO [#tmpdbr_availability_replica_states]
FROM   [master].[sys].[dm_hadr_availability_replica_states];
 
SELECT [ars].[role],
[drs].[database_id],
[drs].[replica_id],
[drs].[last_commit_time]
INTO [#tmpdbr_database_replica_states_primary_LCT]
FROM   [#tmpdbr_database_replica_states] AS [drs]
LEFT JOIN [#tmpdbr_availability_replica_states] [ars] ON [drs].[replica_id] = [ars].[replica_id]
WHERE  [ars].[role] = 1;
 
SELECT [AG].[name] AS [AvailabilityGroupName],
[AR].[replica_server_name] AS [AvailabilityReplicaServerName],
[dbcs].[database_name] AS [AvailabilityDatabaseName],
ISNULL([dbcs].[is_failover_ready],0) AS [IsFailoverReady],
ISNULL([arstates].[role_desc],3) AS [ReplicaRole],
[AR].[availability_mode_desc] AS [AvailabilityMode],
CASE [dbcs].[is_failover_ready]
WHEN 1
THEN 0
ELSE ISNULL(DATEDIFF([ss],[dbr].[last_commit_time],[dbrp].[last_commit_time]),0)
END AS [EstimatedDataLoss_(Seconds)],
ISNULL(CASE [dbr].[redo_rate]
WHEN 0
THEN-1
ELSE CAST([dbr].[redo_queue_size] AS FLOAT) / [dbr].[redo_rate]
END,-1) AS [EstimatedRecoveryTime_(Seconds)],
ISNULL([dbr].[is_suspended],0) AS [IsSuspended],
ISNULL([dbr].[suspend_reason_desc],'-') AS [SuspendReason],
ISNULL([dbr].[synchronization_state_desc],0) AS [SynchronizationState],
ISNULL([dbr].[last_received_time],0) AS [LastReceivedTime],
ISNULL([dbr].[last_redone_time],0) AS [LastRedoneTime],
ISNULL([dbr].[last_sent_time],0) AS [LastSentTime],
ISNULL([dbr].[log_send_queue_size],-1) AS [LogSendQueueSize],
ISNULL([dbr].[log_send_rate],-1) AS [LogSendRate_KB/S],
ISNULL([dbr].[redo_queue_size],-1) AS [RedoQueueSize_KB],
ISNULL([dbr].[redo_rate],-1) AS [RedoRate_KB/S],
ISNULL(CASE [dbr].[log_send_rate]
WHEN 0
THEN-1
ELSE CAST([dbr].[log_send_queue_size] AS FLOAT) / [dbr].[log_send_rate]
END,-1) AS [SynchronizationPerformance],
ISNULL([dbr].[filestream_send_rate],-1) AS [FileStreamSendRate],
ISNULL([dbcs].[is_database_joined],0) AS [IsJoined],
[arstates].[is_local] AS [IsLocal],
ISNULL([dbr].[last_commit_lsn],0) AS [LastCommitLSN],
ISNULL([dbr].[last_commit_time],0) AS [LastCommitTime],
ISNULL([dbr].[last_hardened_lsn],0) AS [LastHardenedLSN],
ISNULL([dbr].[last_hardened_time],0) AS [LastHardenedTime],
ISNULL([dbr].[last_received_lsn],0) AS [LastReceivedLSN],
ISNULL([dbr].[last_redone_lsn],0) AS [LastRedoneLSN]
FROM   [#tmpag_availability_groups] AS [AG]
INNER JOIN [#tmpdbr_availability_replicas] AS [AR] ON [AR].[group_id] = [AG].[group_id]
INNER JOIN [#tmpdbr_database_replica_cluster_states] AS [dbcs] ON [dbcs].[replica_id] = [AR].[replica_id]
LEFT OUTER JOIN [#tmpdbr_database_replica_states] AS [dbr] ON [dbcs].[replica_id] = [dbr].[replica_id]
AND [dbcs].[group_database_id] = [dbr].[group_database_id]
LEFT OUTER JOIN [#tmpdbr_database_replica_states_primary_LCT] AS [dbrp] ON [dbr].[database_id] = [dbrp].[database_id]
INNER JOIN [#tmpdbr_availability_replica_states] AS [arstates] ON [arstates].[replica_id] = [AR].[replica_id]
WHERE  [AG].[name] = ISNULL(@AGname,[AG].[name])
ORDER BY [AvailabilityReplicaServerName] ASC,
[AvailabilityDatabaseName] ASC;
 
/*********************/
 
END;
ELSE
BEGIN
RAISERROR('Invalid AG name supplied, please correct and try again',12,0);
END;