USE Tools
GO

/****** Object:  StoredProcedure [dbo].[AutoRestore_RestoreLatestBackup]    Script Date: 17/07/2019 09:42:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[AutoRestore_RestoreLatestBackup]
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


