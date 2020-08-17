
-- autoscale demo

-- clear procedure cache so that there is no auto tuning on the query

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE ;  

-- run CPU intensive query

DROP TABLE IF EXISTS  #Temp1
GO

DROP TABLE IF EXISTS  #Temp2
GO

SELECT MyInt = CONVERT(BIGINT, o1.object_id) + CONVERT(BIGINT, o2.object_id) + CONVERT(BIGINT, o3.object_id)
INTO #temp1
FROM sys.objects o1
JOIN sys.objects o2 ON o1.object_id < o2.object_id
JOIN sys.objects o3 ON o1.object_id < o3.object_id
order by o1.object_id

SELECT SUM(CONVERT(BIGINT, o1.MyInt) + CONVERT(BIGINT, o2.MyInt))
FROM #temp1 o1
JOIN #temp1 o2 ON o1.MyInt < o2.MyInt

SELECT MyInt = CONVERT(BIGINT, o1.object_id) + CONVERT(BIGINT, o2.object_id) + CONVERT(BIGINT, o3.object_id)
INTO #temp2
FROM sys.objects o1
JOIN sys.objects o2 ON o1.object_id < o2.object_id
JOIN sys.objects o3 ON o1.object_id < o3.object_id
order by o1.object_id

SELECT SUM(CONVERT(BIGINT, o1.MyInt) + CONVERT(BIGINT, o2.MyInt))
FROM #temp2 o1
JOIN #temp2 o2 ON o1.MyInt < o2.MyInt


-- get cpu usage statistics to show CPU autoscaling

select end_time as mesurement_end_time, cpu_limit as max_vcores, avg_cpu_percent
from sys.dm_db_resource_stats
order by end_time desc



