with ranked as (
select
  min(event_date) over (partition by player_id) as install_dt
  ,lead(event_date) over (partition by player_id order by event_date) as next_date
  ,rank() over (partition by player_id order by event_date) as rk
from Activity
)
select 
  install_dt
  ,count(*) as installs
  ,round(
      cast(sum(case when dateadd(day, 1, install_dt) = next_date then 1 else 0 end) as float) /
      count(*), 2) as day1_retention
from ranked
where rk = 1
group by install_dt
