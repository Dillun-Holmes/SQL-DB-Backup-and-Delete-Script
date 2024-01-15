-- created by Dillun Holmes
-- On SSMS, go to SQL Server Agent and create a job to run on the frequency
-- that is needed; it will always delete the latest one.

BEGIN
    DECLARE @BackupPath NVARCHAR(255)
    DECLARE @BackupFileName NVARCHAR(255)
    DECLARE @DateSuffix NVARCHAR(10)
    DECLARE @PreviousDateSuffix NVARCHAR(10)
    DECLARE @PreviousBackupFileName NVARCHAR(255)
    DECLARE @SqlCmd NVARCHAR(1000)

    -- Set the backup path
    SET @BackupPath = 'D:\sql\'

    -- Generate date suffix in the format YYYYMMDD for the current date
    SET @DateSuffix = CONVERT(NVARCHAR, GETDATE(), 112)

    -- Generate date suffix in the format YYYYMMDD for the previous date
    SET @PreviousDateSuffix = CONVERT(NVARCHAR, DATEADD(DAY, -1, GETDATE()), 112)

    -- Construct the backup file name with the date suffix for the current date
    SET @BackupFileName = @BackupPath + 'AnimalDatabase_' + @DateSuffix + '_backup.bak'

    -- Construct the file name for the previous day's backup
    SET @PreviousBackupFileName = @BackupPath + 'AnimalDatabase_' + @PreviousDateSuffix + '_backup.bak'

    -- Delete the backup file for the previous day if it exists
    IF EXISTS (SELECT 1 FROM sys.master_files WHERE physical_name = @PreviousBackupFileName)
    BEGIN
        SET @SqlCmd = 'DEL ' + QUOTENAME(@PreviousBackupFileName, '''')
        EXEC xp_cmdshell @SqlCmd
    END

    -- Perform the backup with the generated file name for the current date
    BACKUP DATABASE [AnimalDatabase] TO DISK = @BackupFileName WITH INIT;
END
