with norder as (
select buyer_id, count(*) as n from Orders
where order_date >= '2019-01-01'
group by buyer_id
)
select a.user_id as buyer_id, join_date, coalesce(n, 0) as orders_in_2019
from Users a
left join norder b
on a.user_id = b.buyer_id
