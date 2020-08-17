-- let's create the database

CREATE DATABASE DBADMIN;
GO













USE DBADMIN;
GO

-- now create the table we need
USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OHManagement](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DATABASENAME] [varchar](100) NOT NULL,
	[DAILYINDEX] [bit] NULL,
	[WEEKINDEX] [bit] NULL,
	[DAILYFULLBACKUP] [bit] NULL,
	[WEEKFULLBACKUP] [bit] NULL,
	[DAILYINCREMENTAL] [bit] NULL,
	[LOGBACKUP] [bit] NULL,
	[STATISTICSDAILY] [bit] NULL,
	[STATISTICSWEEKLY] [bit] NULL,
	[SERVERNAME]  AS (@@servername),
	[INTEGRITYDAILY] [bit] NULL,
	[INTEGRITYWEEKLY] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [DAILYINDEX]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [WEEKINDEX]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [DAILYFULLBACKUP]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [WEEKFULLBACKUP]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [DAILYINCREMENTAL]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [LOGBACKUP]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [STATISTICSDAILY]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [STATISTICSWEEKLY]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [INTEGRITYDAILY]
GO

ALTER TABLE [dbo].[OHManagement] ADD  DEFAULT ((0)) FOR [INTEGRITYWEEKLY]
GO



























-- We'll look at the script in a moment
-- First, let's create the job to update the table

USE [msdb]
GO

/****** Object:  Job [AX_UpdateOHManagement]    Script Date: 5-8-2020 21:32:27 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 5-8-2020 21:32:27 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AX_UpdateOHManagement', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [AddNewDatabase]    Script Date: 5-8-2020 21:32:27 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'AddNewDatabase', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'MERGE OHMANAGEMENT T USING
(select name 
from sys.databases) S
on T.databasename = S.Name
WHEN NOT MATCHED BY TARGET
THEN INSERT (Databasename, dailyindex, weekindex, dailyfullbackup, weekfullbackup, dailyincremental, logbackup, statisticsdaily, statisticsweekly, integritydaily, integrityweekly)
values (name, 0,1,1,1,0,1,0,0,1,0)
WHEN NOT MATCHED BY SOURCE THEN DELETE;', 
		@database_name=N'DBAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CheckFullRecoveryModel]    Script Date: 5-8-2020 21:32:27 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CheckFullRecoveryModel', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'update OHMANAGEMENT
SET LOGBACKUP = 0;
GO
update OHMANAGEMENT
SET LOGBACKUP = 1
WHERE DATABASENAME in (select name 
from sys.databases
where recovery_model_desc != ''SIMPLE''
and name not in (''master'', ''model'', ''tempdb'' ))', 
		@database_name=N'DBAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'UpdateOla', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20191107, 
		@active_end_date=99991231, 
		@active_start_time=180000, 
		@active_end_time=235959, 
		@schedule_uid=N'cc7083e4-6342-476e-ab94-182e55c03c13'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO











-- Now that we've seen the job it creates, let's create a job that uses this table.


USE [msdb]
GO

/****** Object:  Job [AX_OH_DAILY_FULL_BACKUP]    Script Date: 5-8-2020 21:42:50 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 5-8-2020 21:42:50 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AX_OH_DAILY_FULL_BACKUP', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step1]    Script Date: 5-8-2020 21:42:50 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE DBAdmin

DECLARE @DatabaseList varchar(max);

SET @DatabaseList = (

SELECT 
       Name = STUFF( (SELECT DISTINCT '',''+DATABASENAME 
                      FROM dbo.OHManagement
					  where DAILYFULLBACKUP = 1
                      FOR XML PATH('''')
                     ), 1, 1, ''''
                   ) )
 IF(@DatabaseList is null)
 print ''No database has been selected.''
 else
EXECUTE [master].[dbo].[DatabaseBackup]
@Databases = @DatabaseList,
@Directory = N''\\yourbackupdir'',
@BackupType = ''FULL'',
@Verify = ''Y'',
@CleanupTime = 480,
@CheckSum = ''Y'',
@LogToTable = ''Y'',
@CleanupMode = ''AFTER_BACKUP'',
@NumberOfFiles = 4,
@Compress = ''Y''', 
		@database_name=N'DBAdmin', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily Full Backup', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20191028, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
		@active_end_time=235959, 
		@schedule_uid=N'42656cb2-d40f-4e41-94fd-ead601541d94'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



-- Cool, job has been created. Now execute the job to fill the table.



-- That should have worked. Now, what's in the table?


Select * -- don't ever use select *, really! ;)
from OHManagement
