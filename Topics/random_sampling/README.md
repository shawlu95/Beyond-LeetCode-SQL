# Sampling Technique

### Anti-pattern
One common pitfall of sampling is to assign a random number to each row, order all rows, and return the top few rows. This is very inefficient, as ordering takes O(nlogn) time and incurs IO cost when table is large. 
```
-- anti-pattern
SELECT TOP 1 PERCENT Number
FROM Numbers
ORDER BY newid()
```

### Trivial Solution
MS SQL has *TABLESAMPLE* method avaialble, which returns any desired number of rows, as a percentage of the entire table.
```
-- MS SQL
SELECT * from [TABLE] tablesample(1 PERCENT)
```

### The *Interview* Solution
This notebook introduces a different technique that addresses the question: "sample N rows from each group." Specifically, we use the world (database)[databases/world_db], and randomly draw 10 cities from each continent.

The objective is to sample without sorting random number. First we need to assign a random number to each row, and then determine a cutoff threshold for each group. Finally, return rows below the cutoff threshold. To ensure that each group has at least the desired number of samples, we need to relax the threshold a little. 

We can model the selection as a Binomial process, we can get the parameter *p*, which is simple the sample_size / group_size. From *p* we can calculate the standard deviation, and adjust the threshold probability to include more rows wuch that the probability of drawing fewer than desired sample size is small.

First, import the [database](../databases/world_db/) in terminal.
```
mysql < world.sql -uroot -p
```

Create the table we will be sampling from. To have continent and city columns in the same table, we need to join two tables in the world database.
```
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

What does this mean? Take Ocenia for example, it means that if we draw from __every one__ of its cities with Binomial probability 0.1818, we get 10 successes on average, with 2.86 standard deviation. 
```
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

Since we need at least 10 samples from each group, we can relax the *p* threshold a little. For example, we can add 2 * std to the desired sample size. 

```

DROP TABLE IF EXISTS city_group;
CREATE TEMPORARY TABLE city_group AS 
SELECT
  c.*
  ,COUNT(*) OVER (PARTITION BY continent) AS group_size
FROM city_by_continent AS c;

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
```
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

Calculate the cut-off threshold, adjusted for 2 * standard deviations.
```
DROP TABLE IF EXISTS city_prob_cutoff;
CREATE TEMPORARY TABLE city_prob_cutoff AS 
SELECT
  c.*
  ,(@sample_size + CEIL(2 * std)) / group_size AS cutoff
FROM city_prob_assign AS c;

SELECT * FROM  city_prob_cutoff LIMIT 5;
```

Finally, filter the results by cutoff threshold. Notice we are ranking random number here. But because window function is evaluated after *WHERE* clause, we are only ranking a few rows in each group.
```
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

Check that sample size are at least 10!
```
-- check sample size
SELECT continent, COUNT(*) AS sample_size 
FROM city_prob_cutoff
WHERE prob < cutoff
GROUP BY continent;

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
```
-- draw fixed sample size
SELECT * 
FROM city_sample
WHERE group_row_num <= 10
LIMIT 20;

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

### Combined Pipeline
We can merge the steps into a single pipeline. Even better, we can store it in a [procedure](stored_procedure.sql). Then we can simly sample any desired number of rows we want. For example, to draw 3 cities from each continent, we can simply call the procedure as follows:

```
mysql> CALL sample_by_continent(3);

+--------------+---------------------------+---------------+------------+--------------------+-----------------------+--------+---------------+
| city_name    | country_name              | continent     | group_size | std                | prob                  | cutoff | group_row_num |
+--------------+---------------------------+---------------+------------+--------------------+-----------------------+--------+---------------+
| Nazilli      | Turkey                    | Asia          |       1766 | 1.7305788923769574 |    0.7224973214068425 | 0.0040 |             1 |
| Semnan       | Iran                      | Asia          |       1766 | 1.7305788923769574 |    0.7094183831563391 | 0.0040 |             2 |
| Yuci         | China                     | Asia          |       1766 | 1.7305788923769574 |    0.3795999822948128 | 0.0040 |             3 |
| Manchester   | United Kingdom            | Europe        |        841 | 1.7289585538059709 |    0.7099240475426652 | 0.0083 |             1 |
| Vitebsk      | Belarus                   | Europe        |        841 | 1.7289585538059709 |   0.24038589023089585 | 0.0083 |             2 |
| Arzamas      | Russian Federation        | Europe        |        841 | 1.7289585538059709 |   0.07215733926012864 | 0.0083 |             3 |
| Saint-Pierre | Saint Pierre and Miquelon | North America |        581 | 1.7275732570756073 |    0.9816732946612623 | 0.0120 |             1 |
| Compton      | United States             | North America |        581 | 1.7275732570756073 |    0.9894793350151547 | 0.0120 |             2 |
| Grand Rapids | United States             | North America |        581 | 1.7275732570756073 | 0.0023768218256317282 | 0.0120 |             3 |
| al-Qadarif   | Sudan                     | Africa        |        366 | 1.7249376000117878 |    0.6935911212988115 | 0.0191 |             1 |
| Daloa        | Côte d’Ivoire             | Africa        |        366 | 1.7249376000117878 |   0.06386513827728586 | 0.0191 |             2 |
| Abidjan      | Côte d’Ivoire             | Africa        |        366 | 1.7249376000117878 |   0.23855235822363977 | 0.0191 |             3 |
| Adamstown    | Pitcairn                  | Oceania       |         55 |  1.684150708706428 |    0.2901749911626568 | 0.1273 |             1 |
| Yangor       | Nauru                     | Oceania       |         55 |  1.684150708706428 |   0.44737576548697033 | 0.1273 |             2 |
| Cairns       | Australia                 | Oceania       |         55 |  1.684150708706428 |    0.3663538846805262 | 0.1273 |             3 |
| Maracaíbo    | Venezuela                 | South America |        470 | 1.7265140393782532 |    0.8527891355126995 | 0.0149 |             1 |
| Guacara      | Venezuela                 | South America |        470 | 1.7265140393782532 |    0.2539973559360927 | 0.0149 |             2 |
| Corrientes   | Argentina                 | South America |        470 | 1.7265140393782532 |    0.7116194038760097 | 0.0149 |             3 |
+--------------+---------------------------+---------------+------------+--------------------+-----------------------+--------+---------------+
18 rows in set (0.01 sec)

Query OK, 0 rows affected (0.01 sec)
```


