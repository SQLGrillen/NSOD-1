-- Create sample database
USE master;
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name='SQLMaestros_Prod')
BEGIN
ALTER DATABASE SQLMaestros_Prod 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE SQLMaestros_Prod 
END

CREATE DATABASE SQLMaestros_Prod
GO

USE SQLMaestros_Prod;
SET NOCOUNT ON;
GO

-- Create a schema named SQLMaestros_Prod
CREATE SCHEMA [SQLMaestros_Prod] AUTHORIZATION [dbo];
GO

-- Create HOLs table in SQLMaestros_Prod database
CREATE Table [SQLMaestros_Prod].[HOLs](
   Column1 INT,
   Column2 VARCHAR(8000),
   Column3 CHAR(10),
   Column4 INT);
GO 


-- Insert 10000 records into HOLs table
DECLARE @COUNT INT;
SET @COUNT = 1;
DECLARE @DATA1 VARCHAR(7000)
SET @DATA1 = REPLICATE('bigdata',1000)
WHILE @COUNT < 10001
BEGIN
	DECLARE @DATA2 INT;
	SET @DATA2 = ROUND(10000000*RAND(),0);
	INSERT INTO [SQLMaestros_Prod].[HOLs] VALUES(@COUNT,@DATA1,'AAAAA',@DATA2);
	SET @COUNT = @COUNT + 1;
END
GO 
--SELECT * FROM SQLMaestros_Prod.HOLs
---------------------
-- End: Setup
---------------------

-- Run the following command to clear off all the plans in cache and drop buffers
DBCC FREEPROCCACHE   /*Do Not Run These Commnads in Production Environment*/
DBCC DROPCLEANBUFFERS 

-- To observe Reads
SET STATISTICS IO ON

-- Check the logical reads and observe the table scan happened
-- Turn on execution plan
SELECT * FROM SQLMaestros_Prod.HOLs
WHERE Column1=125

--Create a clustered index on Column1 column of HOLs table
CREATE CLUSTERED INDEX CL_HOLs_Column1 
ON [SQLMaestros_Prod].[HOLs](Column1 ASC);
GO --DROP INDEX CL_HOLs_Column1 ON SQLMaestros_Prod.HOLs


--DBCC IND ('sqlmaestros_prod','[SQLMaestros_Prod].[HOLs]',1)
--DBCC TRACEON (3604)
--DBCC PAGE ('SQLMaestros_Prod',1,1312,3)
--View index information for HOLs table
EXEC sp_helpindex 'SQLMaestros_Prod.HOLs';
GO


-- Check the no.of logical reads and observe the index seek happened
SELECT * FROM SQLMaestros_Prod.HOLs
WHERE Column1=125

-- Check the no.of logical reads and observe the clustered index scan happened
SELECT * FROM SQLMaestros_Prod.HOLs
WHERE Column4 = 840 -- this value may  change in your case

CREATE NONCLUSTERED INDEX NCL_HOLs_Column4 
ON SQLMaestros_Prod.HOLs(Column4)
GO --DROP INDEX NCL_HOLs_Column4 ON SQLMaestros_Prod.HOLs

-- Check the execution time and observe the index seek and key look up happened
SELECT * FROM SQLMaestros_Prod.HOLs
WHERE Column4 > 840 -- this value may  change in your case

-- DROP INDEX NCL_HOLs_Column4 ON SQLMaestros_Prod.HOLs

--Covering Index
CREATE NONCLUSTERED INDEX NCL_HOLs_Column4 ON SQLMaestros_Prod.HOLs(Column4)
INCLUDE (Column2,Column3)
GO --DROP INDEX NCL_HOLs_Column4 ON SQLMaestros_Prod.HOLs

-- Only index seek
SELECT * FROM SQLMaestros_Prod.HOLs
WHERE Column4 = 9442447 -- this value may  change in your case





