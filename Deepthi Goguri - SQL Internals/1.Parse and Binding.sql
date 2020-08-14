--I used AdventureWorks2016 database for this demo
--please get the backup of the Adventureworks2016 database from below link:
https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=ssms
--Download OLTP version of Adventureworks2016 database backup.
--Created by Deepthi Goguri

--Parsing

USE [AdventureWorks2016];
GO

-- When PARSEONLY option is turned ON, SQL Server only parses the query

SET PARSEONLY ON;
GO

/* 
Checks for:
1. syntax of the query
2. returns any error messages
3. Doesn't compile or executes the query
4. No execution plan gets generated
*/

SELECT * FROM [Production].[Product];
GO

--checks for the variable declaration

SELECT * FROM [Production].[Product]
where size=@x
GO

 /* 
 The following query doesnt execute because the column and table name does not exist in the database
 but if you parse it, statement will still runs without errors because the statement is syntactically correct.
*/

SELECT noColumn FROM dbo.noTable;
GO


-- Reverting back to the default value (OFF) for PARSEONLY
SET PARSEONLY OFF;
GO


-- When FMTONLY option is turned ON, SQL Server performs the parsing and binding
-- phases for the statement
-- No execution plan is generated
-- 

/*
Prsing and Binding phases happen when option FMTONLY is turned ON
1. Execution plan doesn't get generated
2. Doesn't get processed 
3. No rows are processed or sent to the client
*/
SET FMTONLY ON;
GO

SELECT
OH.[SalesOrderID]
,OH.[AccountNumber]
,OH.[SubTotal]
,C.CustomerID
FROM
  [Sales].[SalesOrderHeader] AS OH
JOIN
 [Sales].[Customer] AS C ON OH.CustomerID=C.CustomerID
WHERE
  (OH.CustomerID IS NOT NULL);
GO


-- binding phase is now executed with FMTONLY=ON, this statement will fail 
SELECT noColumn FROM dbo.noTable;
GO


SET FMTONLY OFF;
GO


/*
Data type resolution
1. [CustomerID] [SalesOrderID] have the same data type
2. we can union the results together
*/

SELECT
[CustomerID]
FROM
 [Sales].[Customer]
UNION ALL
SELECT
  [SalesOrderID]
FROM
   [Sales].[SalesOrderHeader];
GO


/* 
Data type error
1. [CustomerID] is of Data type Int and [CreditCardApprovalCode] is of Data type Varchar
2. Sending this query to the optimizer throws an error while converting the varchar value
to Data type Int
*/

SELECT
[CustomerID]
FROM
 [Sales].[Customer]
UNION ALL
SELECT
[CreditCardApprovalCode]  
FROM
 [Sales].[SalesOrderHeader];
GO


