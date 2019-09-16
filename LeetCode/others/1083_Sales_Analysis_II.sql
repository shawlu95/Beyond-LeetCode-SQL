with joined as (
select a.product_id, a.product_name, b.buyer_id
from Product a
join Sales b
on a.product_id = b.product_id
)
,iphone as (
select distinct buyer_id
from joined where product_name = 'iPhone'
)
,s8 as (
select distinct buyer_id
from joined where product_name = 'S8'
)
select a.buyer_id
from s8 a
left join iphone b
on a.buyer_id = b.buyer_id
where b.buyer_id is null
