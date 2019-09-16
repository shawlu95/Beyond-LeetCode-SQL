with skeleton as (
select distinct spend_date, 'desktop' as platform from Spending
union all
select distinct spend_date, 'mobile' as platform from Spending
union all
select distinct spend_date, 'both' as platform from Spending
)

,labelled as (
select 
  spend_date, user_id, 
  case when count(distinct platform) = 1 then max(platform) else 'both' end as platform
from Spending group by spend_date, user_id
)

,agg as (
select 
  a.spend_date, b.platform, sum(a.amount) as total_amount, count(distinct a.user_id) as total_users
from Spending a
join labelled b
on a.spend_date = b.spend_date
and a.user_id = b.user_id
group by a.spend_date, b.platform
)

select 
  a.spend_date, a.platform
  ,coalesce(b.total_amount, 0) as total_amount
  ,coalesce(b.total_users, 0) as total_users
from skeleton as a
left join agg as b
on a.spend_date = b.spend_date
and a.platform = b.platform
