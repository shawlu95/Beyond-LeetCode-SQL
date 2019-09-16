with ranked as (
select seller_id, item_id, rank() over (partition by seller_id order by order_date) as rk 
from Orders
),

joined_items as (
select a.seller_id, a.item_id, a.rk, b.item_brand
from ranked a
join Items b
on a.item_id = b.item_id
where rk = 2)

select 
  a.user_id as seller_id, 
  case when a.favorite_brand = b.item_brand then 'yes' else 'no' end as '2nd_item_fav_brand'
from Users a
left join joined_items b
on a.user_id = b.seller_id
