# Invalid Search

Given the following table, what is the percentage of invalid search result, and the total number of searches for each country?

__Schema__
```sql
mysql> describe SearchCategory;
+-----------------+---------------+------+-----+---------+-------+
| Field           | Type          | Null | Key | Default | Extra |
+-----------------+---------------+------+-----+---------+-------+
| country         | varchar(10)   | NO   | PRI | NULL    |       |
| search_cat      | varchar(10)   | NO   | PRI | NULL    |       |
| num_search      | int(10)       | YES  |     | NULL    |       |
| zero_result_pct | decimal(10,0) | YES  |     | NULL    |       |
+-----------------+---------------+------+-----+---------+-------+
4 rows in set (0.01 sec)
```

__Sample data__
```

mysql> select * from SearchCategory LIMIT 3;
+---------+------------+------------+-----------------+
| country | search_cat | num_search | zero_result_pct |
+---------+------------+------------+-----------------+
| CN      | dog        |    9700000 |            NULL |
| CN      | home       |    1200000 |              13 |
| CN      | tax        |       1200 |              99 |
+---------+------------+------------+-----------------+
3 rows in set (0.00 sec)
```

__Result table__
| country | num_search | zeo_result_pct |


### Load Data
Load the database file [db.sql](db.sql) to localhost MySQL. A Search database will be created. 
```
mysql < db.sql -uroot -p
```

___
## Observation
This question tests one single skill: given an aggregated table, the goal is to aggregated one level higher. The tricky point is to handle numerous __NULL__ cases. In the naive way, we may do the following:

```
SELECT
  country
  ,SUM(num_search) AS num_search
  ,SUM(num_search * zero_result_pct) AS sum_zero_result
FROM SearchCategory
GROUP BY country;

+---------+------------+-----------------+
| country | num_search | sum_zero_result |
+---------+------------+-----------------+
| CN      |   11881200 |        26498800 |
| UAE     |       NULL |            NULL |
| UK      |     198000 |          398000 |
| US      |     211500 |          218500 |
+---------+------------+-----------------+
4 rows in set (0.00 sec)
```

Then divide the two columns to get net percentage of zero result searches.
```
SELECT
  country, 
  num_search,
  ROUND(sum_zero_result / num_search, 2) AS zero_result_pct
FROM (
  SELECT
    country
    ,SUM(num_search) AS num_search
    ,SUM(num_search * zero_result_pct) AS sum_zero_result
  FROM SearchCategory
  GROUP BY country) AS a;

+---------+------------+-----------------+
| country | num_search | zero_result_pct |
+---------+------------+-----------------+
| CN      |   11881200 |            2.23 |
| UAE     |       NULL |            NULL |
| UK      |     198000 |            2.01 |
| US      |     211500 |            1.03 |
+---------+------------+-----------------+
4 rows in set (0.00 sec)
```

___
### Trouble-shooting NULL
Here are some cases where __NULL__ will not cause trouble.
* If *search_cat* is __NULL__, it does not change the result, because it is neither aggregated over, nor grouped by.
* If both *num_search* and *zero_result_pct* are __NULL__, their product is NULL. This row contributes to neither the numerator nor the denominator.
* If *country* is __NULL__ but the other columns are not, we get a row in the result table for the __NULL__ group. In this exercise, we do not deal with such pathological case. The table structure implies that *country-num_search* is a composite primary key, which cannot contain __NULL__.
* If the summed *num_search* is null for every category in a country, the denominator of outer query is 0. Fortunately, division by 0 yields 0, which is expected.

__The Hidden Error__
If *zero_result_pct* is __NULL__, the multiplying it with *num_search* results in __NULL__. Summing over it with other numeric values does not change the sum, but the denominator includes the *num_search* columns. We are effectively treating this row as having __zero__ invalid result! 

Take China for example, the dog category has the highest volume of searches, and yet we are treating it as having zero invalid result. The resulting net percentage is grossly underestimated.

```
SELECT * FROM SearchCategory WHERE country = 'CN';
+---------+------------+------------+-----------------+
| country | search_cat | num_search | zero_result_pct |
+---------+------------+------------+-----------------+
| CN      | dog        |    9700000 |            NULL |
| CN      | home       |    1200000 |              13 |
| CN      | tax        |       1200 |              99 |
| CN      | travel     |     980000 |              11 |
+---------+------------+------------+-----------------+
4 rows in set (0.00 sec)
```

To fix the denominator, we add a case statement. See that the *num_search* column drops lower for China and US.
```
SELECT
  country
  ,SUM(CASE WHEN zero_result_pct IS NOT NULL THEN num_search ELSE NULL END) AS num_search
  ,SUM(num_search * zero_result_pct) AS sum_zero_result
FROM SearchCategory
GROUP BY country;
+---------+------------+-----------------+
| country | num_search | sum_zero_result |
+---------+------------+-----------------+
| CN      |    2181200 |        26498800 |
| UAE     |       NULL |            NULL |
| UK      |     198000 |          398000 |
| US      |     199500 |          218500 |
+---------+------------+-----------------+
```

Finally, we can get the proper estimate of invalid search. See how much we had underestimated the *zero_result_pct* earlier!
```
SELECT
  country, 
  num_search,
  ROUND(sum_zero_result / num_search, 2) AS zero_result_pct
FROM (
  SELECT
    country
    ,SUM(CASE WHEN zero_result_pct IS NOT NULL THEN num_search ELSE NULL END) AS num_search
    ,SUM(num_search * zero_result_pct) AS sum_zero_result
  FROM SearchCategory
  GROUP BY country) AS a;
+---------+------------+-----------------+
| country | num_search | zero_result_pct |
+---------+------------+-----------------+
| CN      |    2181200 |           12.15 |
| UAE     |       NULL |            NULL |
| UK      |     198000 |            2.01 |
| US      |     199500 |            1.10 |
+---------+------------+-----------------+
4 rows in set (0.00 sec)
```

___
### Optional: MySQL8
```
WITH tmp AS (
SELECT
    country
    ,SUM(CASE WHEN zero_result_pct IS NOT NULL THEN num_search ELSE NULL END) AS num_search
    ,SUM(num_search * zero_result_pct) AS sum_zero_result
  FROM SearchCategory
  GROUP BY country
)
SELECT
  country, 
  num_search,
  ROUND(sum_zero_result / num_search, 2) AS zero_result_pct
FROM tmp;
+---------+------------+-----------------+
| country | num_search | zero_result_pct |
+---------+------------+-----------------+
| CN      |    2181200 |           12.15 |
| UAE     |       NULL |            NULL |
| UK      |     198000 |            2.01 |
| US      |     199500 |            1.10 |
+---------+------------+-----------------+
4 rows in set (0.00 sec)
```

___
### Parting Thought
Though this notebook is meant to be exhaustive, you should communicate with interviewers on which columns can be __NULL__ and which cannot. Some columns cannot be __NULL__ by design. Also, ask for how to present the result where value is __NULL__: whether to leave it as __NULL__ or replace it with more informative text.

See solution [here](solution.sql).