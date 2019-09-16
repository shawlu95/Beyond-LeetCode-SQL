with skeleton as (
select distinct product_id from Products
),
recent as (
select top 1 with ties product_id, new_price
from Products
where change_date <= '2019-08-16'
order by rank() over (partition by product_id order by change_date desc)
)
select a.product_id, coalesce(b.new_price, 10) as price
from skeleton a
left join recent b
on a.product_id = b.product_id
