select round(100 * sum(order_date = customer_pref_delivery_date) / count(*), 2) as immediate_percentage from Delivery;
