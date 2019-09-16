select round(100*avg(
    if(removed is null, 0, removed/reported)),2) as average_daily_percent from
(
select action_date date, count(distinct post_id) as reported
from actions 
where extra='spam'
group by action_date
) t1 left join
(
select action_date date, count(distinct actions.post_id) as removed
from actions, removals 
where extra='spam' and actions.post_id = removals.post_id 
group by action_date
) t2 on (t1.date=t2.date)
