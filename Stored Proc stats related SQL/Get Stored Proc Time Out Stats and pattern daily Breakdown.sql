SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-----================================================================================================================================================================================================================================================================
-- -- Time Out Info Last 1 year with Daily BreakDown
-----=============== =================================================================================================================================================================================================================================================
SELECT 
	
	CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END PROC_Name,
	--DATENAME(WEEKDAY,CreateDate) AS WeekDay,
	--CAST(CreateDate AS DATE) AS CreateDate,
	COUNT(*) Weekly_TimeOutCount,
	LogLevel,
	'Timeout expired'ErrorType
FROM RSLogs.dbo.ErrorLogs
WHERE CreateDate > DATEADD(DAY,(-7),CAST (GETDATE() AS DATE)) 
AND  ErrorType = 'SqlException' AND LogLevel ='Error'   
--AND CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
--         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')  
--	END IN ('FutureWorkDates_GetWithOutcomeCodesB')
AND Errormessage like '%Timeout expired%' 
GROUP BY 
	ErrorType,
	
	CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END ,
	--DATENAME(WEEKDAY,CreateDate),
	--CAST(CreateDate AS DATE),
	LogLevel
UNION 
SELECT 
	
	CASE When charIndex(' ', REPLACE(REPLACE(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''),'GetListByStoredProcedure',''),'GetListByStoredProcedure','')) > 0 
         THEN substring(REPLACE(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''),'GetListByStoredProcedure',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) 
		 ELSE REPLACE(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''),'GetListByStoredProcedure','') 
	END PROC_Name,
	--DATENAME(WEEKDAY,CreateDate) AS WeekDay,
	CAST(CreateDate AS DATE) AS CreateDate,
	COUNT(*) Daily_DeadLockCount,
	LogLevel,
	'Deadlock'ErrorType
FROM RSLogs.dbo.ErrorLogs
WHERE CreateDate > DATEADD(day,(-60),CAST (GETDATE() AS DATE)) 
AND  ErrorType = 'SqlException' AND LogLevel ='Error'   
--AND CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
--         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')  
--	END IN ('FutureWorkDates_GetWithOutcomeCodesB')
AND Errormessage like '%Deadlock%' 
GROUP BY 
	ErrorType,
	
CASE When charIndex(' ', REPLACE(REPLACE(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''),'GetListByStoredProcedure',''),'GetListByStoredProcedure','')) > 0 
         THEN substring(REPLACE(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''),'GetListByStoredProcedure',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) 
		 ELSE REPLACE(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''),'GetListByStoredProcedure','')  end  ,
	--DATENAME(WEEKDAY,CreateDate),
	CAST(CreateDate AS DATE),
	LogLevel


RETURN

SELECT 
	Application,
	CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END PROC_Name,
	DATENAME(WEEKDAY,CreateDate) AS WeekDay,
	CAST(CreateDate AS DATE) AS CreateDate,
	COUNT(*) TimeOutCount,
	LogLevel,
	'Timeout expired'ErrorType
FROM RSLogs.dbo.ErrorLogs
WHERE CreateDate > DATEADD(Month,(-1),CAST (GETDATE() AS DATE)) 
AND  ErrorType = 'SqlException' AND LogLevel ='Error'   
--AND CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
--         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')  
--	END IN ('FutureWorkDates_GetWithOutcomeCodesB')
AND Errormessage like '%Timeout expired%' 
GROUP BY 
	ErrorType,
	Application,
	CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END ,
	DATENAME(WEEKDAY,CreateDate),
	CAST(CreateDate AS DATE),
	LogLevel
ORDER BY CAST(CreateDate AS DATE) desc


-----================================================================================================================================================================================================================================================================
-- -- DeadLock Info 
-----================================================================================================================================================================================================================================================================
SELECT 
	Application,
	CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END PROC_Name,
	DATENAME(WEEKDAY,CreateDate) AS WeekDay,
	CAST(CreateDate AS DATE) AS CreateDate,
	COUNT(*) DeadLockCount,
	LogLevel,
	'Deadlock'ErrorType
FROM RSLogs.dbo.ErrorLogs
WHERE CreateDate > DATEADD(Month,(-1),CAST (GETDATE() AS DATE)) 
AND  ErrorType = 'SqlException' AND LogLevel ='Error'   
--AND CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
--         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')  
--	END IN ('FutureWorkDates_GetWithOutcomeCodesB')
AND Errormessage like '%Deadlock%' 
GROUP BY 
	ErrorType,
	Application,
	CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END ,
	DATENAME(WEEKDAY,CreateDate),
	CAST(CreateDate AS DATE),
	LogLevel
ORDER BY CAST(CreateDate AS DATE) DESC


-----================================================================================================================================================================================================================================================================
-- -- Get Execution stats for Time out and deadlock SQL connect to Primary Node 
-----================================================================================================================================================================================================================================================================

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

DROP TABLE IF EXISTS #temp
SELECT * INTO #temp FROM
(
SELECT 
	Application,
	CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END PROC_Name,
	COUNT(*) TimeOutCount
FROM RSLogs.dbo.ErrorLogs
WHERE CreateDate > DATEADD(year,(-1),CAST (GETDATE() AS DATE)) 
AND  ErrorType = 'SqlException' AND LogLevel ='Error'   
--AND CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
--         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')  
--	END IN ('FutureWorkDates_GetWithOutcomeCodesB')
AND (Errormessage like '%Timeout expired%'  OR Errormessage like '%Deadlock%') 
GROUP BY 
	ErrorType,
	Application,
	CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') 
	END 
)A

SELECT * FROM #temp 


-----================================================================================================================================================================================================================================================================
-- Stats for Matt on Time out and Deadlock
-----================================================================================================================================================================================================================================================================

SELECT 
	
	
	DATENAME(MONTH,CreateDate) [MONTH], DATENAME(Year,CreateDate) [Year],
	CAST(CreateDate AS DATE) [Date],
	COUNT(*) TimeOutCount,
	LogLevel,
	'Timeout expired'ErrorType
FROM RSLogs.dbo.ErrorLogs_Old
WHERE DATENAME(MONTH,CreateDate) = 'DECEMBER' AND  DATENAME(Year,CreateDate) = 2018
AND  ErrorType = 'SqlException' AND LogLevel ='Error'   
--AND CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
--         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')  
--	END IN ('FutureWorkDates_GetWithOutcomeCodesB')
AND Errormessage like '%Timeout expired%' 
GROUP BY 
	ErrorType,
	
	CAST(CreateDate AS DATE) ,
	DATENAME(MONTH,CreateDate), DATENAME(Year,CreateDate),
	
	LogLevel
	ORDER BY CAST(CreateDate AS DATE) 


-----================================================================================================================================================================================================================================================================
-- -- DeadLock Info 
-----================================================================================================================================================================================================================================================================
SELECT 
	
	DATENAME(MONTH,CreateDate) [MONTH], DATENAME(Year,CreateDate) [Year],CAST(CreateDate AS DATE) [Date],
	COUNT(*) DeadLockCount,
	LogLevel,
	'Deadlock'ErrorType
FROM RSLogs.dbo.ErrorLogs_OLD
WHERE  DATENAME(MONTH,CreateDate) = 'DECEMBER' AND  DATENAME(Year,CreateDate) = 2018
AND  ErrorType = 'SqlException' AND LogLevel ='Error'   
--AND CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
--         THEN substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1) ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')  
--	END IN ('FutureWorkDates_GetWithOutcomeCodesB')
AND Errormessage like '%Deadlock%' 
GROUP BY 
	ErrorType,
	
	DATENAME(MONTH,CreateDate), DATENAME(Year,CreateDate),CAST(CreateDate AS DATE) ,
	
	LogLevel

		ORDER BY CAST(CreateDate AS DATE) 