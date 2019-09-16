select round(coalesce(avg(sess), 0), 2) as average_sessions_per_user from (
select user_id, count(distinct session_id) as sess
from Activity
where activity_date between '2019-06-28' and '2019-07-27'
group by user_id 
) a;
