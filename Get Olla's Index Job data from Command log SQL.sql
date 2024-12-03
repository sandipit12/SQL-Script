SELECT [CommandLog].[DatabaseName],CONVERT(time, 
  DATEADD(s, 
    DATEDIFF(s, 
      startTime, 
      EndTime), 
     CAST('1900-01-01 00:00:00' as datetime)
   )) [HH:MM:SS],IndexName,ObjectName tableName, IndexType,StartTime,EndTime,ErrorMessage 
,Command,ExtendedInfo.value('(/ExtendedInfo/PageCount)[1]','int') AS PageCount,ExtendedInfo.value('(/ExtendedInfo/Fragmentation)[1]','float') AS Fragmentation
FROM tools.dbo.CommandLog 
WHERE CommandType = 'ALTER_INDEX' 
--AND StartTime > DATEADD(DAY,-7,GETDATE()) --AND ExtendedInfo.value('(/ExtendedInfo/PageCount)[1]','int') <10000
AND ObjectName NOT LIKE'dbo_Users_CT'
ORDER BY StartTime desc




--Saturday
---- Stpe1
--sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Tools -Q "EXECUTE [dbo].[IndexOptimize] @Databases = 'Venus_Live', @Indexes=' 
--Venus_live.dbo.FinancialTransactions.IXNFinancialTransactions_UserId_CreateDate_TransactionType_INCLUDE_CompanyAccountId_UserAccount_FinancialType, 
--Venus_live.dbo.FinancialTransactions.IXN__FinancialTransactions__UserId_TransactionType_MarketId__INCLUDE__UserAccount_FinancialType_ProcessStatus_Amount', 
--Venus_live.dbo.FinancialTransactions.IXN__FinancialTransactions__UserId_CreateDate_TransactionType_INCLUDE_CompanyAccountId_UserAccount_FinancialType', 
--Venus_live.dbo.FinancialTransactions.IXN__FinancialTransactions__TransactionType_UserId_UserAccount_FinancialType_ProcessStatus_INCLUDE_Amount', 
--Venus_live.dbo.LoanContractPayments.PK_LoanContractPayments, 
--Venus_live.dbo.LoanContractPayments.IX_LoanContractPayments_SeqAndSettle 
--', @LogToTable = 'Y', @FragmentationLevel1=5, @FragmentationLevel2=40, @Execute='Y' " -b

--Step2
----sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Tools -Q "EXECUTE [dbo].[IndexOptimize] @Databases = 'Venus_Live', 
----  @LogToTable = 'Y', @FragmentationLevel1=15, @FragmentationLevel2=40 " -b

--Step3
----sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Tools -Q "EXECUTE [dbo].[IndexOptimize] @Databases = 'BorrowerLoan,CreditBureauReporting,CreditChecks,DataScience,AdobeeSign,DecisionEngine,IntroducerUsers,
---- MotorFinanceCollections,PortalDistributedCache,Tools,Umbraco_Business,Umbraco_Public,User_Authentication,VehicleData,Venus_Auth,Venus_LogsAdmin', 
----  @LogToTable = 'Y', @FragmentationLevel1=15, @FragmentationLevel2=40 " -b





--Sunday
--Step1

----sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Tools -Q "EXECUTE [dbo].[IndexOptimize] @Databases = 'Venus_Live', 
----  @LogToTable = 'Y', @FragmentationLevel1=15, @FragmentationLevel2=40  " -b

--Step2
----sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d Tools -Q "EXECUTE [dbo].[IndexOptimize] @Databases = 'BorrowerLoan,CreditBureauReporting,CreditChecks,DataScience,AdobeeSign,DecisionEngine,IntroducerUsers,
---- MotorFinanceCollections,PortalDistributedCache,Tools,Umbraco_Business,Umbraco_Public,User_Authentication,VehicleData,Venus_Auth,Venus_LogsAdmin', 
----  @LogToTable = 'Y', @FragmentationLevel1=15, @FragmentationLevel2=40 " -b