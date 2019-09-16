-- MS SQL
select 
    id,
    jan as jan_revenue,
    feb as feb_revenue, 
    mar as mar_revenue, 
    apr as apr_revenue,
    may as may_revenue,
    jun as jun_revenue,
    jul as jul_revenue,
    aug as aug_revenue,
    sep as sep_revenue,
    oct as oct_revenue,
    nov as nov_revenue,
    dec as dec_revenue
from department
pivot 
(
    max(revenue)
    for month in (jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec)        
) as t;

-- MySQL
select 
  id
  ,max(case when month = 'Jan' then revenue else null end) as 'Jan_Revenue'
  ,max(case when month = 'Feb' then revenue else null end) as 'Feb_Revenue'
  ,max(case when month = 'Mar' then revenue else null end) as 'Mar_Revenue'
  ,max(case when month = 'Apr' then revenue else null end) as 'Apr_Revenue'
  ,max(case when month = 'May' then revenue else null end) as 'May_Revenue'
  ,max(case when month = 'Jun' then revenue else null end) as 'Jun_Revenue'
  ,max(case when month = 'Jul' then revenue else null end) as 'Jul_Revenue'
  ,max(case when month = 'Aug' then revenue else null end) as 'Aug_Revenue'
  ,max(case when month = 'Sep' then revenue else null end) as 'Sep_Revenue'
  ,max(case when month = 'Oct' then revenue else null end) as 'Oct_Revenue'
  ,max(case when month = 'Nov' then revenue else null end) as 'Nov_Revenue'
  ,max(case when month = 'Dec' then revenue else null end) as 'Dec_Revenue'
from Department
group by id
order by id
  
