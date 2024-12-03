
--
----Database table indicating most number of DML opreation
--

SELECT d.name, t.name, OBJECT_NAME(A.[OBJECT_ID]) AS [OBJECT NAME],       
 I.[NAME] AS [INDEX NAME],       
  A.LEAF_INSERT_COUNT,        
  A.LEAF_UPDATE_COUNT,        
  A.LEAF_DELETE_COUNT

FROM   SYS.DM_DB_INDEX_OPERATIONAL_STATS (NULL,NULL,NULL,NULL ) A        
INNER JOIN SYS.INDEXES AS I          ON I.[OBJECT_ID] = A.[OBJECT_ID]   
join sys.tables t on i.object_id = t.object_id      
join sys.databases d on a.database_id = d.database_id
AND I.INDEX_ID = A.INDEX_ID WHERE  OBJECTPROPERTY(A.[OBJECT_ID],'IsUserTable') = 1 --AND  OBJECT_NAME(S.[OBJECT_ID]) ='Addresses'
order by A.LEAF_INSERT_COUNT + A.LEAF_UPDATE_COUNT + A.LEAF_DELETE_COUNT DESC


--
-- SELECT opreations
--

SELECT d.name as [Database],  OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME],          
I.[NAME] AS [INDEX NAME],          
USER_SEEKS,          
USER_SCANS,          
USER_LOOKUPS,          
USER_UPDATES 
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S          
INNER JOIN SYS.INDEXES AS I ON I.[OBJECT_ID] = S.[OBJECT_ID]               
AND I.INDEX_ID = S.INDEX_ID 
Join sys.Databases d on s.database_id = d.database_id
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 AND  OBJECT_NAME(S.[OBJECT_ID]) ='Addresses'
Order by d.name,USER_SEEKS + USER_SCANS + USER_LOOKUPS + USER_UPDATES desc