 
 
/*

http://www.nikoport.com/2015/12/22/how-to-use-cisl-the-columnstore-indexes-scripts-library/

@minRowsToConsider bigint = 500000 – This parameter defines the minimum number of rows for a table to be considered for the suggestion inclusion.
The default parameter is set to 500.000, which represents around 50% of the maximum size for a Row Group.
@minSizeToConsiderInGB Decimal(16,3) = 0.00 – Defines the minimum size in GB for a table to be considered for the suggestion inclusion.
You can use this parameter to filter out the tables that are too small to be interested for converting to Columnstore technology.
This parameter is set to 0 by default, meaning that every table will be considered.
@schemaName nvarchar(256) = NULL – this parameter allows to show data filtered down to the specified schema.
By default it is set to NULL meaning all schemas of the table will be considered.
@tableName nvarchar(256) = NULL – Allows to show data filtered down to the specified table name pattern.
By default it is set to NULL meaning that all tables in the database will be considered.
@considerColumnsOver8K bit = 1, – shows the tables which columns length sum extends over 8000 bytes and thus not supported in Columnstore Indexes.
This parameter is enabled by default, meaning that those tables that needs some significant work – such as redesigning the table.
@showReadyTablesOnly bit = 0 – this one shows only those Rowstore tables that can already get Columnstore Index without any additional work.
By default this parameter is disabled.
@showUnsupportedColumnsDetails bit = 0 – this parameter shows in a separate result set a list of all unsupported columns from the suggested tables.
By default it is disabled.
@showTSQLCommandsBeta bit = 0 – Shows a list with Commands for dropping the objects that prevent Columnstore Index creation and then creating
Notice that this command is in the early beta phase and is not production ready, but serves more as a guide in the conversion process.
This parameter is disabled by default.
@columnstoreIndexTypeForTSQL varchar(20) = ‘Clustered’ – Allows to define the type of Columnstore Index to be created if the parameter @showTSQLCommandsBeta is set to 1, with possible values of ‘Clustered’ and ‘Nonclustered’.
This parameter is set to create Clustered Columnstore Index by default.
*/

EXEC tools.dbo.cstore_SuggestedTables 	@dbName = 'DWH_TeamCreditRisk_ColumnStored_Test',	
                                        @showReadyTablesOnly = 1,	
										@tableName ='DecisionEngine_NodeOutput',
										@showTSQLCommandsBeta = 1 -- Gives to details o TSQL Code to Convert table to C Store
										
-------------------------------------------------------------------------------------------
/*
script gives a great overview over the different internal structures within Columnstore Indexes. 
It provides information on all types of Row Groups with Columnstore Indexes, the total number of rows, the number of deleted rows, sizes in GB of the whole Columnstore Structure
*/
-------------------------------------------------------------------------------------------
EXEC Tools.dbo.cstore_GetRowGroups  @dbname = 'DWH_TeamCreditRisk_ColumnStored_Test' 

-------------------------------------------------------------------------------------------
/*
script shows detailed information on the Columnstore Row Groups by listing & filtering all row groups that contained within filtered tables with Columnstore Indexes.
*/
-------------------------------------------------------------------------------------------

  
 EXEC tools.dbo.cstore_GetRowGroupsDetails @dbname = 'DWH_TeamCreditRisk_ColumnStored_Test',@tablename =  'Data_Pro_Req_Logs_BSB_First500',@showTrimmedGroupsOnly = 1;
 exec tools.dbo.cstore_GetRowGroupsDetails @showNonCompressedOnly = 1;
 exec tools.dbo.cstore_GetRowGroupsDetails @showFragmentedGroupsOnly = 1;

 -------------------------------------------------------------------------------------------
/*
script is showing the alignment (ordering) between the different Columnstore Segments
*/
-------------------------------------------------------------------------------------------

 EXEC Tools.dbo.cstore_GetAlignment @dbname = 'DWH_TeamCreditRisk_ColumnStored_Test'

  -------------------------------------------------------------------------------------------
/*
This script shows detailed information about the Columnstore Dictionaries, showing aggregated and detailed information about each of the dictionaries and columns in Columnstore Indexes.
*/

 EXEC tools.dbo.cstore_GetDictionaries @dbname = 'DWH_TeamCreditRisk_ColumnStored_Test'
  EXEC Tools.dbo.cstore_GetDictionaries @dbname = 'DWH_TeamCreditRisk_ColumnStored_Test', @showWarningsOnly = 1;
 EXEC Tools.dbo.cstore_GetDictionaries @dbname = 'DWH_TeamCreditRisk_ColumnStored_Test', @showAllTextDictionaries = 1;
-------------------------------------------------------------------------------------------

 EXEC tools.dbo.cstore_GetSQLInfo;
 exec tools.dbo.cstore_GetSQLInfo @showNewerVersions = 1;

 dbcc traceon (634,-1);  -- Disable Automatic Tuple Mover Process 

 SELECT object_name(p.object_id) as TableName,
		p.partition_number as Partition,
		cast( Avg( (rg.deleted_rows * 1. / rg.total_rows) * 100 ) as Decimal(5,2)) as 'Total Fragmentation (Percentage)',
		sum (case rg.deleted_rows when rg.total_rows then 1 else 0 end ) as 'Deleted Segments Count',
		cast( (sum (case rg.deleted_rows when rg.total_rows then 1 else 0 end ) * 1. / count(*)) * 100 as Decimal(5,2)) as 'DeletedSegments (Percentage)'
	FROM sys.partitions AS p 
		INNER JOIN sys.column_store_row_groups rg
			ON p.object_id = rg.object_id 
	where rg.state = 3 -- Compressed (Ignoring: 0 - Hidden, 1 - Open, 2 - Closed, 4 - Tombstone) 
	group by p.object_id, p.partition_number
	order by object_name(p.object_id);