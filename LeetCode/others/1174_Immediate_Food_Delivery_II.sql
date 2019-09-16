with first as (
select top 1 with ties delivery_id, customer_id, order_date, customer_pref_delivery_date
from Delivery order by rank() over (partition by customer_id order by order_date)
)
select round(100 * sum(case when order_date = customer_pref_delivery_date then 1.0 else 0.0 end) / count(distinct customer_id), 2) as immediate_percentage from first;
