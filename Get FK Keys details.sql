DECLARE @tablename VARCHAR(200)
SET @tablename = 'LoanContractPayments'

-- using sys tables to enumerate foreign keys
-- returns 45 constraint rows
 SELECT
    f.name constraint_name
   ,OBJECT_NAME(f.parent_object_id) referencing_table_name
   ,COL_NAME(fc.parent_object_id, fc.parent_column_id) referencing_column_name
   ,OBJECT_NAME (f.referenced_object_id) referenced_table_name
   ,COL_NAME(fc.referenced_object_id, fc.referenced_column_id) referenced_column_name
   ,delete_referential_action_desc
   ,update_referential_action_desc
FROM sys.foreign_keys AS f
INNER JOIN sys.foreign_key_columns AS fc
   ON f.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(f.parent_object_id) = @tablename OR OBJECT_NAME (f.referenced_object_id) =@tablename
ORDER BY f.name