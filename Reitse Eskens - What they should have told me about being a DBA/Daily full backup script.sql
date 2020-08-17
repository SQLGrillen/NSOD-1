USE DBAdmin

DECLARE @DatabaseList varchar(max);

SET @DatabaseList = (

SELECT 
       Name = STUFF( (SELECT DISTINCT ','+DATABASENAME 
                      FROM dbo.OHManagement
					  where DAILYFULLBACKUP = 1
                      FOR XML PATH('')
                     ), 1, 1, ''
                   ) )
 IF(@DatabaseList is null)
 print 'No database has been selected.'
 else
EXECUTE [master].[dbo].[DatabaseBackup]
@Databases = @DatabaseList,
@Directory = N'\\yourbackupdir',
@BackupType = 'FULL',
@Verify = 'Y',
@CleanupTime = 480,
@CheckSum = 'Y',
@LogToTable = 'Y',
@CleanupMode = 'AFTER_BACKUP',
@NumberOfFiles = 4,
@Compress = 'Y'