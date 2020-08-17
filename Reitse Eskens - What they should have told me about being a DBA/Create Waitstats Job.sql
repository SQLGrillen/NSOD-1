USE [msdb]
GO

/****** Object:  Job [AX_GetWaitStatistics]    Script Date: 13-8-2020 13:50:02 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13-8-2020 13:50:02 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AX_GetWaitStatistics', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'SA', 
		@notify_email_operator_name=N'', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CatchEmAll]    Script Date: 13-8-2020 13:50:02 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CatchEmAll', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=3, 
		@retry_interval=5, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS
    ( 
        SELECT * 
        FROM TEMPDB.dbo.sysobjects
        WHERE ID = OBJECT_ID(N''tempdb..#ws_Capture'')
    )
DROP TABLE #ws_Capture;

CREATE TABLE #ws_Capture
(
    wst_WaitType        VARCHAR(50),
    wst_WaitTime        BIGINT,
    wst_WaitingTasks    BIGINT,
    wst_SignalWaitTime  BIGINT
)

INSERT INTO #ws_Capture
    SELECT
        wait_type, 
        wait_time_ms,
        waiting_tasks_count,
        signal_wait_time_ms
    FROM sys.dm_os_wait_stats

WAITFOR DELAY ''00:04:30''

INSERT INTO WaitStats
    SELECT
        GETDATE() AS [DATETIME],
        DATEPART(DAY,GETDATE()) AS [DAY],
        DATEPART(MONTH, GETDATE()) AS [MONTH],
        DATEPART(YEAR, GETDATE()) AS [YEAR],
        DATEPART(HOUR, GETDATE()) AS [HOUR],
        DATEPART(MINUTE, GETDATE()) AS [MINUTE],
        DATENAME(DW, GETDATE()) AS DAYOFWEEK,
        dm.wait_type AS WaitType,
        dm.wait_time_ms - ws.wst_WaitTime AS WaitTime,
        dm.waiting_tasks_count - ws.wst_WaitingTasks AS WaitingTasks,
        dm.signal_wait_time_ms - ws.wst_SignalWaitTime AS SignalWaitTime
    FROM sys.dm_os_wait_stats dm
        INNER JOIN #ws_Capture ws ON dm.wait_type = ws.wst_WaitType;

DROP TABLE #ws_Capture;', 
		@database_name=N'DBAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5 min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181003, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'2d69dc5f-a1ba-4ab4-8f51-922eba923a53'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


