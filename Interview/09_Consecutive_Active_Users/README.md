# Consecutive Active Users

> Given timestamps of logins, figure out how many people on Facebook were active ALL seven days of a week on a mobile phone.

Different from the monthly active user [problem](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/Interview/03_Monthly_Active_User), in which active user is defined by those who logged on __at least once__ in the past month, in this problem we define acive users as those who logged on in the past __7 consecutive days__. In this problem, we'll require only 3 days. The logic is the same.

### Key Concepts
* Self join.
* Window functions.

### Table
```
mysql> describe Login;
+---------+---------+------+-----+---------+----------------+
| Field   | Type    | Null | Key | Default | Extra          |
+---------+---------+------+-----+---------+----------------+
| id      | int(11) | NO   | PRI | NULL    | auto_increment |
| user_id | int(11) | YES  |     | NULL    |                |
| ts      | date    | YES  |     | NULL    |                |
+---------+---------+------+-----+---------+----------------+
3 rows in set (0.00 sec)

mysql> select * from Login;
+----+---------+------------+
| id | user_id | ts         |
+----+---------+------------+
|  1 |       1 | 2019-02-14 |
|  2 |       1 | 2019-02-13 |
|  3 |       1 | 2019-02-12 |
|  4 |       1 | 2019-02-11 |
|  5 |       2 | 2019-02-14 |
|  6 |       2 | 2019-02-12 |
|  7 |       2 | 2019-02-11 |
|  8 |       2 | 2019-02-10 |
|  9 |       3 | 2019-02-14 |
| 10 |       3 | 2019-02-12 |
| 11 |       4 | 2019-02-09 |
| 12 |       4 | 2019-02-08 |
| 13 |       4 | 2019-02-08 |
| 14 |       4 | 2019-02-07 |
+----+---------+------------+
14 rows in set (0.00 sec)
```

___
### Self-join Method
Directly joining tables against itself 7 times causes row number to explode. Since we are not differentiating same user's multiple logins in a day, we only need to keep one record for each user per day before joining the table. Because the *ts* column is *date* type, we only need a *DISTINCT* keyword to filter the duplicates. If the column is *datetime* type, we would need to transform it into *date* type first.

```sql
WITH tmp AS (
  SELECT DISTINCT user_id, ts FROM Login)
SELECT 
  *
FROM tmp AS d0
JOIN tmp AS d1
  ON d0.user_id = d1.user_id
  AND DATEDIFF(d0.ts, d1.ts) = 1
JOIN tmp AS d2
  ON d2.user_id = d1.user_id
  AND DATEDIFF(d0.ts, d2.ts) = 2;
  -- AND DATEDIFF(d1.ts, d2.ts) = 1 -- only need one of the condition, because we are using inner join (no NULL)
```
```
+---------+------------+---------+------------+---------+------------+
| user_id | ts         | user_id | ts         | user_id | ts         |
+---------+------------+---------+------------+---------+------------+
|       1 | 2019-02-14 |       1 | 2019-02-13 |       1 | 2019-02-12 |
|       1 | 2019-02-13 |       1 | 2019-02-12 |       1 | 2019-02-11 |
|       2 | 2019-02-12 |       2 | 2019-02-11 |       2 | 2019-02-10 |
|       4 | 2019-02-09 |       4 | 2019-02-08 |       4 | 2019-02-07 |
+---------+------------+---------+------------+---------+------------+
4 rows in set (0.00 sec)
```

Did you see any problem? The query returns all users who have __ever__ been active for 3 days in __all__ history. The question asks for users who have been active in the __most recent__ 3 days only. So we need to add condition on the *d0.ts* column. Preferably, we use pre-filter instead of post-filter. Only one user satisfies out conditions. 

```sql
@now = '2019-02-04';
WITH tmp AS (
  SELECT DISTINCT user_id, ts FROM Login)
SELECT *
FROM tmp AS d0
JOIN tmp AS d1
  ON d0.ts = @now
  AND d0.user_id = d1.user_id
  AND DATEDIFF(d0.ts, d1.ts) = 1
JOIN tmp AS d2
  ON d2.user_id = d1.user_id
  AND DATEDIFF(d0.ts, d2.ts) = 2;
```
```
+---------+------------+---------+------------+---------+------------+
| user_id | ts         | user_id | ts         | user_id | ts         |
+---------+------------+---------+------------+---------+------------+
|       1 | 2019-02-14 |       1 | 2019-02-13 |       1 | 2019-02-12 |
+---------+------------+---------+------------+---------+------------+
1 row in set (0.00 sec)
```

Equivalently, we can pre-filter the source table into several sub-tables before joining them. This solution also works for *datetime* data type.

```sql
SET @now = "2019-02-14";
WITH tmp AS (
  SELECT DISTINCT user_id, ts FROM Login)
SELECT *
FROM tmp AS d0
JOIN tmp AS d1
  ON d0.ts = @now
  AND DATEDIFF(@now, d1.ts) = 1
  AND d0.user_id = d1.user_id
JOIN tmp AS d2
  ON DATEDIFF(@now, d2.ts) = 2
  AND d2.user_id = d1.user_id;
```
```
+----+---------+------------+----+---------+------------+----+---------+------------+
| id | user_id | ts         | id | user_id | ts         | id | user_id | ts         |
+----+---------+------------+----+---------+------------+----+---------+------------+
|  1 |       1 | 2019-02-14 |  2 |       1 | 2019-02-13 |  3 |       1 | 2019-02-12 |
+----+---------+------------+----+---------+------------+----+---------+------------+
1 row in set (0.00 sec)
```

Note that by using inner join, we are incrementally filtering out users who are not active in a day. This is okay because we only need user_id. If we were to calculate the proportion of active user, we need to do __full join__ (left join is not sufficient). The total number of rows returned by the full join is the number of users who have been active in at least one of the past 3 days.

---
### Window Method
The window function takes a different mental twist. Instead of finding customers who are active on day 0, day 1, ... day N. We are asking the following question:
* Q1: How many days ago was the last log in (earlier than today)?
* Q2: How many days ago was the second last log in (earlier than the last log in)?
* ...

If the answer to Q1 is 1, answer to Q2 is 2, then the customer is active in the most recent 3 days.

Note that for this logic to work, we must have __one__ record per day for each customers. If we have multiple records per day, *LAG* function will return 0 for those duplicates.

```sql
SET @now = "2019-02-14";
SELECT
  user_id
  ,DATEDIFF(@now, LAG(ts, 1) OVER w) AS day_from_pre1
  ,DATEDIFF(@now, LAG(ts, 2) OVER w) AS day_from_pre2
FROM Login
WINDOW w AS (PARTITION BY user_id ORDER BY ts);
```
```
+---------+---------------+---------------+
| user_id | day_from_pre1 | day_from_pre2 |
+---------+---------------+---------------+
|       1 |          NULL |          NULL |
|       1 |             3 |          NULL |
|       1 |             2 |             3 |
|       1 |             1 |             2 |
|       2 |          NULL |          NULL |
|       2 |             4 |          NULL |
|       2 |             3 |             4 |
|       2 |             2 |             3 |
|       3 |          NULL |          NULL |
|       3 |             2 |          NULL |
|       4 |          NULL |          NULL |
|       4 |             7 |          NULL |
|       4 |             6 |             7 |
|       4 |             6 |             6 |
+---------+---------------+---------------+
14 rows in set (0.00 sec)
```

__Warning__: because *WHERE* is evaluated before window function, the following table returns returns nothing in the window functions.

> Window functions are permitted only in the SELECT list and the ORDER BY clause of the query. They are forbidden elsewhere, such as in GROUP BY, HAVING and WHERE clauses. This is because they logically execute after the processing of those clauses. Also, window functions execute after regular aggregate functions.

```sql
SET @now = "2019-02-14";
SELECT
  user_id
  ,ts
  ,DATEDIFF(@now, LAG(ts, 1) OVER (PARTITION BY user_id ORDER BY ts)) AS day_from_pre1
  ,DATEDIFF(@now, LAG(ts, 2) OVER (PARTITION BY user_id ORDER BY ts)) AS day_from_pre2
FROM Login
WHERE ts = @now;
```
```
+---------+------------+---------------+---------------+
| user_id | ts         | day_from_pre1 | day_from_pre2 |
+---------+------------+---------------+---------------+
|       1 | 2019-02-14 |          NULL |          NULL |
|       2 | 2019-02-14 |          NULL |          NULL |
|       3 | 2019-02-14 |          NULL |          NULL |
+---------+------------+---------------+---------------+
3 rows in set (0.00 sec)
```

__Warning__: if you're using *WHERE* clause to filter results, you __cannot__ window alias.
```
SET @now = "2019-02-14";
SELECT
  user_id
  ,ts
  ,DATEDIFF(@now, LAG(ts, 1) OVER w) AS day_from_pre1
  ,DATEDIFF(@now, LAG(ts, 2) OVER w) AS day_from_pre2
FROM Login
WINDOW w AS (PARTITION BY user_id ORDER BY ts)
WHERE ts = @now;

ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'WHERE ts = @now' at line 8
```

__Warning__: similarly, you cannot use window function in *WHERE* clause. Instead, place it in a temporary table.
```
SET @now = "2019-02-14";
SELECT
  user_id
  ,ts
FROM Login
WHERE DATEDIFF(@now, LAG(ts, 1) OVER (PARTITION BY user_id ORDER BY ts)) AS day_from_pre1 = 1
  AND DATEDIFF(@now, LAG(ts, 2) OVER (PARTITION BY user_id ORDER BY ts)) AS day_from_pre2 = 2
  AND ts = @now;

ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'AS day_from_pre1 = 1

```

The correct implementation.
```sql
SET @now = "2019-02-14";
WITH tmp AS (
SELECT
  user_id
  ,ts
  ,DATEDIFF(@now, LAG(ts, 1) OVER w) AS day_from_pre1
  ,DATEDIFF(@now, LAG(ts, 2) OVER w) AS day_from_pre2
FROM Login
WINDOW w AS (PARTITION BY user_id ORDER BY ts)
)
SELECT user_id
FROM tmp
WHERE ts = @now
  AND day_from_pre1 = 1
  AND day_from_pre2 = 2;
```
```
+---------+
| user_id |
+---------+
|       1 |
+---------+
1 row in set (0.00 sec)
```

---
### Generalize to 7 Days
```sql
SET @now = "2019-02-14";
WITH tmp AS (
  SELECT DISTINCT user_id, ts FROM Login)
SELECT *
FROM tmp AS d0
JOIN tmp AS d1
  ON d0.ts = @now
  AND DATEDIFF(@now, d1.ts) = 1
  AND d0.user_id = d1.user_id
JOIN tmp AS d2
  ON DATEDIFF(@now, d2.ts) = 2
  AND d0.user_id = d2.user_id
JOIN tmp AS d3
  ON DATEDIFF(@now, d3.ts) = 3
  AND d0.user_id = d3.user_id
JOIN tmp AS d4
  ON DATEDIFF(@now, d4.ts) = 4
  AND d0.user_id = d4.user_id
JOIN tmp AS d5
  ON DATEDIFF(@now, d5.ts) = 5
  AND d0.user_id = d5.user_id
JOIN tmp AS d6
  ON DATEDIFF(@now, d6.ts) = 6
  AND d0.user_id = d6.user_id
JOIN tmp AS d7
  ON DATEDIFF(@now, d7.ts) = 7
  AND d0.user_id = d7.user_id;
```

```sql
SET @now = "2019-02-14";
WITH tmp AS (
SELECT
  user_id
  ,DATEDIFF(@now, LAG(ts, 1) OVER w) AS day_from_pre1
  ,DATEDIFF(@now, LAG(ts, 2) OVER w) AS day_from_pre2
  ,DATEDIFF(@now, LAG(ts, 3) OVER w) AS day_from_pre3
  ,DATEDIFF(@now, LAG(ts, 4) OVER w) AS day_from_pre4
  ,DATEDIFF(@now, LAG(ts, 5) OVER w) AS day_from_pre5
  ,DATEDIFF(@now, LAG(ts, 6) OVER w) AS day_from_pre6
  ,DATEDIFF(@now, LAG(ts, 7) OVER w) AS day_from_pre7
FROM Login
WINDOW w AS (PARTITION BY user_id ORDER BY ts)
)
SELECT user_id
FROM tmp
WHERE ts=@now
  AND day_from_pre1 = 1
  AND day_from_pre2 = 2
  AND day_from_pre3 = 3
  AND day_from_pre4 = 4
  AND day_from_pre5 = 5
  AND day_from_pre6 = 6
  AND day_from_pre7 = 7;
```

See full solution [here](solution.sql)