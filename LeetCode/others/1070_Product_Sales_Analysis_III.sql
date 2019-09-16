select top 1 with ties product_id, year as first_year, quantity, price
from Sales
order by rank() over (partition by product_id order by year);
