



EXEC tools.[dbo].[sp_foreachdb]  @command = 
N'

use ?
INSERT into tools.[dbo].[SandipTableCompressionStats]
SELECT db_name() as DB_Name, Object_name(o.object_id)[table]
,ix.name [index_name]
,sp.data_compression
,sp.data_compression_desc

FROM sys.partitions SP 
LEFT JOIN sys.Objects o 
on o.object_id = sp.object_id
LEFT OUTER JOIN sys.indexes IX 
ON sp.object_id = ix.object_id 
and sp.index_id = ix.index_id
WHERE sp.data_compression <> 0  and o.type_desc = ''USER_TABLE''
'