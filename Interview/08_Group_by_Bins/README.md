# Group by Bins

One common task is to put rows into bins, meaning that there does not exist a conveninet column for us to GROUP BY. In this notebook, we will use the *classicmodels* database. It contains a *customers* table. We will put customers into different class of credit limit.

* 0~50,000
* 50,001~100,000
* over 100,000

___

### Step 1. Create Column to Group By

```
SELECT
  customerName
  ,CASE 
  WHEN creditLimit BETWEEN 0 AND 50000 THEN '0 ~ 50k'
  WHEN creditLimit BETWEEN 50001 AND 100000 THEN '50 ~ 100k'
  ELSE '> 100k'
  END AS credit_range
FROM customers
LIMIT 5;

+----------------------------+--------------+
| customerName               | credit_range |
+----------------------------+--------------+
| Atelier graphique          | 0 ~ 50k      |
| Signal Gift Stores         | 50 ~ 100k    |
| Australian Collectors, Co. | > 100k       |
| La Rochelle Gifts          | > 100k       |
| Baane Mini Imports         | 50 ~ 100k    |
+----------------------------+--------------+
```

### Step 2. Group by Bin
```
SELECT
  CASE 
  WHEN creditLimit BETWEEN 0 AND 50000 THEN '0 ~ 50k'
  WHEN creditLimit BETWEEN 50001 AND 100000 THEN '50 ~ 100k'
  ELSE '> 100k'
  END AS credit_range
  ,COUNT(*) AS customer_tally
FROM customers
GROUP BY credit_range;

+--------------+----------------+
| credit_range | customer_tally |
+--------------+----------------+
| 0 ~ 50k      |             37 |
| 50 ~ 100k    |             60 |
| > 100k       |             25 |
+--------------+----------------+
3 rows in set (0.00 sec)
```

---
### Parting thought
This type of question can easily generalize to a broad range of topics. For example, what is the distribution of user's age, what is the distribution of revenue from each online order?