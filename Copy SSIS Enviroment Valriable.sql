--https://www.mssqltips.com/sqlservertip/5924/copy-or-duplicate-sql-server-integration-services-ssis-environments-using-tsql/

--Run on Source Server

SELECT e.[environment_id], e.[folder_id], e.[name] SOURCE_ENVIRONMENT,f.name  FOLDER_NAME
FROM [SSISDB].[catalog].[folders] f
JOIN [SSISDB].[catalog].[environments] e
   ON e.[folder_id] = f.[folder_id] 
WHERE f.[name] = N'DWH_Dev_Jakelyn'; -- Source that you want to clone
GO

-----------------------------------------------------------------------------------------------------------------------
-- Add Folder name and Its ENVIRONMENT name to SQL below
-- Copy Out put and paste in SSQL Below that we need to Run on Destinamtion Server
-----------------------------------------------------------------------------------------------------------------------
--Run on Source Server

DECLARE @FOLDER_NAME NVARCHAR(128) = N'DWH_Dev_Jakelyn'; -- Source Folder name that yuo want to clone
DECLARE @SOURCE_ENVIRONMENT NVARCHAR(128) = N'DEV_JAKELYN_DWH_SSIS1';  -- SOURCE ENVIRONMENT that yuo want to clone

SELECT ',(' +
    '''' + v.[name] + '''' + ',' +
    '''' + CONVERT(NVARCHAR(1024),ISNULL(v.[value], N'<VALUE GOES HERE>')) +
    ''''  + ',' +
    '''' + v.[description] + '''' +
    ')' ENVIRONMENT_VARIABLES
FROM [SSISDB].[catalog].[environments] e
JOIN [SSISDB].[catalog].[folders] f
   ON e.[folder_id] = f.[folder_id]
JOIN [SSISDB].[catalog].[environment_variables] v
   ON e.[environment_id] = v.[environment_id]
WHERE e.[name] = @SOURCE_ENVIRONMENT
AND f.[name] = @FOLDER_NAME
ORDER BY v.[name]
GO
-----------------------------------------------------------------------------------------------------------------------
-- Get the out put from above SQL and Paste result in Insert 
-----------------------------------------------------------------------------------------------------------------------

DECLARE @FOLDER_NAME NVARCHAR(MAX)= 'Sandip_Test'
DECLARE @TARGET_ENVIRONMENT_NAME NVARCHAR(MAX)= 'Sandip_Test_Evn'

DECLARE @folder_id1 BIGINT
EXEC [SSISDB].[catalog].[create_folder] @folder_name=@FOLDER_NAME , @folder_id=@folder_id1 OUTPUT
SELECT @folder_id1
EXEC [SSISDB].[catalog].[set_folder_description] @folder_name=@FOLDER_NAME, @folder_description=N''

EXEC [SSISDB].[catalog].[create_environment] @environment_name=@TARGET_ENVIRONMENT_NAME, @environment_description=N'', @folder_name=@FOLDER_NAME


DECLARE
-- @FOLDER_NAME             NVARCHAR(128) = N'Sandip_Test' -- 
@FOLDER_ID               BIGINT
--,@ TARGET_ENVIRONMENT_NAME NVARCHAR(128) = N'Sandip_Test_Evn'
,@ENVIRONMENT_ID          INT
,@VARIABLE_NAME           NVARCHAR(128)
,@VARIABLE_VALUE          NVARCHAR(1024)
,@VARIABLE_DESCRIPTION    NVARCHAR(1024)

DECLARE @ENVIRONMENT_VARIABLES TABLE (
  [name]        NVARCHAR(128)
, [value]       NVARCHAR(1024)
, [description] NVARCHAR(1024)
);				

INSERT @ENVIRONMENT_VARIABLES
SELECT [name], [value], [description]
FROM (
  VALUES
  --
  -- PASTE Result from Query Able here. Update connection string deatils before running to Query on destination server
  --
 ('ADONET_Destination_ConnectionString','Data Source=10.10.7.13,1955;Initial Catalog=DWH;Integrated Security=True;Application Name=SSIS-SSAS Process All Cubes;','')
,('ADONET_DWH_Documentation_ConnectionString','Data Source=10.10.7.13,1955;Initial Catalog=DWH_Documentation;Integrated Security=True;Application Name=DWH_Documentation;','Connection string to DWH_Documentation database')
,('ADONET_DWH_Documentation_Password','<VALUE GOES HERE>','Password to DWH_Documentation database')
,('ADONET_PowerBI_ConnectionString','Data Source=10.10.7.13,1955;Initial Catalog=PowerBI;Integrated Security=True;Application Name=SSIS-PowerBI;','Power BI ADONET connection string')
,('ADONET_PowerBI_Password','<VALUE GOES HERE>','Power BI ADONET Password')
,('ADONET_Source_Venus_Live_ConnectionString','Data Source=Clust01-Inst01;User ID=reportingLogin;Initial Catalog=Venus_Live;Persist Security Info=True;Application Name="DWH";ApplicationIntent=ReadOnly;','ADO Net connection string to Venus_Live')
,('ADONET_Source_Venus_Live_Node_C_ConnectionString','Data Source=Clust01-Inst01;User ID=reportingLogin;Initial Catalog=Venus_Live;ApplicationIntent=ReadOnly;','ADO Net connection string to Venus_Live Node C')
,('Database_Destination_ConnectionString','Data Source=10.10.7.13,1955;User ID=reportingLogin;Initial Catalog=DWH;Persist Security Info=True;Integrated Security=SSPI;','Data Source - Destination - ConectionString')
,('Database_Destination_Password','<VALUE GOES HERE>','SQL Server Database Destination')
,('Database_Source_ConnectionString','Data Source=Clust01-Inst01;User ID=reportingLogin;Initial Catalog=Venus_Live_Snapshot;Persist Security Info=True;Application Intent=READONLY;Provider=SQLNCLI11.1;','Data Source - Source - ConnectionString')
,('Database_Source_Log_ConnectionString','Data Source=Clust01-Inst01;User ID=reportingLogin;Initial Catalog=RSLogs;Persist Security Info=True;Application Intent=READONLY;Provider=SQLNCLI11.1;','RSLogs database source')
,('Database_Source_Log_Password','<VALUE GOES HERE>','RSLogs database password')
,('Database_Source_Password','<VALUE GOES HERE>','Data Source - Source - Password')
,('EnvironmentName','Production','To be sent on the emails')
,('OLEDB_Destination_ConnectionString','Data Source=10.10.7.13,1955;Initial Catalog=DWH;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;','')
,('OLEDB_DWH_ConnectionString','Data Source=10.10.7.13,1955;Initial Catalog=DWH;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;','OLEDB connection string')
,('OLEDB_DWH_Password','','')
,('OLEDB_Source_ConnectionString','Data Source=Clust01-Inst01;User ID=reportingLogin;Initial Catalog=Venus_Live_Snapshot;Persist Security Info=True;ApplicationIntent=ReadOnly;','')
,('OLEDB_Source_Venus_Live_ConnectionString','Data Source=Clust01-Inst01;User ID=reportingLogin;Initial Catalog=Venus_Live;Persist Security Info=True;Application Intent=READONLY;Provider=SQLNCLI11.1;','OLED DB connection string to Venus_Live')
,('OLEDB_Source_Venus_Live_Password','<VALUE GOES HERE>','OLED DB Password to Venus_Live')
,('OLEDB_SSAS_Source_ConnectionString','Data Source=UKS-RS-DW03;User ID=ratesetter\uks-rs-dw03_svc;Initial Catalog=BL - Borrower Loans;Provider=MSOLAP.6;','Connection string of the analysis services server we are monitoring')
,('OLEDB_SSAS_Source_Password','<VALUE GOES HERE>','Password of the analysis services server')
,('SendEmailIfFailureTo','dbateam@ratesetter.com','')
,('SendEmailIfSuccessTo','jakelyn.acevedo@ratesetter.com;Shaj.Miah@ratesetter.com;Christopher.New@ratesetter.com','')
,('SendEmailNotificationTo','dbateam@ratesetter.com','SendEmailNotificationTo')
,('SMTP_ConnectionString','SmtpServer=uks-iis-mail02.rsaziis.lan;UseWindowsAuthentication=False;EnableSsl=False;','SMTP connection string')
,('SSAS_Password','<VALUE GOES HERE>','')
,('SSAS_Server','AnalysisServices01.ratesetter.local','')
,('SSAS_UserName','ratesetter\uks-rs-dw03_svc','')
  --
  --
) AS v([name], [value], [description]);
 
SELECT * FROM @ENVIRONMENT_VARIABLES;  -- debug output	



SELECT TOP 1
 @VARIABLE_NAME = [name]
,@VARIABLE_VALUE = [value]
,@VARIABLE_DESCRIPTION = [description]
FROM @ENVIRONMENT_VARIABLES
WHILE @VARIABLE_NAME IS NOT NULL
BEGIN
   PRINT @VARIABLE_NAME
    -- create environment variable if it doesn't exist
   IF NOT EXISTS (
      SELECT 1 FROM [SSISDB].[catalog].[environment_variables] 
      WHERE environment_id = @ENVIRONMENT_ID AND name = @VARIABLE_NAME
   )
      EXEC [SSISDB].[catalog].[create_environment_variable]
        @variable_name=@VARIABLE_NAME
      , @sensitive=0
      , @description=@VARIABLE_DESCRIPTION
      , @environment_name=@TARGET_ENVIRONMENT_NAME
      , @folder_name=@FOLDER_NAME
      , @value=@VARIABLE_VALUE
      , @data_type=N'String'
   ELSE
    -- update environment variable value if it exists
      EXEC [SSISDB].[catalog].[set_environment_variable_value]
        @folder_name = @FOLDER_NAME
      , @environment_name = @TARGET_ENVIRONMENT_NAME
      , @variable_name = @VARIABLE_NAME
      , @value = @VARIABLE_VALUE
   DELETE TOP (1) FROM @ENVIRONMENT_VARIABLES
   SET @VARIABLE_NAME = null
   SELECT TOP 1
     @VARIABLE_NAME = [name]
    ,@VARIABLE_VALUE = [value]
    ,@VARIABLE_DESCRIPTION = [description]
    FROM @ENVIRONMENT_VARIABLES
END			