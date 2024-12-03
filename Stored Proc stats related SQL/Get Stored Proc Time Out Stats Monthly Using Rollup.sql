SELECT 
    COALESCE (DATENAME(Month,CreateDate),'              Total') AS [Month],coalesce (CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END, 'All Proc') AS [PROC],
	CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END PROC_Name,
	COUNT(*) TimeOutCount,
	'Timeout expired'ErrorType
FROM RSLogs.dbo.ErrorLogs
WHERE CreateDate > DATEADD(MONTH,(-6),CAST (GETDATE() AS DATE)) 
AND  ErrorType = 'SqlException' AND LogLevel ='Error'   
--AND CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
--         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')  
--	END IN ('FutureWorkDates_GetWithOutcomeCodesB')
AND Errormessage like '%Timeout expired%' 
GROUP BY 
	ROLLUP(CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END ,
    DATENAME(Month,CreateDate))



