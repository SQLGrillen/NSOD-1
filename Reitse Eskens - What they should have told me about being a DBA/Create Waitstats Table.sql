USE [DBAdmin]
GO

/****** Object:  Table [dbo].[WaitStats]    Script Date: 13-8-2020 13:48:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WaitStats](
	[ws_ID] [int] IDENTITY(1,1) NOT NULL,
	[ws_DateTime] [datetime] NULL,
	[ws_DAY] [int] NULL,
	[ws_MONTH] [int] NULL,
	[ws_YEAR] [int] NULL,
	[ws_HOUR] [int] NULL,
	[ws_MINUTE] [int] NULL,
	[ws_DAYOFWEEK] [varchar](15) NULL,
	[ws_WaitType] [varchar](50) NULL,
	[ws_WaitTime] [int] NULL,
	[ws_WaitingTasks] [int] NULL,
	[ws_SignalWaitTime] [int] NULL,
	[ws_time_per_wait]  AS ([ws_WaitTime]/case when [ws_WaitingTasks]=(0) then (1) else [ws_WaitingTasks] end),
PRIMARY KEY CLUSTERED 
(
	[ws_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


