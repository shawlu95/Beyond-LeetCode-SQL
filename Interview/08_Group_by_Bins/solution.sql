SELECT
  CASE 
  WHEN creditLimit BETWEEN 0 AND 50000 THEN '0 ~ 50k'
  WHEN creditLimit BETWEEN 50001 AND 100000 THEN '50 ~ 100k'
  ELSE '> 100k'
  END AS credit_range
  ,COUNT(*) AS customer_tally
FROM customers
GROUP BY credit_range;