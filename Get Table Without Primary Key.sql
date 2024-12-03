DROP TABLE IF EXISTS #temp
CREATE TABLE #temp
([DB_Name]  Varchar(100),TableName Varchar(150) )

USE [PortalDistributedCache] 

INSERT INTO #temp(DB_Name,TableName) SELECT  'PortalDistributedCache' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%' 
 USE [Venus_Live] 
INSERT INTO #temp(DB_Name,TableName) SELECT  'Venus_Live' AS [DB_Name], name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [CreditChecks] 
INSERT INTO #temp(DB_Name,TableName) SELECT  'CreditChecks' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DataScience] 
INSERT INTO #temp(DB_Name,TableName) SELECT   'DataScience' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DecisionEngine] 
INSERT INTO #temp(DB_Name,TableName) SELECT   'DecisionEngine' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [RSDocuments] 
INSERT INTO #temp(DB_Name,TableName) SELECT   'RSDocuments' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [RSLogs] INSERT INTO #temp(DB_Name,TableName) SELECT   'RSLogs' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [Venus_Auth] INSERT INTO #temp(DB_Name,TableName) SELECT   '[Venus_Auth' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [Venus_LogsAdmin] INSERT INTO #temp(DB_Name,TableName) SELECT   'Venus_LogsAdmin' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [Umbraco_Business] INSERT INTO #temp(DB_Name,TableName) SELECT   'Umbraco_Business' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [BorrowerLoan] INSERT INTO #temp(DB_Name,TableName) SELECT   'BorrowerLoan' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [MotorFinanceCollections] INSERT INTO #temp(DB_Name,TableName) SELECT  'MotorFinanceCollections' AS [DB_name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [Umbraco_Public] INSERT INTO #temp(DB_Name,TableName) SELECT   'Umbraco_Public' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [VehicleData] INSERT INTO #temp(DB_Name,TableName) SELECT   'VehicleData' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [IntroducerUsers] INSERT INTO #temp(DB_Name,TableName) SELECT   'IntroducerUsers' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [UserAuthentication] INSERT INTO #temp(DB_Name,TableName) SELECT   'UserAuthentication' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DecisionEngine_DataProvider_CallCredit] INSERT INTO #temp(DB_Name,TableName) SELECT   'DecisionEngine_DataProvider_CallCredit' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [CreditBureauReporting] INSERT INTO #temp(DB_Name,TableName) SELECT   'CreditBureauReporting' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DecisionEngine_DataProvider_DecisionEngine] INSERT INTO #temp(DB_Name,TableName) SELECT   'DecisionEngine_DataProvider_DecisionEngine' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DecisionEngine_StageEditor] INSERT INTO #temp(DB_Name,TableName) SELECT   'DecisionEngine_StageEditor' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DecisionEngine_PreProcessor] INSERT INTO #temp(DB_Name,TableName) SELECT   'DecisionEngine_PreProcessor' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DecisionEngine_DataProviders_Gateway] INSERT INTO #temp(DB_Name,TableName) SELECT   'DecisionEngine_DataProviders_Gateway' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DecisionEngine_DataProvider_Venus] INSERT INTO #temp(DB_Name,TableName) SELECT   'DecisionEngine_DataProvider_Venus' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DecisionEngine_DataProvider_Equifax] INSERT INTO #temp(DB_Name,TableName) SELECT   'DecisionEngine_DataProvider_Equifax' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [Lender] INSERT INTO #temp(DB_Name,TableName) SELECT   'Lender' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [NotificationsWebHooks] INSERT INTO #temp(DB_Name,TableName) SELECT   'NotificationsWebHooks' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [DealershipPortal] INSERT INTO #temp(DB_Name,TableName) SELECT   'DealershipPortal' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [AdobeeSign] INSERT INTO #temp(DB_Name,TableName) SELECT   'AdobeeSign' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
 USE [InvestorMoneyOutHolding] INSERT INTO #temp(DB_Name,TableName) SELECT   'InvestorMoneyOutHolding' AS [DB_Name],name AS TableName
FROM sys.tables
WHERE OBJECTPROPERTY(OBJECT_ID,'TableHasPrimaryKey') = 0
AND name NOT LIKE '%_CT%'
				
SELECT *,'No Primary Key' AS Message FROM #temp 

			