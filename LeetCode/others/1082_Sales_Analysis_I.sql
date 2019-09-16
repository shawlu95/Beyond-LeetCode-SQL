select top 1 with ties seller_id
from Sales
group by seller_id
order by sum(price) desc;
