# NULL Pathology
This notebook covers common pitfalls of using NULL. Any single one can ruin your query. This notebook is divided into the following sections.
* Counting Behavior
* Aggregation Behavior
* Boolean Behavior
* Inclusion & Exclusion Behavior
* Ordering Behavior
* Window Behavior

### Sample Data
Load the database file [db.sql](db.sql) to localhost MySQL. The *Balance* table will be created in the Practice database. 
```
mysql < db.sql -uroot -p
```

Take a look at the data. They will give you enough pain, if you decide to continue reading.
```
mysql> SELECT * FROM Balance;
+----+-------+---------+
| id | name  | balance |
+----+-------+---------+
|  1 | Alice |      10 |
|  2 | Bob   |       5 |
|  3 | NULL  |      20 |
|  4 | Cindy |    NULL |
|  5 | Bob   |      10 |
|  6 | Cindy |     100 |
|  7 | Shaw  |    NULL |
|  8 | NULL  |    NULL |
+----+-------+---------+
8 rows in set (0.01 sec)
```

---
### Counting Behavior
Make sure you are not surprised by the following counting behavior. Explain why those results are returned.

```
mysql> SELECT name, COUNT(*) FROM Balance GROUP BY name;
+-------+----------+
| name  | COUNT(*) |
+-------+----------+
| Alice |        1 |
| Bob   |        2 |
| NULL  |        2 |
| Cindy |        2 |
| Shaw  |        1 |
+-------+----------+
5 rows in set (0.00 sec)

mysql> SELECT name, COUNT(name) FROM Balance GROUP BY name ORDER BY name;
+-------+-------------+
| name  | COUNT(name) |
+-------+-------------+
| NULL  |           0 |
| Alice |           1 |
| Bob   |           2 |
| Cindy |           2 |
| Shaw  |           1 |
+-------+-------------+
5 rows in set (0.00 sec)

mysql> SELECT name, COUNT(distinct name) FROM Balance GROUP BY name ORDER BY name;
+-------+----------------------+
| name  | COUNT(distinct name) |
+-------+----------------------+
| NULL  |                    0 |
| Alice |                    1 |
| Bob   |                    1 |
| Cindy |                    1 |
| Shaw  |                    1 |
+-------+----------------------+
5 rows in set (0.00 sec)

mysql> SELECT name, COUNT(balance) FROM Balance GROUP BY name ORDER BY name;
+-------+----------------+
| name  | COUNT(balance) |
+-------+----------------+
| NULL  |              1 |
| Alice |              1 |
| Bob   |              2 |
| Cindy |              1 |
| Shaw  |              0 |
+-------+----------------+
5 rows in set (0.00 sec)

mysql> SELECT name, COUNT(distinct balance) FROM Balance GROUP BY name ORDER BY name;
+-------+-------------------------+
| name  | COUNT(distinct balance) |
+-------+-------------------------+
| NULL  |                       1 |
| Alice |                       1 |
| Bob   |                       2 |
| Cindy |                       1 |
| Shaw  |                       0 |
+-------+-------------------------+
5 rows in set (0.00 sec)

```

---
### Aggregation Behavior

In *SUM()*, *MAX()*, *MIN()*, *AVG()*, rows containing *NULL* are simply ignored. When calculating average, they are not even counted in the denoominator.

__Attention__: when column in GROUP BY clause contains NULL, NULL will not be ignored!  See examples below:

```
mysql> SELECT name, SUM(balance) FROM Balance GROUP BY name;
+-------+--------------+
| name  | SUM(balance) |
+-------+--------------+
| Alice |           10 |
| Bob   |           15 |
| NULL  |           20 |
| Cindy |          100 |
| Shaw  |         NULL |
+-------+--------------+
5 rows in set (0.00 sec)

mysql> SELECT name, MAX(balance) FROM Balance GROUP BY name;
+-------+--------------+
| name  | MAX(balance) |
+-------+--------------+
| Alice |           10 |
| Bob   |           10 |
| NULL  |           20 |
| Cindy |          100 |
| Shaw  |         NULL |
+-------+--------------+
5 rows in set (0.00 sec)

mysql> SELECT name, AVG(balance) FROM Balance GROUP BY name;
+-------+--------------+
| name  | AVG(balance) |
+-------+--------------+
| Alice |      10.0000 |
| Bob   |       7.5000 |
| NULL  |      20.0000 |
| Cindy |     100.0000 |
| Shaw  |         NULL |
+-------+--------------+
5 rows in set (0.00 sec)

```

---
### Boolean Behavior
* True and NULL returns NULL
* True or NULLreturns __True__
* False and NULL returns__False__
* False or NULL returns NULL
* NULL = 0 returns NULL
* NULL != 12 returns NULL
* NULL +3 returns NULL
* NULL || 'str' returns NULL
* __NULL = NULL__ returns NULL
* __NULL != NULL__ returns NULL

---
### Inclusion & Exclusion Behavior
When excluding an individual row, we risk exclusing __all__ the NULL rows.
```
mysql> SELECT name FROM balance WHERE name != "Alice";
+-------+
| name  |
+-------+
| Bob   |
| Cindy |
| Bob   |
| Cindy |
| Shaw  |
+-------+
5 rows in set (0.00 sec)

-- FIX
mysql> SELECT name FROM balance WHERE name != "Alice" OR name IS NULL;
+-------+
| name  |
+-------+
| Bob   |
| NULL  |
| Cindy |
| Bob   |
| Cindy |
| Shaw  |
| NULL  |
+-------+
7 rows in set (0.00 sec)
```

*NOT IN* clause is converted to a series of *AND*. Any 'True' flag, when ANDing with NULL (returned by name != NULL), produces NULL. The following query returns __empty__ set!
```
mysql> SELECT name FROM balance WHERE name not IN ("Alice", NULL);
Empty set (0.00 sec)
```

By similar logic, the following query will not return NULL row! Because NULL != any_value returns NULL.
```
-- equivalent to name != 'Alice' AND name != 'Bob' AND name != 'Cindy'
mysql> SELECT name FROM balance WHERE name not IN ("Alice", "Bob", "Cindy");
+------+
| name |
+------+
| Shaw |
+------+
1 row in set (0.00 sec)
```

On the other hand, *IN* clause is converted to a series of *OR*. Any 'True' flag, when ORing with NULL, produces True.
```
mysql> SELECT name FROM balance WHERE name IN ("Alice", NULL);
+-------+
| name  |
+-------+
| Alice |
+-------+
1 row in set (0.01 sec)
```

For an even more pathological example, considering using the following query to find the maximum balance (instead of using *MAX()*). This is just crazy enough to fail! The reason is that there is NULL in the subquery. *ALL* clause is convereted into series of *AND* (similar to *NOT IN* clause). The entire subquery returns true only if all comparison return True. Unfortunately, any_value >= NULL returns NULL.

```
mysql> SELECT name, balance
    -> FROM Balance 
    -> WHERE balance >= ALL(SELECT balance FROM Balance);
Empty set (0.00 sec)

-- FIX
mysql> SELECT name, balance
    -> FROM Balance 
    -> WHERE balance >= ALL(SELECT balance FROM Balance WHERE balance IS NOT NULL);
+-------+---------+
| name  | balance |
+-------+---------+
| Cindy |     100 |
+-------+---------+
1 row in set (0.00 sec)
```

---
### Ordering Behavior
Note that when in ASC order, NULL appears first. In DESC order, NULL appears last. Use *COALESCE()* if we want to place *NULL* at the end, while still have *ASC* order for the rest of the rows.
```
mysql> SELECT name, balance FROM Balance ORDER BY balance;
+-------+---------+
| name  | balance |
+-------+---------+
| Cindy |    NULL |
| Shaw  |    NULL |
| NULL  |    NULL |
| Bob   |       5 |
| Alice |      10 |
| Bob   |      10 |
| NULL  |      20 |
| Cindy |     100 |
+-------+---------+
8 rows in set (0.00 sec)

mysql> SELECT name, balance FROM Balance ORDER BY COALESCE(balance, 1E9);
+-------+---------+
| name  | balance |
+-------+---------+
| Bob   |       5 |
| Alice |      10 |
| Bob   |      10 |
| NULL  |      20 |
| Cindy |     100 |
| Cindy |    NULL |
| Shaw  |    NULL |
| NULL  |    NULL |
+-------+---------+
8 rows in set (0.00 sec)
```

In a GROUP BY clause, ordering is applied by default. See the following example: without using ORDER BY name, the results are already ordered by name.

```
mysql> SELECT name, SUM(balance) AS sum_balance FROM Balance GROUP BY name;
+-------+-------------+
| name  | sum_balance |
+-------+-------------+
| Alice |          10 |
| Bob   |          15 |
| NULL  |          20 |
| Cindy |         100 |
| Shaw  |        NULL |
+-------+-------------+
5 rows in set (0.00 sec)

mysql> SELECT name, SUM(balance) AS sum_balance FROM Balance GROUP BY name ORDER BY sum_balance;
+-------+-------------+
| name  | sum_balance |
+-------+-------------+
| Shaw  |        NULL |
| Alice |          10 |
| Bob   |          15 |
| NULL  |          20 |
| Cindy |         100 |
+-------+-------------+
5 rows in set (0.00 sec)
```

---
### Window Behavior
Unlike aggregate function, ranking function does not ignore NULL. 

```
SELECT id, name, balance
	,ROW_NUMBER() OVER (PARTITION BY name ORDER BY balance) AS row_num
	,RANK() OVER (PARTITION BY name ORDER BY balance) AS rnk
	,DENSE_RANK() OVER (PARTITION BY name ORDER BY balance) AS dense_rnk
	,SUM(balance) OVER (PARTITION BY name ORDER BY balance) AS cum_sum
	,AVG(balance) OVER (PARTITION BY name ORDER BY balance) AS sum_avg
FROM balance
ORDER BY name DESC;

+----+-------+---------+---------+-----+-----------+---------+----------+
| id | name  | balance | row_num | rnk | dense_rnk | cum_sum | sum_avg  |
+----+-------+---------+---------+-----+-----------+---------+----------+
|  7 | Shaw  |    NULL |       1 |   1 |         1 |    NULL |     NULL |
|  4 | Cindy |    NULL |       1 |   1 |         1 |    NULL |     NULL |
|  6 | Cindy |     100 |       2 |   2 |         2 |     100 | 100.0000 |
|  2 | Bob   |       5 |       1 |   1 |         1 |       5 |   5.0000 |
|  5 | Bob   |      10 |       2 |   2 |         2 |      15 |   7.5000 |
|  1 | Alice |      10 |       1 |   1 |         1 |      10 |  10.0000 |
|  3 | NULL  |      20 |       2 |   2 |         2 |      20 |  20.0000 |
|  8 | NULL  |    NULL |       1 |   1 |         1 |    NULL |     NULL |
+----+-------+---------+---------+-----+-----------+---------+----------+
8 rows in set (0.00 sec)
```

How does ranking function handle multiple NULL? Let's take a look!

```
SELECT id, balance
	,ROW_NUMBER() OVER (ORDER BY balance) AS row_num
	,RANK() OVER (ORDER BY balance) AS rnk
	,RANK() OVER (ORDER BY balance DESC) AS rnk_desc
	,DENSE_RANK() OVER (ORDER BY balance) AS dense_rnk
	,DENSE_RANK() OVER (ORDER BY balance DESC) AS dense_rnk_desc
	,SUM(balance) OVER (ORDER BY balance) AS cum_sum
	,AVG(balance) OVER (ORDER BY balance) AS sum_avg
FROM balance
ORDER BY balance;

+----+---------+---------+-----+----------+-----------+----------------+---------+---------+
| id | balance | row_num | rnk | rnk_desc | dense_rnk | dense_rnk_desc | cum_sum | sum_avg |
+----+---------+---------+-----+----------+-----------+----------------+---------+---------+
|  7 |    NULL |       2 |   1 |        6 |         1 |              5 |    NULL |    NULL |
|  8 |    NULL |       3 |   1 |        6 |         1 |              5 |    NULL |    NULL |
|  4 |    NULL |       1 |   1 |        6 |         1 |              5 |    NULL |    NULL |
|  2 |       5 |       4 |   4 |        5 |         2 |              4 |       5 |  5.0000 |
|  5 |      10 |       6 |   5 |        3 |         3 |              3 |      25 |  8.3333 |
|  1 |      10 |       5 |   5 |        3 |         3 |              3 |      25 |  8.3333 |
|  3 |      20 |       7 |   7 |        2 |         4 |              2 |      45 | 11.2500 |
|  6 |     100 |       8 |   8 |        1 |         5 |              1 |     145 | 29.0000 |
+----+---------+---------+-----+----------+-----------+----------------+---------+---------+
8 rows in set (0.01 sec)
```

Interestingly, both *RANK()* and *DENSE_RANK()* consider all NULL as equal rank! The row number does not go with the order, because there is simply no order among the three NULLs. The other aggregate functions behave just as usual.
