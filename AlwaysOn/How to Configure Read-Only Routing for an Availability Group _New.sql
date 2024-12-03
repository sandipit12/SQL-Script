-- https://www.sqlshack.com/how-to-configure-read-only-routing-for-an-availability-group-in-sql-server-2016/

--Availability Group Listener is Configuration 

SELECT	AV.name AS AVGName
	, AVGLis.dns_name AS ListenerName
	, AVGLis.ip_configuration_string_from_cluster AS ListenerIP ,port,AV.failure_condition_level,AV.health_check_timeout
FROM	sys.availability_group_listeners AVGLis
INNER JOIN sys.availability_groups AV on AV.group_id = AV.group_id
 
 SELECT replica_server_name
	, read_only_routing_url
	, secondary_role_allow_connections_desc , primary_role_allow_connections_desc,availability_mode_desc,endpoint_url,backup_priority,seeding_mode_desc
FROM sys.availability_replicas

SELECT	  AVGSrc.replica_server_name AS SourceReplica		
		, AVGRepl.replica_server_name AS ReadOnlyReplica
		, AVGRepl.read_only_routing_url AS RoutingURL
		, AVGRL.routing_priority AS RoutingPriority
FROM sys.availability_read_only_routing_lists AVGRL
INNER JOIN sys.availability_replicas AVGSrc ON AVGRL.replica_id = AVGSrc.replica_id
INNER JOIN sys.availability_replicas AVGRepl ON AVGRL.read_only_replica_id = AVGRepl.replica_id
INNER JOIN sys.availability_groups AV ON AV.group_id = AVGSrc.group_id
ORDER BY SourceReplica