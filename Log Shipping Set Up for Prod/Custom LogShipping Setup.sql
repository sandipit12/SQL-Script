USE [msdb]
GO

/****** Object:  Job [1. Custom Log Shipping Restore Full and Diff backup]    Script Date: 04/11/2019 11:18:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 04/11/2019 11:18:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'1. Custom Log Shipping Restore Full and Diff backup', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Restore Full and Diff First to Start Custom Log shipping', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'RATESETTER\Sandip.Patel', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore Full and Diff First to Start Custom Log shipping]    Script Date: 04/11/2019 11:18:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore Full and Diff First to Start Custom Log shipping', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''PortalDistributedCache''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\PortalDistributedCache\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\PortalDistributedCache\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
--EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Venus_Live''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage1\SQLBackups\SQL-CL01$AG01\Venus_Live\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage1\SQLBackups\SQL-CL01$AG01\Venus_Live\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''CreditChecks''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\CreditChecks\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\CreditChecks\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DataScience''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DataScience\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DataScience\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
--EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DecisionEngine''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
--EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''RSDocuments''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage06\SQLBackups\SQL-CL01$AG01\RSDocuments\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage06\SQLBackups\SQL-CL01$AG01\RSDocuments\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
--EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''RSLogs''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage08\SQLBackups\SQL-CL01$AG01\RSLogs\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage08\SQLBackups\SQL-CL01$AG01\RSLogs\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Venus_Auth''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Venus_Auth\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Venus_Auth\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Venus_LogsAdmin''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Venus_LogsAdmin\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Venus_LogsAdmin\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Umbraco_Business''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Umbraco_Business\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Umbraco_Business\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''BorrowerLoan''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\BorrowerLoan\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\BorrowerLoan\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''MotorFinanceCollections''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\MotorFinanceCollections\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\MotorFinanceCollections\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Umbraco_Public''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Umbraco_Public\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Umbraco_Public\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''VehicleData''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\VehicleData\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\VehicleData\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''IntroducerUsers''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\IntroducerUsers\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\IntroducerUsers\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''UserAuthentication''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\UserAuthentication\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\UserAuthentication\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DecisionEngine_DataProvider_CallCredit''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProvider_CallCredit\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProvider_CallCredit\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''CreditBureauReporting''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\CreditBureauReporting\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\CreditBureauReporting\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DecisionEngine_DataProvider_DecisionEngine''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProvider_DecisionEngine\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProvider_DecisionEngine\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DecisionEngine_StageEditor''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_StageEditor\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_StageEditor\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DecisionEngine_PreProcessor''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_PreProcessor\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_PreProcessor\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DecisionEngine_DataProviders_Gateway''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProviders_Gateway\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProviders_Gateway\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DecisionEngine_DataProvider_Venus''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProvider_Venus\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProvider_Venus\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DecisionEngine_DataProvider_Equifax''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProvider_Equifax\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_DataProvider_Equifax\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Lender''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Lender\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Lender\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''NotificationsWebHooks''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\NotificationsWebHooks\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\NotificationsWebHooks\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DealershipPortal''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DealershipPortal\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DealershipPortal\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''AdobeeSign''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\AdobeeSign\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\AdobeeSign\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''InvestorMoneyOutHolding''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\InvestorMoneyOutHolding\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\InvestorMoneyOutHolding\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''PaymentSchedule''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\PaymentSchedule\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\PaymentSchedule\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DocumentManagement''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DocumentManagement\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DocumentManagement\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''TokenManager''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\TokenManager\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\TokenManager\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''AdviserManagement''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\AdviserManagement\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\AdviserManagement\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Phoenix_Episerver''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Phoenix_Episerver\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Phoenix_Episerver\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''NotificationsServiceLog''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\NotificationsServiceLog\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\NotificationsServiceLog\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Bureau_Equifax''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Bureau_Equifax\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Bureau_Equifax\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DataProvider_Emailage''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DataProvider_Emailage\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DataProvider_Emailage\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DecisionEngine_StrategyEditor''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_StrategyEditor\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DecisionEngine_StrategyEditor\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Bureau_CallCredit''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Bureau_CallCredit\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Bureau_CallCredit\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Bureau_CIFAS''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Bureau_CIFAS\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Bureau_CIFAS\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DistributedSettlement''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DistributedSettlement\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DistributedSettlement\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Pricing''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Pricing\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Pricing\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''DataProvider_CIFAS''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DataProvider_CIFAS\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\DataProvider_CIFAS\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''MockService''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\MockService\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\MockService\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Bureau_RDC''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Bureau_RDC\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Bureau_RDC\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''Dataprovider_RDC''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Dataprovider_RDC\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\Dataprovider_RDC\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''
EXEC dbo.AutoRestore_RestoreLatestBackup   @DataBaseName    = ''AuditTrail''  ,@FullBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\AuditTrail\FULL\''   ,@DiffBackupPath = ''\\rsstandardstorage.file.core.windows.net\sqlstorage04\SQLBackups\SQL-CL01$AG01\AuditTrail\DIFF\''  ,@RestoreDataPath = ''E:\data\'',@RestoreLogPath  = ''E:\Log\''', 
		@database_name=N'Tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [2. Custom Log Shipping - Main]    Script Date: 04/11/2019 11:18:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 04/11/2019 11:18:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'2. Custom Log Shipping - Main', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Custom Log Shipping - Restore Logs]    Script Date: 04/11/2019 11:18:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Custom Log Shipping - Restore Logs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.CustomLogShipping_RestoreLogs', 
		@database_name=N'Tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run Check]    Script Date: 04/11/2019 11:18:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Check', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.CustomLogShipping_Check', 
		@database_name=N'Tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Custom Log Shipping Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160722, 
		@active_end_date=99991231, 
		@active_start_time=500, 
		@active_end_time=235959, 
		@schedule_uid=N'2ddd047a-b048-4efb-816f-37bf1097fcee'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Custom Log Shipping - CleanUp]    Script Date: 04/11/2019 11:18:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 04/11/2019 11:18:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Custom Log Shipping - CleanUp', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This Job Will remove Log Files So do not Start this Job', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Custom Log Shipping - CleanUp]    Script Date: 04/11/2019 11:18:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Custom Log Shipping - CleanUp', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.CustomLogShipping_CleanUp', 
		@database_name=N'Tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Custom Log Shipping - CleanUp', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160725, 
		@active_end_date=99991231, 
		@active_start_time=170000, 
		@active_end_time=235959, 
		@schedule_uid=N'fd171336-9702-4376-b992-0cb6706cdf8c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Custom Log Shipping - Fix]    Script Date: 04/11/2019 11:18:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 04/11/2019 11:18:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Custom Log Shipping - Fix', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CustomLogShipping_RestartLogShipping]    Script Date: 04/11/2019 11:18:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CustomLogShipping_RestartLogShipping', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.CustomLogShipping_RestartLogShipping', 
		@database_name=N'Tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CustomLogShipping_RstoreWithRecovery]    Script Date: 04/11/2019 11:18:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CustomLogShipping_RstoreWithRecovery', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.CustomLogShipping_RstoreWithRecovery', 
		@database_name=N'Tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Custom Log Shipping - Monitor]    Script Date: 04/11/2019 11:18:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 04/11/2019 11:18:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Custom Log Shipping - Monitor', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Custom Log Shipping - Monitor]    Script Date: 04/11/2019 11:18:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Custom Log Shipping - Monitor', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.CustomLogShipping_Monitor', 
		@database_name=N'Tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Custom Log Shipping - Notify]    Script Date: 04/11/2019 11:18:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Custom Log Shipping - Notify', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC CustomLogShipping_Notify', 
		@database_name=N'Tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'CustomLogShipping_MonitorSchedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160811, 
		@active_end_date=99991231, 
		@active_start_time=900, 
		@active_end_time=235959, 
		@schedule_uid=N'9ff2ab85-f2cf-4e3f-a8c1-72b768c03187'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


USE [Tools]
GO

/****** Object:  Table [dbo].[LogShippingConfiguration]    Script Date: 04/11/2019 11:18:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LogShippingConfiguration](
	[DatabaseName] [NVARCHAR](255) NOT NULL,
	[IsActive] [BIT] NOT NULL,
	[LogBackupPath] [NVARCHAR](4000) NOT NULL,
	[FullBackupPath] [NVARCHAR](4000) NULL,
	[DiffBackupPath] [NVARCHAR](4000) NULL,
	[LowPriorityDelayInMinutes] [INT] NOT NULL,
	[MediumPriorityDelayInMinutes] [INT] NOT NULL,
	[HighPriorityDelayInMinutes] [INT] NOT NULL,
	[EmailList] [NVARCHAR](4000) NULL,
	[RstoreWithRecovery] [BIT] NOT NULL,
	[RestartShipping] [BIT] NOT NULL,
	[LogFileNamePattern] [NVARCHAR](1000) NOT NULL,
 CONSTRAINT [PK_LogShippingConfiguration] PRIMARY KEY CLUSTERED 
(
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LogShippingMonitorLog]    Script Date: 04/11/2019 11:18:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LogShippingMonitorLog](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[CreateDate] [DATETIME] NULL,
	[DatabaseName] [NVARCHAR](255) NULL,
	[MessageSubject] [NVARCHAR](255) NULL,
	[MessageBody] [NVARCHAR](4000) NULL,
	[SeverityLevel] [INT] NULL,
	[IsResolved] [BIT] NULL,
	[MessageSent] [BIT] NULL,
 CONSTRAINT [PK_LogShippingMonitorLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LogShippingRestoreLog]    Script Date: 04/11/2019 11:18:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LogShippingRestoreLog](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[CreateDate] [DATETIME] NULL,
	[DatabaseName] [NVARCHAR](255) NULL,
	[FileName] [NVARCHAR](4000) NULL,
	[FileTimeStamp]  AS (SUBSTRING([FileName],PATINDEX('%________[_]______.%',[FileName]),CHARINDEX('.',[FileName])-PATINDEX('%________[_]______.%',[FileName]))),
	[RestoreStatus] [INT] NULL,
	[LastRestoredLSN] [NUMERIC](25, 0) NULL,
 CONSTRAINT [PK_LogShippingRestoreLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


USE [Tools]
GO

/****** Object:  StoredProcedure [dbo].[AutoRestore_RestoreLatestBackup]    Script Date: 04/11/2019 11:19:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AutoRestore_RestoreLatestBackup]
 @DataBaseName NVARCHAR(256)
,@FullBackupPath NVARCHAR(4000)
,@DiffBackupPath NVARCHAR(4000)
,@RestoreDataPath NVARCHAR(4000)
,@RestoreLogPath NVARCHAR(4000)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @cmd NVARCHAR(4000) 
	DECLARE @FullFileList TABLE (backupFile NVARCHAR(4000), BackupOrder INT) 
	DECLARE @DiffFileList TABLE (backupFile NVARCHAR(4000), BackupOrder INT) 
	DECLARE @lastFullBackup NVARCHAR(4000) 
	DECLARE @lastDiffBackup NVARCHAR(4000)
	DECLARE @SQL NVARCHAR(MAX)
	DECLARE @FileListSQL NVARCHAR(2000)
	DECLARE @YesterdayName NVARCHAR(500) = DATENAME(WEEKDAY, DATEADD(DD,-1,GETDATE()))
    DECLARE @BackupFileList TABLE
        (
         LogicalName NVARCHAR(128)
       , PhysicalName NVARCHAR(260)
       , Type CHAR(1)
       , FileGroupName NVARCHAR(128)
       , Size NUMERIC(20, 0)
       , MaxSize NUMERIC(20, 0)
       , Fileid TINYINT
       , CreateLSN NUMERIC(25, 0)
       , DropLSN NUMERIC(25, 0)
       , UniqueID UNIQUEIDENTIFIER
       , ReadOnlyLSN NUMERIC(25, 0)
       , ReadWriteLSN NUMERIC(25, 0)
       , BackupSizeInBytes BIGINT
       , SourceBlocSize INT
       , FileGroupId INT
       , LogGroupGUID UNIQUEIDENTIFIER
       , DifferentialBaseLSN NUMERIC(25, 0)
       , DifferentialBaseGUID UNIQUEIDENTIFIER
       , IsReadOnly BIT
       , IsPresent BIT
       , TDEThumbprint varbinary(32)
       , SnapshotURL NVARCHAR(360)
        );

	DECLARE @IsShowAdvancedOptionsOn BIT
	DECLARE @IsXp_cmdshellOn BIT

	SELECT @IsShowAdvancedOptionsOn = CAST (value_in_use AS BIT)
	FROM sys.configurations
	WHERE name = 'show advanced options'

	SELECT @IsXp_cmdshellOn = CAST (value_in_use AS BIT)
	FROM sys.configurations
	WHERE name = 'xp_cmdshell'

	IF @IsShowAdvancedOptionsOn = 0
	BEGIN 
		EXEC sp_configure 'show advanced options', 1
		RECONFIGURE
	END

	IF @IsXp_cmdshellOn = 0
	BEGIN 
		EXEC sp_configure 'xp_cmdshell', 1
		RECONFIGURE
	END

	SET @cmd = 'DIR /b ' + @FullBackupPath 

	INSERT INTO @FullFileList(backupFile) 
	EXEC master.sys.xp_cmdshell @cmd 

	SET @cmd = 'DIR /b ' + @DiffBackupPath 

	INSERT INTO @DiffFileList(backupFile) 
	EXEC master.sys.xp_cmdshell @cmd 

	IF @IsXp_cmdshellOn = 0
	BEGIN 
		EXEC sp_configure 'xp_cmdshell', 0
		RECONFIGURE
	END

	IF @IsShowAdvancedOptionsOn = 0
	BEGIN 
		EXEC sp_configure 'show advanced options', 0
		RECONFIGURE
	END

	;WITH CTE_Order AS (
	SELECT *, ROW_NUMBER() OVER (ORDER BY backupFile DESC) AS RowNo
	FROM @FullFileList)
	UPDATE CTE_Order SET BackupOrder = RowNo

	;WITH CTE_Order AS (
	SELECT *, ROW_NUMBER() OVER (ORDER BY backupFile DESC) AS RowNo
	FROM @DiffFileList)
	UPDATE CTE_Order SET BackupOrder = RowNo

	SELECT @lastFullBackup = @FullbackupPath+backupFile
	FROM @FullFileList
	WHERE BackupOrder = 1

	SELECT @lastDiffBackup = @DiffbackupPath+backupFile
	FROM @DiffFileList
	WHERE BackupOrder = 1

	SET @FileListSQL = 'RESTORE FILELISTONLY FROM DISK='''+@lastFullBackup+''''

	INSERT INTO @BackupFileList
	EXEC (@FileListSQL)


	DECLARE @LogicalName NVARCHAR(128)
	DECLARE @Type CHAR(1)
	DECLARE @FileID TINYINT
    DECLARE @FullFilePath NVARCHAR(MAX)
	
	DECLARE FileList_Cur CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT BFL.LogicalName, BFL.Type, BFL.Fileid
	FROM @BackupFileList AS BFL
	
	SET @SQL = 'RESTORE DATABASE ['+@DataBaseName+'] FROM  DISK = N'''+@lastFullBackup+''' WITH FILE = 1 ' + CHAR(13)
	         + ', NORECOVERY, REPLACE, STATS = 10' + CHAR(13)

	OPEN FileList_Cur
	
	FETCH NEXT FROM FileList_Cur INTO @LogicalName, @Type, @FileID
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		SET @FullFilePath = CASE WHEN @Type = 'L' THEN @RestoreLogPath ELSE @RestoreDataPath END
		                  +@DataBaseName+'_'
		                  +@LogicalName
						  + CASE 
						        WHEN @Type = 'L' THEN '.ldf' 
							    ELSE 
							        CASE 
								        WHEN @FileID = 1 THEN '.mdf'
										ELSE '.ndf'
                                    END
							END
	    
		SET @SQL = @SQL + ', MOVE N'''+@LogicalName+''' TO N'''+@FullFilePath+''''+CHAR(13)

	    FETCH NEXT FROM FileList_Cur INTO @LogicalName, @Type, @FileID
	END
	
	CLOSE FileList_Cur
	DEALLOCATE FileList_Cur

	EXEC (@SQL)

	IF @YesterdayName != 'Saturday'
	BEGIN
		SET @SQL = 'RESTORE DATABASE ['+@DataBaseName+'] FROM  DISK = N'''+@lastDiffBackup+''' WITH  FILE = 1, NORECOVERY,  NOUNLOAD,  STATS = 5'
		EXEC (@SQL)
	END

	--SET @SQL = 'RESTORE DATABASE ['+@DataBaseName+'] WITH No RECOVERY'
	--EXEC (@SQL)
END
GO

/****** Object:  StoredProcedure [dbo].[CustomLogShipping_Check]    Script Date: 04/11/2019 11:19:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CustomLogShipping_Check]
AS

	IF EXISTS (SELECT * FROM dbo.LogShippingConfiguration AS LSC WHERE LSC.RstoreWithRecovery = 1 AND LSC.RestartShipping = 1 AND LSC.IsActive = 1)
	BEGIN
		RAISERROR ('Both options RstoreWithRecovery and RestartShipping can not be set to true at once', 16, 1)
		UPDATE dbo.LogShippingConfiguration SET RstoreWithRecovery = 0, RestartShipping = 0 WHERE RstoreWithRecovery = 1 AND RestartShipping = 1 AND IsActive = 1
		RETURN
	END
	IF EXISTS ( SELECT * FROM dbo.LogShippingConfiguration AS LSC WHERE (LSC.RstoreWithRecovery = 1 OR LSC.RestartShipping = 1) AND LSC.IsActive = 1)
	BEGIN
		EXEC msdb.dbo.sp_start_job @job_name = 'Custom Log Shipping - Fix'
	END
GO

/****** Object:  StoredProcedure [dbo].[CustomLogShipping_CleanUp]    Script Date: 04/11/2019 11:19:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CustomLogShipping_CleanUp]
AS
SET NOCOUNT ON

DECLARE @DatabaseName NVARCHAR(255)
DECLARE @BackupPath NVARCHAR(4000)

DECLARE LogShippingCleanUp_Cur CURSOR FAST_FORWARD READ_ONLY FOR 
SELECT LSC.DatabaseName, LSC.LogBackupPath
FROM dbo.LogShippingConfiguration AS LSC
WHERE LSC.IsActive = 1

OPEN LogShippingCleanUp_Cur

FETCH NEXT FROM LogShippingCleanUp_Cur INTO @DatabaseName, @BackupPath

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE @LatestBackupTimeStamp DATETIME
	DECLARE @StandardCleanupTime DATETIME
	DECLARE @CleanupTime DATETIME
	DECLARE @LatestBackupID INT
	DECLARE @StandardCleanUpID INT
	DECLARE @CleanupID INT

	SELECT TOP 1 @LatestBackupTimeStamp = CAST(FORMAT(CAST(REPLACE(FileTimeStamp, '_', '') AS numeric(25, 0)), '######## ##:##:##') AS DATETIME)
	FROM dbo.LogShippingRestoreLog
	WHERE RestoreStatus = 0 AND DatabaseName = @DatabaseName
	ORDER BY ID DESC

	SET @StandardCleanupTime = DATEADD(HOUR, -169, GETDATE())
	SET @LatestBackupTimeStamp = DATEADD(HOUR, -1, @LatestBackupTimeStamp)

	SET @CleanupTime = CASE WHEN @LatestBackupTimeStamp < @StandardCleanupTime THEN @LatestBackupTimeStamp ELSE @StandardCleanupTime END

	PRINT 'Deleting backups before date:'
	PRINT @CleanupTime
	PRINT 'From path:'
	PRINT @BackupPath
	PRINT ''

	EXEC sys.xp_delete_file 0, @BackupPath, 'trn', @CleanupTime, 0

	SELECT TOP 1 @LatestBackupID = ISNULL(@LatestBackupID, 0)
	FROM dbo.LogShippingRestoreLog
	WHERE RestoreStatus = 0 AND DatabaseName = @DatabaseName
	ORDER BY ID DESC

	SET @StandardCleanUpID = (SELECT TOP 1 ID FROM dbo.LogShippingRestoreLog ORDER BY ID DESC) - 100000 

	SET @CleanupID = CASE WHEN @LatestBackupID < @StandardCleanUpID THEN @LatestBackupID ELSE @StandardCleanUpID END

	DELETE FROM dbo.LogShippingRestoreLog WHERE ID < @CleanupID AND DatabaseName = @DatabaseName

    FETCH NEXT FROM LogShippingCleanUp_Cur INTO @DatabaseName, @BackupPath
END

CLOSE LogShippingCleanUp_Cur
DEALLOCATE LogShippingCleanUp_Cur
GO

/****** Object:  StoredProcedure [dbo].[CustomLogShipping_Monitor]    Script Date: 04/11/2019 11:19:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CustomLogShipping_Monitor]
AS
BEGIN
    DECLARE @DatabaseName NVARCHAR(255)
	DECLARE @Recepients varchar(max)
	DECLARE @Subject nvarchar(255)
	DECLARE @Body nvarchar(max)
	DECLARE @SeverityLevel INT
	DECLARE @MessageID INT
	DECLARE @DelayInMinutes INT
	DECLARE @Low INT, @Medium INT, @High INT

DECLARE MonitorLog_Cur CURSOR FAST_FORWARD READ_ONLY FOR 
SELECT LSC.DatabaseName, LSC.LowPriorityDelayInMinutes, LSC.MediumPriorityDelayInMinutes, LSC.HighPriorityDelayInMinutes
FROM dbo.LogShippingConfiguration AS LSC
WHERE LSC.IsActive = 1

OPEN MonitorLog_Cur

FETCH NEXT FROM MonitorLog_Cur INTO @DatabaseName, @Low, @Medium, @High

WHILE @@FETCH_STATUS = 0
BEGIN	
	
	set @Subject = 'Custom Log Shipping - Delay in log restores on '+@DatabaseName

	SELECT TOP 1 @DelayInMinutes = DATEDIFF(MINUTE, CAST(FORMAT(CAST(REPLACE(FileTimeStamp, '_', '') AS numeric(25, 0)), '######## ##:##:##') AS DATETIME), GETDATE())
	FROM dbo.LogShippingRestoreLog
	WHERE DatabaseName = @DatabaseName AND RestoreStatus = 0
	ORDER BY ID DESC
	
	SET @MessageID = NULL

	SELECT TOP 1 @MessageID = ID, @SeverityLevel = SeverityLevel FROM dbo.LogShippingMonitorLog WHERE MessageSubject = @subject AND DatabaseName = @DatabaseName AND IsResolved = 0

	IF @DelayInMinutes <= @Low
		BEGIN
			SET @Body = 'NONE: Custom Log Shipping - RESOLVED - Delay in log restores. Server: '+@@SERVERNAME+', Database: '+@DatabaseName+'. Current Delay In Minutes: '+CAST (@DelayInMinutes AS VARCHAR(10))
			IF @MessageID IS NOT NULL
			UPDATE dbo.LogShippingMonitorLog SET IsResolved = 1, MessageSent = 0, MessageBody = @Body WHERE ID = @MessageID
		END

	IF @DelayInMinutes > @Low AND @DelayInMinutes <= @Medium
		BEGIN
			IF @MessageID IS NULL
				BEGIN

				SET @SeverityLevel = 1
				SET @Body = 'LOW: Custom Log Shipping - ERROR RAISED - Delay in log restores. Server: '+@@SERVERNAME+', Database: '+@DatabaseName+'. Current Delay In Minutes: '+CAST (@DelayInMinutes AS VARCHAR(10))

				INSERT INTO dbo.LogShippingMonitorLog
				        ( CreateDate ,
				          DatabaseName ,
				          MessageSubject ,
				          MessageBody ,
				          SeverityLevel ,
				          IsResolved ,
				          MessageSent
				        )
				VALUES  ( GETDATE() ,
				          @DatabaseName ,
				          @Subject , 
						  @Body ,
				          @SeverityLevel , 
				          0 , 
						  0)
				END
			ELSE IF @MessageID IS NOT NULL AND @SeverityLevel != 1
				BEGIN
					SET @Body = 'LOW: Custom Log Shipping - SEVERITY CHANGED - Delay in log restores. Server: '+@@SERVERNAME+', Database: '+@DatabaseName+'. Current Delay In Minutes: '+CAST (@DelayInMinutes AS VARCHAR(10))
					UPDATE LogShippingMonitorLog SET SeverityLevel = 1, MessageSent = 0, MessageBody = @Body WHERE ID = @MessageID
				END
		END

	IF @DelayInMinutes > @Medium AND @DelayInMinutes <= @High
		BEGIN
			IF @MessageID IS NULL
				BEGIN

				SET @SeverityLevel = 2
				SET @Body = 'MEDIUM: Custom Log Shipping - ERROR RAISED - Delay in log restores. Server: '+@@SERVERNAME+', Database: '+@DatabaseName+'. Current Delay In Minutes: '+CAST (@DelayInMinutes AS VARCHAR(10))

				INSERT INTO dbo.LogShippingMonitorLog
				        ( CreateDate ,
				          DatabaseName ,
				          MessageSubject ,
				          MessageBody ,
				          SeverityLevel ,
				          IsResolved ,
				          MessageSent
				        )
				VALUES  ( GETDATE() ,
				          @DatabaseName ,
				          @Subject , 
						  @Body ,
				          @SeverityLevel , 
				          0 , 
						  0)
				END
			ELSE IF @MessageID IS NOT NULL AND @SeverityLevel != 2
				BEGIN
					SET @Body = 'MEDIUM: Custom Log Shipping - SEVERITY CHANGED - Delay in log restores. Server: '+@@SERVERNAME+', Database: '+@DatabaseName+'. Current Delay In Minutes: '+CAST (@DelayInMinutes AS VARCHAR(10))
					UPDATE LogShippingMonitorLog SET SeverityLevel = 2, MessageSent = 0, MessageBody = @Body WHERE ID = @MessageID
				END
		END
	
	IF @DelayInMinutes > @High
		BEGIN
			IF @MessageID IS NULL
				BEGIN

				SET @SeverityLevel = 3
				SET @Body = 'HIGH: Custom Log Shipping - ERROR RAISED - Delay in log restores. Server: '+@@SERVERNAME+', Database: '+@DatabaseName+'. Current Delay In Minutes: '+CAST (@DelayInMinutes AS VARCHAR(10))

				INSERT INTO dbo.LogShippingMonitorLog
				        ( CreateDate ,
				          DatabaseName ,
				          MessageSubject ,
				          MessageBody ,
				          SeverityLevel ,
				          IsResolved ,
				          MessageSent
				        )
				VALUES  ( GETDATE() ,
				          @DatabaseName ,
				          @Subject , 
						  @Body ,
				          @SeverityLevel , 
				          0 , 
						  0)
				END
			ELSE IF @MessageID IS NOT NULL AND @SeverityLevel != 3
				BEGIN
					SET @Body = 'HIGH: Custom Log Shipping - SEVERITY CHANGED - Delay in log restores. Server: '+@@SERVERNAME+', Database: '+@DatabaseName+'. Current Delay In Minutes: '+CAST (@DelayInMinutes AS VARCHAR(10))
					UPDATE LogShippingMonitorLog SET SeverityLevel = 3, MessageSent = 0, MessageBody = @Body WHERE ID = @MessageID
				END
		END


    FETCH NEXT FROM MonitorLog_Cur INTO @DatabaseName, @Low, @Medium, @High
END

CLOSE MonitorLog_Cur
DEALLOCATE MonitorLog_Cur

END
GO

/****** Object:  StoredProcedure [dbo].[CustomLogShipping_Notify]    Script Date: 04/11/2019 11:19:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CustomLogShipping_Notify]
AS
BEGIN

/* declare variables */
DECLARE @MessageID INT
DECLARE @DatabaseName NVARCHAR(255)
DECLARE @EmailList NVARCHAR(4000)
DECLARE @subject NVARCHAR(255)
DECLARE @body NVARCHAR(max)
DECLARE @severity INT
DECLARE @importance VARCHAR(6)

DECLARE Cursor_EmailNotification CURSOR FAST_FORWARD READ_ONLY FOR 
SELECT ID, MessageSubject, MessageBody, SeverityLevel, DatabaseName
FROM dbo.LogShippingMonitorLog
WHERE MessageSent = 0

OPEN Cursor_EmailNotification

FETCH NEXT FROM Cursor_EmailNotification INTO @MessageID, @subject, @body, @severity, @DatabaseName

WHILE @@FETCH_STATUS = 0
BEGIN
	
	SET @importance = CASE @severity WHEN 1 THEN 'Low' WHEN 2 THEN 'Normal' WHEN 3 THEN 'High' END

	SELECT @EmailList = LSC.EmailList
	FROM dbo.LogShippingConfiguration AS LSC
	WHERE LSC.DatabaseName = @DatabaseName

    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'RSSQL2@ratesetter.com', -- sysname
    @recipients = @EmailList, -- varchar(max)
    @subject = @subject, -- nvarchar(255)
    @body = @body, -- nvarchar(max)
	@importance = @importance

	UPDATE dbo.LogShippingMonitorLog SET MessageSent = 1 WHERE ID = @MessageID

    FETCH NEXT FROM Cursor_EmailNotification INTO @MessageID, @subject, @body, @severity, @DatabaseName
END

CLOSE Cursor_EmailNotification
DEALLOCATE Cursor_EmailNotification

END
 

GO

/****** Object:  StoredProcedure [dbo].[CustomLogShipping_RestartLogShipping]    Script Date: 04/11/2019 11:19:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CustomLogShipping_RestartLogShipping]
AS

BEGIN TRY

SET NOCOUNT ON

	DECLARE @FullBackupPath NVARCHAR(4000)
	DECLARE @DiffBackupPath NVARCHAR(4000)
	DECLARE @LogBackupPath NVARCHAR(4000)
	DECLARE @DatabaseName NVARCHAR(255)

	DECLARE @FileList TABLE (backupFile NVARCHAR(255)) 
	DECLARE @LatestBackupTimeStamp NVARCHAR(4000)
	DECLARE @LogFileNamePattern NVARCHAR(1000)
	DECLARE @ShellCmd NVARCHAR(4000)
	DECLARE @RestoreSQL NVARCHAR(MAX)
	DECLARE @HeaderOnlySQL NVARCHAR(MAX)
	DECLARE @FirstLSN NUMERIC(25, 0)
    DECLARE @LastLSN NUMERIC(25, 0)
	DECLARE @LastRestoredLSN NUMERIC(25, 0)
	DECLARE @Headeronly TABLE
    (
      BackupName NVARCHAR(128) , BackupDescription NVARCHAR(255) ,
      BackupType SMALLINT , ExpirationDate DATETIME ,
      Compressed BIT , Position SMALLINT ,
      DeviceType TINYINT , UserName NVARCHAR(128) ,
      ServerName NVARCHAR(128) , DatabaseName NVARCHAR(128) ,
      DatabaseVersion INT , DatabaseCreationDate DATETIME ,
      BackupSize NUMERIC(20, 0) , FirstLSN NUMERIC(25, 0) ,
      LastLSN NUMERIC(25, 0) , CheckpointLSN NUMERIC(25, 0) ,
      DatabaseBackupLSN NUMERIC(25, 0) , BackupStartDate DATETIME ,
      BackupFinishDate DATETIME , SortOrder SMALLINT ,
      CodePage SMALLINT , UnicodeLocaleId INT ,
      UnicodeComparisonStyle INT , CompatibilityLevel TINYINT ,
      SoftwareVendorId INT , SoftwareVersionMajor INT ,
      SoftwareVersionMinor INT , SoftwareVersionBuild INT ,
      MachineName NVARCHAR(128) , Flags INT ,
      BindingID UNIQUEIDENTIFIER , RecoveryForkID UNIQUEIDENTIFIER ,
      Collation NVARCHAR(128) , FamilyGUID UNIQUEIDENTIFIER ,
      HasBulkLoggedData BIT , IsSnapshot BIT ,
      IsReadOnly BIT , IsSingleUser BIT ,
      HasBackupChecksums BIT , IsDamaged BIT ,
      BeginsLogChain BIT , HasIncompleteMetaData BIT ,
      IsForceOffline BIT , IsCopyOnly BIT ,
      FirstRecoveryForkID UNIQUEIDENTIFIER , ForkPointLSN NUMERIC(25, 0) NULL ,
      RecoveryModel NVARCHAR(60) , DifferentialBaseLSN NUMERIC(25, 0) NULL ,
      DifferentialBaseGUID UNIQUEIDENTIFIER , BackupTypeDescription NVARCHAR(60) ,
      BackupSetGUID UNIQUEIDENTIFIER NULL , CompressedBackupSize NUMERIC(25, 0) NULL ,
      Containment NUMERIC(25, 0) NULL, KeyAlgorithm nvarchar(32) ,
      EncryptorThumbprint varbinary(20) , EncryptorType nvarchar(32)
    );

	UPDATE LogShippingConfiguration SET IsActive = 0 WHERE RestartShipping = 1
	
	DECLARE RestartLogShipping_Cur CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT LSC.DatabaseName, LSC.FullBackupPath, LSC.DiffBackupPath, LSC.LogBackupPath, LSC.LogFileNamePattern
	FROM dbo.LogShippingConfiguration AS LSC
	WHERE LSC.RestartShipping = 1 AND LSC.IsActive = 0

	OPEN RestartLogShipping_Cur
	
	FETCH NEXT FROM RestartLogShipping_Cur INTO @DatabaseName, @FullBackupPath, @DiffBackupPath, @LogBackupPath, @LogFileNamePattern
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT TOP 1 @LatestBackupTimeStamp = FileTimeStamp, @LastRestoredLSN = LastRestoredLSN
		FROM Tools.dbo.LogShippingRestoreLog
		WHERE RestoreStatus = 0 AND DatabaseName = @DatabaseName
		ORDER BY ID DESC

		SET @LatestBackupTimeStamp = ISNULL(@LatestBackupTimeStamp, '99999999_999999')

		DELETE FROM @FileList

		SET @ShellCmd = 'DIR /b '+@FullBackupPath

	    INSERT INTO @fileList (backupFile)
	    EXEC sys.xp_cmdshell @ShellCmd

		DECLARE @FileToRestore NVARCHAR(4000)
	    DECLARE @FileToRestore_FullPath NVARCHAR(MAX)

		SELECT TOP 1 @FileToRestore = backupFile
		FROM @fileList
		WHERE substring([backupFile]
			,patindex('%________[_]______.%',[backupFile])
			,charindex('.',[backupFile])-patindex('%________[_]______.%',[backupFile])) < @LatestBackupTimeStamp
		ORDER BY backupFile DESC

		IF @FileToRestore IS NOT NULL
		BEGIN
			SET @FileToRestore_FullPath = @FullBackupPath + @FileToRestore

			SET @HeaderOnlySQL =  'RESTORE HEADERONLY FROM DISK='''+@FileToRestore_FullPath+''''
				
			DELETE FROM @Headeronly

			INSERT INTO @Headeronly
			EXEC (@HeaderOnlySQL);

			SELECT TOP 1 @FirstLSN = H.FirstLSN, @LastLSN = H.LastLSN
			FROM @Headeronly AS H

			SET @RestoreSQL = 'RESTORE DATABASE '+@DatabaseName+' FROM DISK = '''+@FileToRestore_FullPath+''' WITH NORECOVERY, REPLACE, STATS=10'
			
			PRINT @RestoreSQL
			PRINT ''
			EXEC (@RestoreSQL)

			INSERT INTO Tools.dbo.LogShippingRestoreLog
					( CreateDate ,
						DatabaseName ,
						FileName ,
						RestoreStatus ,
						LastRestoredLSN
					)
			VALUES  ( GETDATE() , -- CreateDate - datetime
						@DatabaseName ,
						@FileToRestore , -- LogFileName - nvarchar(4000)
						0 , -- RestoreStatus - int
						@LastLSN
					)

					SELECT TOP 1 @LatestBackupTimeStamp = FileTimeStamp, @LastRestoredLSN = LastRestoredLSN
					FROM Tools.dbo.LogShippingRestoreLog
					WHERE RestoreStatus = 0 AND DatabaseName = @DatabaseName
					ORDER BY ID DESC

					DELETE FROM @FileList

					SET @ShellCmd = 'DIR /b '+@DiffBackupPath

					INSERT INTO @fileList (backupFile)
					EXEC sys.xp_cmdshell @ShellCmd

					SET @FileToRestore = NULL

					SELECT TOP 1 @FileToRestore = backupFile
					FROM @fileList
					WHERE substring([backupFile]
						,patindex('%________[_]______.%',[backupFile])
						,charindex('.',[backupFile])-patindex('%________[_]______.%',[backupFile])) > @LatestBackupTimeStamp
					ORDER BY backupFile DESC

					IF @FileToRestore IS NOT NULL
					BEGIN
						SET @FileToRestore_FullPath = @DiffBackupPath + @FileToRestore

						SET @HeaderOnlySQL =  'RESTORE HEADERONLY FROM DISK='''+@FileToRestore_FullPath+''''
				
						DELETE FROM @Headeronly

						INSERT INTO @Headeronly
						EXEC (@HeaderOnlySQL);

						SELECT TOP 1 @FirstLSN = H.FirstLSN, @LastLSN = H.LastLSN
						FROM @Headeronly AS H

						SET @RestoreSQL = 'RESTORE DATABASE '+@DatabaseName+' FROM DISK = '''+@FileToRestore_FullPath+''' WITH NORECOVERY, STATS=10'
			
						PRINT @RestoreSQL
						PRINT ''
						EXEC (@RestoreSQL)

						INSERT INTO Tools.dbo.LogShippingRestoreLog
								( CreateDate ,
									DatabaseName ,
									FileName ,
									RestoreStatus ,
									LastRestoredLSN
								)
						VALUES  ( GETDATE() , -- CreateDate - datetime
									@DatabaseName ,
									@FileToRestore , -- LogFileName - nvarchar(4000)
									0 , -- RestoreStatus - int
									@LastLSN
								)
					END


					SELECT TOP 1 @LatestBackupTimeStamp = FileTimeStamp, @LastRestoredLSN = LastRestoredLSN
					FROM Tools.dbo.LogShippingRestoreLog
					WHERE RestoreStatus = 0 AND DatabaseName = @DatabaseName
					ORDER BY ID DESC

					SET @ShellCmd = 'DIR /b '+@LogBackupPath

					DELETE FROM @FileList

					INSERT INTO @fileList (backupFile)
					EXEC sys.xp_cmdshell @ShellCmd

					SET @FileToRestore = NULL

					DECLARE RestoreLogReinit_Cur CURSOR FAST_FORWARD READ_ONLY FOR 	
					SELECT backupFile
					FROM @fileList
					WHERE substring([backupFile]
						,patindex('%________[_]______.%',[backupFile])
						,charindex('.',[backupFile])-patindex('%________[_]______.%',[backupFile])) > @LatestBackupTimeStamp
					AND backupFile LIKE @LogFileNamePattern
					ORDER BY backupFile

					OPEN RestoreLogReinit_Cur

					FETCH NEXT FROM RestoreLogReinit_Cur INTO @FileToRestore
	
					WHILE @@FETCH_STATUS = 0
						BEGIN

							SET @FileToRestore_FullPath = @LogBackupPath + @FileToRestore

							SET @HeaderOnlySQL =  'RESTORE HEADERONLY FROM DISK='''+@FileToRestore_FullPath+''''
				
							DELETE FROM @Headeronly

							INSERT INTO @Headeronly
							EXEC (@HeaderOnlySQL);

							SELECT TOP 1 @FirstLSN = H.FirstLSN, @LastLSN = H.LastLSN
							FROM @Headeronly AS H

							IF ISNULL(@LastRestoredLSN, @FirstLSN) >= @FirstLSN AND ISNULL(@LastRestoredLSN, 0) < @LastLSN
							BEGIN
								SET @RestoreSQL = 'RESTORE LOG '+@DatabaseName+' FROM DISK = '''+@FileToRestore_FullPath+''' WITH NORECOVERY'

								PRINT '.... Restoring '+ @FileToRestore

								PRINT @RestoreSQL
								PRINT ''
								EXEC (@RestoreSQL)

								INSERT INTO Tools.dbo.LogShippingRestoreLog
										( CreateDate ,
										  DatabaseName ,
										  FileName ,
										  RestoreStatus ,
										  LastRestoredLSN
										)
								VALUES  ( GETDATE() , -- CreateDate - datetime
										  @DatabaseName ,
										  @FileToRestore , -- LogFileName - nvarchar(4000)
										  0 , -- RestoreStatus - int
										  @LastLSN
										)

								--EXEC master.sys.xp_delete_file 0, @FileToRestore_FullPath
								SET @FileToRestore = NULL
								SET @LastRestoredLSN = @LastLSN
							END
							ELSE IF @LastRestoredLSN > @FirstLSN
								INSERT INTO Tools.dbo.LogShippingRestoreLog
										( CreateDate ,
										  DatabaseName ,
										  FileName ,
										  RestoreStatus ,
										  LastRestoredLSN
										)
								VALUES  ( GETDATE() , -- CreateDate - datetime
										  @DatabaseName ,
										  @FileToRestore , -- LogFileName - nvarchar(4000)
										  50000 , -- RestoreStatus - int
										  @LastLSN
										)

							FETCH NEXT FROM RestoreLogReinit_Cur INTO @FileToRestore
						END

						IF (SELECT CURSOR_STATUS('global','RestoreLogReinit_Cur')) >= -1
						 BEGIN
						  IF (SELECT CURSOR_STATUS('global','RestoreLogReinit_Cur')) > -1
						   BEGIN
							CLOSE RestoreLogReinit_Cur
						   END
						 DEALLOCATE RestoreLogReinit_Cur
						END

		END

		UPDATE LogShippingConfiguration SET IsActive = 1, RestartShipping = 0 WHERE DatabaseName = @DatabaseName

	    FETCH NEXT FROM RestartLogShipping_Cur INTO @DatabaseName, @FullBackupPath, @DiffBackupPath, @LogBackupPath, @LogFileNamePattern
	END

	IF (SELECT CURSOR_STATUS('global','RestartLogShipping_Cur')) >= -1
	 BEGIN
	  IF (SELECT CURSOR_STATUS('global','RestartLogShipping_Cur')) > -1
	   BEGIN
		CLOSE RestartLogShipping_Cur
	   END
	 DEALLOCATE RestartLogShipping_Cur
	END
END TRY
BEGIN CATCH

	DECLARE @ErrorNumber INT

	SET @ErrorNumber = ERROR_NUMBER()

	IF @FileToRestore IS NOT NULL
		INSERT INTO Tools.dbo.LogShippingRestoreLog
		        ( CreateDate ,
		          DatabaseName ,
		          FileName ,
		          RestoreStatus ,
				  LastRestoredLSN
		        )
		VALUES  ( GETDATE() , -- CreateDate - datetime
		          @DatabaseName ,
		          @FileToRestore , -- LogFileName - nvarchar(4000)
		          @ErrorNumber , -- RestoreStatus - int
				  @LastLSN
		        )

	IF (SELECT CURSOR_STATUS('global','RestoreLogReinit_Cur')) >= -1
		BEGIN
		IF (SELECT CURSOR_STATUS('global','RestoreLogReinit_Cur')) > -1
		BEGIN
		CLOSE RestoreLogReinit_Cur
		END
		DEALLOCATE RestoreLogReinit_Cur
	END

	IF (SELECT CURSOR_STATUS('global','RestartLogShipping_Cur')) >= -1
	 BEGIN
	  IF (SELECT CURSOR_STATUS('global','RestartLogShipping_Cur')) > -1
	   BEGIN
		CLOSE RestartLogShipping_Cur
	   END
	 DEALLOCATE RestartLogShipping_Cur
	END
END CATCH
GO

/****** Object:  StoredProcedure [dbo].[CustomLogShipping_RestoreLogs]    Script Date: 04/11/2019 11:19:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CustomLogShipping_RestoreLogs]
AS

SET NOCOUNT ON

BEGIN TRY

	DECLARE @BackupPath NVARCHAR(4000)
	DECLARE @DatabaseName NVARCHAR(255)

	DECLARE @FileList TABLE (backupFile NVARCHAR(255)) 
	DECLARE @LatestBackupTimeStamp NVARCHAR(4000)
	DECLARE @LogFileNamePattern NVARCHAR(1000)
	DECLARE @ShellCmd NVARCHAR(4000)
	DECLARE @RestoreSQL NVARCHAR(MAX)
	DECLARE @HeaderOnlySQL NVARCHAR(MAX)
	DECLARE @FirstLSN NUMERIC(25, 0)
    DECLARE @LastLSN NUMERIC(25, 0)
	DECLARE @LastRestoredLSN NUMERIC(25, 0)
	DECLARE @Headeronly TABLE
    (
      BackupName NVARCHAR(128) , BackupDescription NVARCHAR(255) ,
      BackupType SMALLINT , ExpirationDate DATETIME ,
      Compressed BIT , Position SMALLINT ,
      DeviceType TINYINT , UserName NVARCHAR(128) ,
      ServerName NVARCHAR(128) , DatabaseName NVARCHAR(128) ,
      DatabaseVersion INT , DatabaseCreationDate DATETIME ,
      BackupSize NUMERIC(20, 0) , FirstLSN NUMERIC(25, 0) ,
      LastLSN NUMERIC(25, 0) , CheckpointLSN NUMERIC(25, 0) ,
      DatabaseBackupLSN NUMERIC(25, 0) , BackupStartDate DATETIME ,
      BackupFinishDate DATETIME , SortOrder SMALLINT ,
      CodePage SMALLINT , UnicodeLocaleId INT ,
      UnicodeComparisonStyle INT , CompatibilityLevel TINYINT ,
      SoftwareVendorId INT , SoftwareVersionMajor INT ,
      SoftwareVersionMinor INT , SoftwareVersionBuild INT ,
      MachineName NVARCHAR(128) , Flags INT ,
      BindingID UNIQUEIDENTIFIER , RecoveryForkID UNIQUEIDENTIFIER ,
      Collation NVARCHAR(128) , FamilyGUID UNIQUEIDENTIFIER ,
      HasBulkLoggedData BIT , IsSnapshot BIT ,
      IsReadOnly BIT , IsSingleUser BIT ,
      HasBackupChecksums BIT , IsDamaged BIT ,
      BeginsLogChain BIT , HasIncompleteMetaData BIT ,
      IsForceOffline BIT , IsCopyOnly BIT ,
      FirstRecoveryForkID UNIQUEIDENTIFIER , ForkPointLSN NUMERIC(25, 0) NULL ,
      RecoveryModel NVARCHAR(60) , DifferentialBaseLSN NUMERIC(25, 0) NULL ,
      DifferentialBaseGUID UNIQUEIDENTIFIER , BackupTypeDescription NVARCHAR(60) ,
      BackupSetGUID UNIQUEIDENTIFIER NULL , CompressedBackupSize NUMERIC(25, 0) NULL ,
      Containment NUMERIC(25, 0) NULL, KeyAlgorithm nvarchar(32) ,
      EncryptorThumbprint varbinary(20) , EncryptorType nvarchar(32)
    );
	
	DECLARE RestoreLogConfig_Cur CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT LSC.DatabaseName, LSC.LogBackupPath, LSC.LogFileNamePattern
	FROM dbo.LogShippingConfiguration AS LSC
	WHERE LSC.IsActive = 1
	
	OPEN RestoreLogConfig_Cur
	
	FETCH NEXT FROM RestoreLogConfig_Cur INTO @DatabaseName, @BackupPath, @LogFileNamePattern
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT TOP 1 @LatestBackupTimeStamp = FileTimeStamp, @LastRestoredLSN = LastRestoredLSN
		FROM Tools.dbo.LogShippingRestoreLog
		WHERE RestoreStatus = 0 AND DatabaseName = @DatabaseName
		ORDER BY ID DESC

		SET @ShellCmd = 'DIR /b '+@BackupPath

		DELETE FROM @FileList

	    INSERT INTO @fileList (backupFile)
	    EXEC sys.xp_cmdshell @ShellCmd

		DECLARE @FileToRestore NVARCHAR(4000)
	    DECLARE @FileToRestore_FullPath NVARCHAR(MAX)

		DECLARE RestoreLog_Cur CURSOR FAST_FORWARD READ_ONLY FOR 	
		SELECT backupFile
		FROM @fileList
		WHERE substring([backupFile]
			,patindex('%________[_]______.%',[backupFile])
			,charindex('.',[backupFile])-patindex('%________[_]______.%',[backupFile])) > @LatestBackupTimeStamp
		AND backupFile LIKE @LogFileNamePattern
		ORDER BY backupFile

		OPEN RestoreLog_Cur

		FETCH NEXT FROM RestoreLog_Cur INTO @FileToRestore
	
		WHILE @@FETCH_STATUS = 0
			BEGIN

				SET @FileToRestore_FullPath = @BackupPath + @FileToRestore

				SET @HeaderOnlySQL =  'RESTORE HEADERONLY FROM DISK='''+@FileToRestore_FullPath+''''
				
				DELETE FROM @Headeronly

				INSERT INTO @Headeronly
				EXEC (@HeaderOnlySQL);

				SELECT TOP 1 @FirstLSN = H.FirstLSN, @LastLSN = H.LastLSN
				FROM @Headeronly AS H

				IF ISNULL(@LastRestoredLSN, @FirstLSN) >= @FirstLSN AND ISNULL(@LastRestoredLSN, 0) < @LastLSN
				BEGIN
					SET @RestoreSQL = 'RESTORE LOG '+@DatabaseName+' FROM DISK = '''+@FileToRestore_FullPath+''' WITH NORECOVERY'

					PRINT '.... Restoring '+ @FileToRestore

					PRINT @RestoreSQL
					PRINT ''
					EXEC (@RestoreSQL)

					INSERT INTO Tools.dbo.LogShippingRestoreLog
							( CreateDate ,
							  DatabaseName ,
							  FileName ,
							  RestoreStatus ,
							  LastRestoredLSN
							)
					VALUES  ( GETDATE() , -- CreateDate - datetime
							  @DatabaseName ,
							  @FileToRestore , -- LogFileName - nvarchar(4000)
							  0 , -- RestoreStatus - int
							  @LastLSN
							)

					--EXEC master.sys.xp_delete_file 0, @FileToRestore_FullPath
					SET @FileToRestore = NULL
					SET @LastRestoredLSN = @LastLSN
				END
				ELSE IF @LastRestoredLSN > @FirstLSN
					INSERT INTO Tools.dbo.LogShippingRestoreLog
							( CreateDate ,
							  DatabaseName ,
							  FileName ,
							  RestoreStatus ,
							  LastRestoredLSN
							)
					VALUES  ( GETDATE() , -- CreateDate - datetime
							  @DatabaseName ,
							  @FileToRestore , -- LogFileName - nvarchar(4000)
							  50000 , -- RestoreStatus - int
							  @LastLSN
							)

				FETCH NEXT FROM RestoreLog_Cur INTO @FileToRestore
			END

			IF (SELECT CURSOR_STATUS('global','RestoreLog_Cur')) >= -1
			 BEGIN
			  IF (SELECT CURSOR_STATUS('global','RestoreLog_Cur')) > -1
			   BEGIN
				CLOSE RestoreLog_Cur
			   END
			 DEALLOCATE RestoreLog_Cur
			END



	    FETCH NEXT FROM RestoreLogConfig_Cur INTO @DatabaseName, @BackupPath, @LogFileNamePattern
	END

	IF (SELECT CURSOR_STATUS('global','RestoreLogConfig_Cur')) >= -1
	 BEGIN
	  IF (SELECT CURSOR_STATUS('global','RestoreLogConfig_Cur')) > -1
	   BEGIN
		CLOSE RestoreLogConfig_Cur
	   END
	 DEALLOCATE RestoreLogConfig_Cur
	END

END TRY
BEGIN CATCH

	DECLARE @ErrorNumber INT

	SET @ErrorNumber = ERROR_NUMBER()

	IF @FileToRestore IS NOT NULL
		INSERT INTO Tools.dbo.LogShippingRestoreLog
		        ( CreateDate ,
		          DatabaseName ,
		          FileName ,
		          RestoreStatus ,
				  LastRestoredLSN
		        )
		VALUES  ( GETDATE() , -- CreateDate - datetime
		          @DatabaseName ,
		          @FileToRestore , -- LogFileName - nvarchar(4000)
		          @ErrorNumber , -- RestoreStatus - int
				  @LastLSN
		        )

	IF (SELECT CURSOR_STATUS('global','RestoreLog_Cur')) >= -1
	 BEGIN
	  IF (SELECT CURSOR_STATUS('global','RestoreLog_Cur')) > -1
	   BEGIN
		CLOSE RestoreLog_Cur
	   END
	 DEALLOCATE RestoreLog_Cur
	END

	IF (SELECT CURSOR_STATUS('global','RestoreLogConfig_Cur')) >= -1
	 BEGIN
	  IF (SELECT CURSOR_STATUS('global','RestoreLogConfig_Cur')) > -1
	   BEGIN
		CLOSE RestoreLogConfig_Cur
	   END
	 DEALLOCATE RestoreLogConfig_Cur
	END
END CATCH
GO

/****** Object:  StoredProcedure [dbo].[CustomLogShipping_RstoreWithRecovery]    Script Date: 04/11/2019 11:19:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CustomLogShipping_RstoreWithRecovery]
AS

SET NOCOUNT ON

	DECLARE @DatabaseName NVARCHAR(255)
	DECLARE @SQL NVARCHAR(4000)
	
	DECLARE SwitchToRecovery_Cur CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT LSC.DatabaseName
	FROM dbo.LogShippingConfiguration AS LSC
	WHERE LSC.IsActive = 1 AND LSC.RstoreWithRecovery = 1
	
	OPEN SwitchToRecovery_Cur
	
	FETCH NEXT FROM SwitchToRecovery_Cur INTO @DatabaseName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @SQL = 'RESTORE DATABASE ['+@DatabaseName+'] WITH RECOVERY'
		EXEC(@SQL)
	    
		UPDATE dbo.LogShippingConfiguration SET IsActive = 0, RstoreWithRecovery = 0 WHERE DatabaseName = @DatabaseName
		
	    FETCH NEXT FROM SwitchToRecovery_Cur INTO @DatabaseName
	END
	
	IF (SELECT CURSOR_STATUS('global','SwitchToRecovery_Cur')) >= -1
	 BEGIN
	  IF (SELECT CURSOR_STATUS('global','SwitchToRecovery_Cur')) > -1
	   BEGIN
		CLOSE SwitchToRecovery_Cur
	   END
	 DEALLOCATE SwitchToRecovery_Cur
	END
----===============================================================================================================================================================================
GO


