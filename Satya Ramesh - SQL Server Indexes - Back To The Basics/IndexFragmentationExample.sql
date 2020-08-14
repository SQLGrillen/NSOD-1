
SET NOCOUNT ON;
USE tempdb;
GO

-- Create table T1
--  This table has two columns. one has NEWID() function which will be used to insert some random values into column1
--  Second column is a filler column to fill up the 8k page faster
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;

CREATE TABLE dbo.T1
(
  col1 UNIQUEIDENTIFIER NOT NULL DEFAULT(NEWID()),
  bloat CHAR(2000) NOT NULL DEFAULT('a')
);
GO
CREATE UNIQUE CLUSTERED INDEX idx_cl_col ON dbo.T1(col1);
GO


-- Endless loop. Run for 2 sec and stop. Be careful with this otherwise your machine will crash
SET NOCOUNT ON;
USE tempdb;
WHILE 1 = 1
  INSERT INTO dbo.T1 DEFAULT VALUES;
GO


-- Check the fragmentation percentage using the DMF. For more details Refer sys.dm_db_index_physical_stats
SELECT avg_fragmentation_in_percent FROM sys.dm_db_index_physical_stats
( 
  DB_ID('tempdb'),
  OBJECT_ID('dbo.T1'),
  1,
  NULL,
  NULL
);


-- Reorganize the index (if percentage is >5 and <30)
ALTER INDEX idx_cl_col ON dbo.T1 REORGANIZE

-- Rebuild the index (if percentage is >30)
ALTER INDEX idx_cl_col ON dbo.T1 REBUILD

-- Create index using fill factor
CREATE UNIQUE CLUSTERED INDEX idx_cl_col ON dbo.T1(col1)
WITH (FILLFACTOR=50, PAD_INDEX=ON);
GO --DROP INDEX idx_cl_col ON dbo.T1

-- Drop index 
DROP INDEX idx_cl_col ON dbo.T1

-- Drop the table
DROP TABLE dbo.T1