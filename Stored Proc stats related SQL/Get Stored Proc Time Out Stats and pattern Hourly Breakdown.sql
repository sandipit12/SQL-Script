SELECT ErrorType,case When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
           Then substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1)
           else REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') END PROC_Name,DATENAME(WEEKDAY,CreateDate) AS WeekDay,CAST(CreateDate AS DATE) AS CreateDate ,COUNT(*) TimeOutCount,LogLevel ,
RIGHT('00'+ISNULL(CAST(DATENAME(HH,CreateDate)AS VARCHAR(5)) ,''),2)+':00 - ' + CAST(DATENAME(HH,CreateDate)+1 AS VARCHAR(5))+':00' AS HourlybrkDown--+':'+DATENAME(MINUTE,CreateDate) AS [Hour:MINUTE]
FROM RSLogs.dbo.ErrorLogs

WHERE CreateDate > DATEADD(DD,(-1*28),CAST (GETDATE() AS DATE)) 
AND  ErrorType = 'SqlException' AND LogLevel ='Error' AND Application <> 'BatchProcessor'  
AND CASE 
       WHEN charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
			THEN SUBSTRING(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1)
            ELSE REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') END IN ('FutureWorkDates_GetWithOutcomeCodesB')
GROUP BY 
ErrorType, 
CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
           Then substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1)
           else REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') END ,CAST(CreateDate AS DATE),DATENAME(WEEKDAY,CreateDate),LogLevel, --,ErrorSource
RIGHT('00'+ISNULL(CAST(DATENAME(HH,CreateDate)AS VARCHAR(5)) ,''),2)+':00 - ' + CAST(DATENAME(HH,CreateDate)+1 AS VARCHAR(5))+':00'--+':'+DATENAME(MINUTE,CreateDate) AS [Hour:MINUTE]

ORDER BY 
CAST(CreateDate AS DATE) DESC ,
DATENAME(WEEKDAY,CreateDate) ,
RIGHT('00'+ISNULL(CAST(DATENAME(HH,CreateDate)AS VARCHAR(5)) ,''),2)+':00 - ' + CAST(DATENAME(HH,CreateDate)+1 AS VARCHAR(5))+':00' , CASE When charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','')) > 0 
           Then substring(REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''), 1, charIndex(' ', REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ',''))-1)
           else REPLACE(REPLACE(Method,'ExecuteReader ',''),'ExecuteFunction ','') END