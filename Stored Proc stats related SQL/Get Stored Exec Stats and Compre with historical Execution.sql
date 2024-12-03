DECLARE @CollectionDate DATETIME
DECLARE @CollectionDateLastWeek DATETIME 

SELECT @CollectionDate = MAX(CollectionDate) FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily

SELECT @CollectionDateLastWeek =  MAX(CollectionDate) FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily WHERE CollectionDate < DATEADD( Day,-1,@CollectionDate)


SELECT 
	LastWeek.StoredProcName,
	Today.AVG_ELAPSED_SEC - LastWeek.AVG_ELAPSED_SEC ExecutiontimeDiffINSec ,CAST(((Today.AVG_ELAPSED_SEC - LastWeek.AVG_ELAPSED_SEC)/Today.AVG_ELAPSED_SEC)*100 AS decimal(10,2)) [ExecutiontimeDiff%],
	--Today.AVG_ELAPSED_SEC - LastWeek.AVG_ELAPSED_SEC,
	Today.AVG_ELAPSED_SEC ExecutiontimeToday,LastWeek.AVG_ELAPSED_SEC  ExecutiontimeLastWeek,
	--Today.Total_Execution Total_ExecutionToday,LastWeek.Total_Execution Total_ExecutionLastWeek,
	LastWeek.CollectionDate CollectionDateLastWeekCollectionDate,today.CollectionDate CollectionDateToday
FROM 
	(SELECT * FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily WHERE CollectionDate = @CollectionDate) Today
	JOIN
	(SELECT * FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily WHERE CollectionDate = @CollectionDateLastWeek) LastWeek
	ON LastWeek.StoredProcName = Today.StoredProcName
	WHERE CAST(((Today.AVG_ELAPSED_SEC - LastWeek.AVG_ELAPSED_SEC)/Today.AVG_ELAPSED_SEC)*100 AS decimal(10,2)) >50
ORDER BY ExecutiontimeDiffINSec	 DESC

RETURN
SELECT * FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily
WHERE StoredProcName ='Users_SearchCore_NoFilters'
ORDER BY CollectionDate DESC

