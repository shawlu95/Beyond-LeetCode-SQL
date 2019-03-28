# Sampling Technique

### Anti-pattern
One common pitfall of sampling is to assign a random number to each row, order all rows, and return the top few rows. This is very inefficient, as ordering takes O(nlogn) time and incurs IO cost when table is large. 
```sql
-- anti-pattern
SELECT TOP 1 PERCENT Number
FROM Numbers
ORDER BY newid()
```

---
### Trivial Solution
MS SQL has *TABLESAMPLE* method avaialble, which returns any desired number of rows, as a percentage of the entire table.
```sql
-- MS SQL
SELECT * from [TABLE] tablesample(1 PERCENT)
```

---
### The *Interview* Solution
This notebook introduces a different technique that addresses the question: "sample N rows from each group." Specifically, we use the world (database)[databases/world_db], and randomly draw 10 cities from each continent.

The objective is to sample without sorting random number. First we need to assign a random number to each row, and then determine a cutoff threshold for each group. Finally, return rows below the cutoff threshold. To ensure that each group has at least the desired number of samples, we need to relax the threshold a little. 

We can model the selection as a Binomial process, we can get the parameter *p*, which is simple the sample_size / group_size. From *p* we can calculate the standard deviation, and adjust the threshold probability to include more rows wuch that the probability of drawing fewer than desired sample size is small.

First, import the [database](../databases/world_db/) in terminal.
```bash
mysql < world.sql -uroot -p
```

---
#### Create Source Table
Create the table we will be sampling from. To have continent and city columns in the same table, we need to join two tables in the world database.
```sql
-- this is the table we want to sample from (given)
DROP TABLE IF EXISTS city_by_continent;
CREATE TEMPORARY TABLE city_by_continent AS
SELECT 
  city.Name AS city_name
  ,country.Name AS country_name
  ,country.continent
FROM city
JOIN country
ON city.countryCode = country.code;
```
```
-- show 10 rows
+----------------+--------------+---------------+
| city_name      | country_name | continent     |
+----------------+--------------+---------------+
| Oranjestad     | Aruba        | North America |
| Kabul          | Afghanistan  | Asia          |
| Qandahar       | Afghanistan  | Asia          |
| Herat          | Afghanistan  | Asia          |
| Mazar-e-Sharif | Afghanistan  | Asia          |
| Luanda         | Angola       | Africa        |
| Huambo         | Angola       | Africa        |
| Lobito         | Angola       | Africa        |
| Benguela       | Angola       | Africa        |
| Namibe         | Angola       | Africa        |
+----------------+--------------+---------------+
10 rows in set (0.05 sec)
```

---
#### Calculate Group Statistics
What does this mean? Take Ocenia for example, it means that if we draw from __every one__ of its cities with Binomial probability 0.1818, we get 10 successes on average, with 2.86 standard deviation. 
```sql
-- check gorup size 
-- use normal distirbution to approximate binomial draw
DROP TABLE IF EXISTS sample_dist_stats;
CREATE TEMPORARY TABLE sample_dist_stats AS
SELECT
  continent
  ,COUNT(*) AS city_tally
  ,10/COUNT(*) AS p
  ,10 AS mean
  ,SQRT(COUNT(*) * (10/COUNT(*)) * (1-10/COUNT(*))) AS std
FROM city_by_continent
GROUP BY continent
ORDER BY city_tally;
```
```
mysql> SELECT * FROM sample_dist_stats LIMIT 10;
+---------------+------------+--------+------+--------------------+
| continent     | city_tally | p      | mean | std                |
+---------------+------------+--------+------+--------------------+
| Oceania       |         55 | 0.1818 |   10 |  2.860387762731098 |
| Africa        |        366 | 0.0273 |   10 |  3.118777938186021 |
| South America |        470 | 0.0213 |   10 | 3.1284554827337416 |
| North America |        581 | 0.0172 |   10 | 3.1349453619779277 |
| Europe        |        841 | 0.0119 |   10 |  3.143420682983631 |
| Asia          |       1766 | 0.0057 |   10 | 3.1533116854448204 |
+---------------+------------+--------+------+--------------------+
6 rows in set (0.00 sec)
```

---
#### Expand Group Size Column
Since we need at least 10 samples from each group, we can relax the *p* threshold a little. For example, we can add 2 * std to the desired sample size. 

```sql
DROP TABLE IF EXISTS city_group;
CREATE TEMPORARY TABLE city_group AS 
SELECT
  c.*
  ,COUNT(*) OVER (PARTITION BY continent) AS group_size
FROM city_by_continent AS c;
```
```
mysql> SELECT * FROM  city_group LIMIT 5;
+----------------+----------------------+-----------+------------+
| city_name      | country_name         | continent | group_size |
+----------------+----------------------+-----------+------------+
| Kabul          | Afghanistan          | Asia      |       1766 |
| Qandahar       | Afghanistan          | Asia      |       1766 |
| Herat          | Afghanistan          | Asia      |       1766 |
| Mazar-e-Sharif | Afghanistan          | Asia      |       1766 |
| Dubai          | United Arab Emirates | Asia      |       1766 |
+----------------+----------------------+-----------+------------+
5 rows in set (0.00 sec)
```

Next, add the standard deviation column, which depends on the group size.
```sql
SET @sample_size = 10;

DROP TABLE IF EXISTS city_prob_assign;
CREATE TEMPORARY TABLE city_prob_assign AS 
SELECT
  c.*
  -- ,@sample_size
  -- ,group_size * @sample_size / group_size AS mean
  ,SQRT(group_size * (@sample_size / group_size) * (1 - @sample_size / group_size)) AS std
  ,RAND() AS prob
FROM city_group AS c;
```
```
SELECT * FROM  city_prob_assign LIMIT 5;
+----------------+----------------------+-----------+------------+--------------------+---------------------+
| city_name      | country_name         | continent | group_size | std                | prob                |
+----------------+----------------------+-----------+------------+--------------------+---------------------+
| Kabul          | Afghanistan          | Asia      |       1766 | 3.1533116854448204 |  0.7848065782196881 |
| Qandahar       | Afghanistan          | Asia      |       1766 | 3.1533116854448204 |   0.134653924158452 |
| Herat          | Afghanistan          | Asia      |       1766 | 3.1533116854448204 |  0.3188499168668407 |
| Mazar-e-Sharif | Afghanistan          | Asia      |       1766 | 3.1533116854448204 | 0.19028784259249254 |
| Dubai          | United Arab Emirates | Asia      |       1766 | 3.1533116854448204 |  0.9948894930955856 |
+----------------+----------------------+-----------+------------+--------------------+---------------------+
5 rows in set (0.00 sec)
```

---
#### Adjust Cutoff Threshold
Calculate the cut-off threshold, adjusted for 2 * standard deviations.
```sql
DROP TABLE IF EXISTS city_prob_cutoff;
CREATE TEMPORARY TABLE city_prob_cutoff AS 
SELECT
  c.*
  ,(@sample_size + CEIL(2 * std)) / group_size AS cutoff
FROM city_prob_assign AS c;

SELECT * FROM  city_prob_cutoff LIMIT 5;
```

Finally, filter the results by cutoff threshold. Notice we are ranking random number here. But because window function is evaluated after *WHERE* clause, we are only ranking a few rows in each group.
```sql
-- draw sample by cutoff probabilities
DROP TABLE IF EXISTS city_sample;
CREATE TEMPORARY TABLE city_sample AS 
SELECT 
  c.*
  -- window is evaluated after WHERE clause!
  -- ranking is cheap!
  ,RANK() OVER (PARTITION BY continent ORDER BY prob) AS group_row_num
FROM city_prob_cutoff AS c
WHERE prob < cutoff;
```
```
mysql> SELECT * FROM  city_sample LIMIT 5;
+-----------+--------------+-----------+------------+--------------------+-----------------------+--------+---------------+
| city_name | country_name | continent | group_size | std                | prob                  | cutoff | group_row_num |
+-----------+--------------+-----------+------------+--------------------+-----------------------+--------+---------------+
| Tianjin   | China        | Asia      |       1766 | 3.1533116854448204 | 0.0008353479214341826 | 0.0096 |             1 |
| Koyang    | South Korea  | Asia      |       1766 | 3.1533116854448204 | 0.0015736427172772984 | 0.0096 |             2 |
| Honghu    | China        | Asia      |       1766 | 3.1533116854448204 | 0.0017311302961140222 | 0.0096 |             3 |
| Mahabad   | Iran         | Asia      |       1766 | 3.1533116854448204 | 0.0019912449661560775 | 0.0096 |             4 |
| Tianmen   | China        | Asia      |       1766 | 3.1533116854448204 |  0.003459511327985219 | 0.0096 |             5 |
+-----------+--------------+-----------+------------+--------------------+-----------------------+--------+---------------+
5 rows in set (0.00 sec)
```

---
#### Sampling
Check that sample size are at least 10!
```sql
-- check sample size
SELECT continent, COUNT(*) AS sample_size 
FROM city_prob_cutoff
WHERE prob < cutoff
GROUP BY continent;
```
```
+---------------+-------------+
| continent     | sample_size |
+---------------+-------------+
| Asia          |          19 |
| Europe        |          19 |
| North America |          22 |
| Africa        |          14 |
| Oceania       |          15 |
| South America |          17 |
+---------------+-------------+
6 rows in set (0.00 sec)
```

Finally, cut off row number greater than 10, and retain 10 rows in each group.
```sql
-- draw fixed sample size
SELECT * 
FROM city_sample
WHERE group_row_num <= 10
LIMIT 20;
```
```
+-----------------+--------------------+-----------+------------+--------------------+-----------------------+--------+---------------+
| city_name       | country_name       | continent | group_size | std                | prob                  | cutoff | group_row_num |
+-----------------+--------------------+-----------+------------+--------------------+-----------------------+--------+---------------+
| Tianjin         | China              | Asia      |       1766 | 3.1533116854448204 | 0.0008353479214341826 | 0.0096 |             1 |
| Koyang          | South Korea        | Asia      |       1766 | 3.1533116854448204 | 0.0015736427172772984 | 0.0096 |             2 |
| Honghu          | China              | Asia      |       1766 | 3.1533116854448204 | 0.0017311302961140222 | 0.0096 |             3 |
| Mahabad         | Iran               | Asia      |       1766 | 3.1533116854448204 | 0.0019912449661560775 | 0.0096 |             4 |
| Tianmen         | China              | Asia      |       1766 | 3.1533116854448204 |  0.003459511327985219 | 0.0096 |             5 |
| Purnea (Purnia) | India              | Asia      |       1766 | 3.1533116854448204 |  0.004049095328942961 | 0.0096 |             6 |
| al-Nasiriya     | Iraq               | Asia      |       1766 | 3.1533116854448204 |  0.004353526052416792 | 0.0096 |             7 |
| Kueishan        | Taiwan             | Asia      |       1766 | 3.1533116854448204 |  0.004543391991912752 | 0.0096 |             8 |
| Dewas           | India              | Asia      |       1766 | 3.1533116854448204 | 0.0046459874181505175 | 0.0096 |             9 |
| Shijiazhuang    | China              | Asia      |       1766 | 3.1533116854448204 |  0.004931667824212152 | 0.0096 |            10 |
| West Bromwich   | United Kingdom     | Europe    |        841 |  3.143420682983631 |  0.001503678971439301 | 0.0202 |             1 |
| Orehovo-Zujevo  | Russian Federation | Europe    |        841 |  3.143420682983631 | 0.0033666901321771463 | 0.0202 |             2 |
| Baranovitši     | Belarus            | Europe    |        841 |  3.143420682983631 | 0.0045585548547641885 | 0.0202 |             3 |
| Arkangeli       | Russian Federation | Europe    |        841 |  3.143420682983631 | 0.0051870467189578775 | 0.0202 |             4 |
| Belfast         | United Kingdom     | Europe    |        841 |  3.143420682983631 | 0.0070222821152045225 | 0.0202 |             5 |
| Legnica         | Poland             | Europe    |        841 |  3.143420682983631 |  0.007184362976983528 | 0.0202 |             6 |
| Lugansk         | Ukraine            | Europe    |        841 |  3.143420682983631 |  0.007315824746448383 | 0.0202 |             7 |
| Balakovo        | Russian Federation | Europe    |        841 |  3.143420682983631 |  0.008451521404508056 | 0.0202 |             8 |
| Eindhoven       | Netherlands        | Europe    |        841 |  3.143420682983631 |  0.011638396430423853 | 0.0202 |             9 |
| Prato           | Italy              | Europe    |        841 |  3.143420682983631 |   0.01365445462395852 | 0.0202 |            10 |
+-----------------+--------------------+-----------+------------+--------------------+-----------------------+--------+---------------+
20 rows in set (0.00 sec)
```

---
### Combined Pipeline
We can merge the steps into a single [pipeline](solution.sql). Even better, we can store it in a [procedure](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/Topics/05_Stored_Precesure/stored_procedure.sql). 

```sql
SET @sample_size = 10;

WITH 
city_group AS 
  (SELECT
    c.*
    ,COUNT(*) OVER (PARTITION BY continent) AS group_size
  FROM city_by_continent AS c)
,city_prob_assign AS 
  (SELECT
    c.*
    -- beaware expectation of sample size group_size * @sample_size / group_size AS mean = @sample_size
    ,SQRT(group_size * (@sample_size / group_size) * (1 - @sample_size / group_size)) AS std
    ,RAND() AS prob
  FROM city_group AS c)
,city_prob_cutoff AS 
  (SELECT
    c.*
    ,(@sample_size + CEIL(2 * std)) / group_size AS cutoff
  FROM city_prob_assign AS c)
-- filter by cuffoff
-- note that this step cannot be merged with previous
,city_sample AS 
  (SELECT 
    c.*
    -- window is evaluated after WHERE clause!
    -- ranking is cheap when performed on small group!
    ,RANK() OVER (PARTITION BY continent ORDER BY prob) AS group_row_num
  FROM city_prob_cutoff AS c
  WHERE prob < cutoff)
-- final, fixed size sample
SELECT * 
FROM city_sample
WHERE group_row_num <= @sample_size;
```
