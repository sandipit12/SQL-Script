USE [Tools]
GO
SET ANSI_PADDING ON

DROP TABLE IF EXISTS LogShippingConfiguration
BEGIN
CREATE TABLE [dbo].[LogShippingConfiguration](
	[DatabaseName] [nvarchar](255) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[LogBackupPath] [nvarchar](4000) NOT NULL,
	[FullBackupPath] [nvarchar](4000) NULL,
	[DiffBackupPath] [nvarchar](4000) NULL,
	[LowPriorityDelayInMinutes] [int] NOT NULL,
	[MediumPriorityDelayInMinutes] [int] NOT NULL,
	[HighPriorityDelayInMinutes] [int] NOT NULL,
	[EmailList] [nvarchar](4000) NULL,
	[RstoreWithRecovery] [bit] NOT NULL,
	[RestartShipping] [bit] NOT NULL,
	[LogFileNamePattern] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_LogShippingConfiguration] PRIMARY KEY CLUSTERED 
(
	[DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

END



----=====================================================================================================================================================================================================================

DROP TABLE IF EXISTS [LogShippingMonitorLog]
BEGIN
CREATE TABLE [dbo].[LogShippingMonitorLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CreateDate] [datetime] NULL,
	[DatabaseName] [nvarchar](255) NULL,
	[MessageSubject] [nvarchar](255) NULL,
	[MessageBody] [nvarchar](4000) NULL,
	[SeverityLevel] [int] NULL,
	[IsResolved] [bit] NULL,
	[MessageSent] [bit] NULL,
 CONSTRAINT [PK_LogShippingMonitorLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


END


DROP TABLE IF EXISTS [LogShippingRestoreLog]
BEGIN
CREATE TABLE [dbo].[LogShippingRestoreLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CreateDate] [datetime] NULL,
	[DatabaseName] [nvarchar](255) NULL,
	[FileName] [nvarchar](4000) NULL,
	[FileTimeStamp]  AS (substring([FileName],patindex('%________[_]______.%',[FileName]),charindex('.',[FileName])-patindex('%________[_]______.%',[FileName]))),
	[RestoreStatus] [int] NULL,
	[LastRestoredLSN] [numeric](25, 0) NULL,
 CONSTRAINT [PK_LogShippingRestoreLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

END


GO
IF OBJECT_ID ( 'dbo.CustomLogShipping_Check') IS NOT NULL
BEGIN
DROP PROCEDURE dbo.CustomLogShipping_Check
END
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




IF OBJECT_ID( 'dbo.CustomLogShipping_CleanUp') IS NOT null
BEGIN 
DROP PROC dbo.CustomLogShipping_CleanUp
END
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
----============================================================================================================

IF OBJECT_ID('dbo.CustomLogShipping_Monitor') IS NOT NULL
BEGIN
DROP PROC dbo.CustomLogShipping_Monitor
END
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
go

----======================================================================================================================================================================


IF OBJECT_ID ('dbo.CustomLogShipping_Notify') IS NOT null
BEGIN 
DROP PROC dbo.[CustomLogShipping_Notify]
END 
Go
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

----=============================================================================================================================================================


IF OBJECT_ID('dbo.CustomLogShipping_RestartLogShipping') IS NOT NULL
BEGIN
DROP PROC dbo.CustomLogShipping_RestartLogShipping
END 
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
Go
----===============================================================================================================================================================================


IF OBJECT_ID ('dbo.CustomLogShipping_RestoreLogs') IS NOT null
BEGIN 
DROP PROC dbo.CustomLogShipping_RestoreLogs
END 
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
Go
----===============================================================================================================================================================================


IF OBJECT_ID( 'dbo.CustomLogShipping_RstoreWithRecovery') IS NOT NULL
BEGIN
DROP PROC dbo.CustomLogShipping_RstoreWithRecovery
END 
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
