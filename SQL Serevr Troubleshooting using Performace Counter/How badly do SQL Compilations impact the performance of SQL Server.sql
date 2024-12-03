----How badly do SQL Compilations impact the performance of SQL Server?

 --It's a general rule of thumb that Compilations/sec should be at 10% or less than total Batch Requests/sec.
 declare @single_use_counts int, @multi_use_counts int

;with PlanCacheCte as 
(
    select
        db_name(st.dbid) as database_name,
        cp.bucketid,
        cp.usecounts,
        cp.size_in_bytes,
        cp.objtype,
        st.text
    from sys.dm_exec_cached_plans cp
    cross apply sys.dm_exec_sql_text(cp.plan_handle) st
    where cp.cacheobjtype = 'Compiled Plan'
)
select @single_use_counts = count(*)
from PlanCacheCte
where usecounts = 1

;with PlanCacheCte as 
(
    select
        db_name(st.dbid) as database_name,
        cp.bucketid,
        cp.usecounts,
        cp.size_in_bytes,
        cp.objtype,
        st.text
    from sys.dm_exec_cached_plans cp
    cross apply sys.dm_exec_sql_text(cp.plan_handle) st
    where cp.cacheobjtype = 'Compiled Plan'
)
select @multi_use_counts = count(*)
from PlanCacheCte
where usecounts > 1

select
    @single_use_counts as single_use_counts,
    @multi_use_counts as multi_use_counts,
    @single_use_counts * 1.0 / (@single_use_counts + @multi_use_counts) * 100
        as percent_single_use_counts