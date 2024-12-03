
DECLARE @ProcName VARCHAR(max)
SET @ProcName  = 'MasterUser_UsernameAllowedForAccountRegistration'

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
WITH XMLNAMESPACES
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT 'Key look Up ',
    i.value('(@PhysicalOp)[1]', 'VARCHAR(128)') AS PhysicalOp,
    i.value('(./IndexScan/Object/@Database)[1]', 'VARCHAR(128)') AS DatabaseName,
    i.value('(./IndexScan/Object/@Schema)[1]', 'VARCHAR(128)') AS SchemaName,
    i.value('(./IndexScan/Object/@Table)[1]', 'VARCHAR(128)') AS TableName,
    i.value('(./IndexScan/Object/@Index)[1]', 'VARCHAR(128)') as IndexName,
    STUFF((SELECT DISTINCT ', ' + cg.value('(@Column)[1]', 'VARCHAR(128)')
       FROM i.nodes('./OutputList/ColumnReference') AS t(cg)
       FOR  XML PATH('')),1,2,'') AS output_columns,
    STUFF((SELECT DISTINCT ', ' + cg.value('(@Column)[1]', 'VARCHAR(128)')
       FROM i.nodes('./IndexScan/SeekPredicates/SeekPredicateNew//ColumnReference') AS t(cg)
       FOR  XML PATH('')),1,2,'') AS seek_columns,
    i.value('(./IndexScan/Predicate/ScalarOperator/@ScalarString)[1]', 'VARCHAR(4000)') as Predicate,
    cp.usecounts,OBJECT_NAME(object_id,database_id)AS StoredProcName,tab.query_plan
FROM (  SELECT plan_handle, query_plan
        FROM (  SELECT DISTINCT plan_handle
                FROM sys.dm_exec_query_stats WITH(NOLOCK)) AS qs
        OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) tp
      ) as tab (plan_handle, query_plan)
INNER JOIN sys.dm_exec_cached_plans AS cp 
    ON tab.plan_handle = cp.plan_handle
INNER JOIN sys.dm_exec_procedure_stats ps ON ps.plan_handle = cp.plan_handle
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/*') AS q(n)
CROSS APPLY n.nodes('.//RelOp[IndexScan[@Lookup="1"] and IndexScan/Object[@Schema!="[sys]"]]') as s(i)
WHERE OBJECT_NAME(object_id,database_id)  IN ( @ProcName)
OPTION(RECOMPILE, MAXDOP 1);


DECLARE @dbname SYSNAME 
SET @dbname = QUOTENAME(DB_NAME());



WITH XMLNAMESPACES 
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 

SELECT  distinct 
   t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)') AS TableName, 
   t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)') AS ColumnName, 
   ic.DATA_TYPE AS ConvertFrom, 
   ic.CHARACTER_MAXIMUM_LENGTH AS ConvertFromLength, 
   t.value('(@DataType)[1]', 'varchar(128)') AS ConvertTo, 
   t.value('(@Length)[1]', 'int') AS ConvertToLength, 
   OBJECT_NAME(ps.object_id,database_id)AS StoreProcName
FROM sys.dm_exec_cached_plans AS cp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt) 
CROSS APPLY stmt.nodes('.//Convert[@Implicit="1"]') AS n(t) 
JOIN   sys.dm_exec_procedure_stats ps ON ps.plan_handle = cp.plan_handle
JOIN INFORMATION_SCHEMA.COLUMNS AS ic 
   ON QUOTENAME(ic.TABLE_SCHEMA) = t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)') 
   AND QUOTENAME(ic.TABLE_NAME) = t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)') 
   AND ic.COLUMN_NAME = t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)') 
WHERE t.exist('ScalarOperator/Identifier/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]') = 1
AND  OBJECT_NAME(ps.object_id,database_id)  IN (@ProcName)


