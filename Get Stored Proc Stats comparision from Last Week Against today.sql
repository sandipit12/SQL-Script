DECLARE @CollectionDate DATE;
DECLARE @CollectionDateLasPast DATE;

SELECT @CollectionDate = MAX(CAST(CollectionDate AS DATE))
FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily
WHERE CAST(CollectionDate AS DATE) =  '2020-04-03' -- Remove This to compare Aginst Todays Stats

SELECT @CollectionDateLasPast = MAX(CAST(CollectionDate AS DATE))
FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily
WHERE CAST(CollectionDate AS DATE) =  '2020-03-03'
--WHERE CollectionDate < DATEADD(WEEK, -1, @CollectionDate);


SELECT LastWeek.StoredProcName,
       Today.AVG_ELAPSED_SEC - LastWeek.AVG_ELAPSED_SEC AS ExecutiontimeDiff_Sec,
       CAST(((Today.AVG_ELAPSED_SEC - LastWeek.AVG_ELAPSED_SEC) / Today.AVG_ELAPSED_SEC) * 100 AS DECIMAL(10, 2)) PercentIncrease,
       Today.AVG_ELAPSED_SEC ExecutiontimeToday,
       LastWeek.AVG_ELAPSED_SEC Executiontime_Past,
       Today.Total_Execution Total_ExecutionToday,
       LastWeek.Total_Execution Total_Execution_Past,
       LastWeek.CollectionDate CollectionDate_Past,
       Today.CollectionDate CollectionDate_Today
FROM
(
    SELECT *
    FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily
    WHERE CAST(CollectionDate AS DATE) = @CollectionDate
) Today
    JOIN
    (
        SELECT *
        FROM Tools.dbo.SandipCollectStoredProcedureExecutionStats_Daily
        WHERE CAST(CollectionDate AS DATE) = @CollectionDateLasPast
    ) LastWeek
        ON LastWeek.StoredProcName = Today.StoredProcName
WHERE LastWeek.StoredProcName LIKE 'LoanContracts%' 
OR LastWeek.StoredProcName LIKE'LoanContractPayment%'
OR LastWeek.StoredProcName LIKE'FinancialTransactions%'
ORDER BY PercentIncrease DESC;