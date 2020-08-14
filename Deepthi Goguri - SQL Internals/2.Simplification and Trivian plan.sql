--Simplification

USE [AdventureWorks2016];
GO

-- Subqueries to joins
--converts subqueries to joins

SELECT
OH.[SalesOrderID]
,OH.[AccountNumber]
,OH.[SubTotal]
FROM
  [Sales].[SalesOrderHeader] AS OH
  WHERE
  (OH.CustomerID IN (SELECT
                        [CustomerID]
					 FROM [Sales].[Customer]
					 WHERE
					   [TerritoryID]=1));
GO


-- Unused table and redundant joins
-- Removes unused table, redundant inner and outer joins

SELECT
OH.[SalesOrderID]
,OH.[AccountNumber]
,OH.[SubTotal]
,OH.[TerritoryID]
FROM
  [Sales].[SalesOrderHeader] AS OH
LEFT OUTER JOIN
 [Sales].[Customer] AS C ON C.CustomerID=OH.CustomerID
WHERE
  (OH.[TerritoryID]=1)
GO


-- Contradictions
-- Query Optimizer detects contradictions, such as opposite
-- conditions in the WHERE clause

SET STATISTICS IO ON;

SELECT CustomerID,[TerritoryID]
FROM [Sales].[Customer]
WHERE [TerritoryID] = 1
AND [TerritoryID] != 1
OPTION (RECOMPILE)



-- Trivial Plan- Query Optimizer will check if the query is qualified for a trivial plan
--Once the trivial plan is choosen, optimization process ends immediately

USE [AdventureWorks2016];
GO

SELECT
 [SalesOrderID]
,[TerritoryID]
FROM
  [Sales].[SalesOrderHeader]
WHERE
[SalesOrderID]=43661;
GO

--Query having Trivial Plan  can be forced to have FULL plan

-- TF 3604 enables output in the messages tab
-- TF 8757 is used to force Trivial plan to FULL optimization

SELECT
 [SalesOrderID]
,[TerritoryID]
FROM
  [Sales].[SalesOrderHeader]
WHERE
[SalesOrderID]=43661
OPTION(RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8757);
GO

