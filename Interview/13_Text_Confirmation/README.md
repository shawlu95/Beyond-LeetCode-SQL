# Text Confirmation

> New users sign up with their emails for our service. Each sign up requires text confirmation to activate account. We have two tables: *Email* and *Text*. Answer the following question: (1) How many users signed up with their emails per day? (2) What proportion of people who signed up confirmed with SMS text message? (3) How many people did not confirm on the first day of sign up, but confirmed on the second day?

This exercise covers a typical interview problem. Two tables are presented, with three questions that progress in difficulty. As you will see, depending on the assumption, the answer can vary greatly. Communication is key. Do not make any assumption without confirmation.

___
### Load Data
Load the database file [db.sql](db.sql) to localhost MySQL. A Email database will be created with two tables. 
```
mysql < db.sql -uroot -p
```
```
SELECT * FROM email;
+---------------------+---------+---------------------+
| ts                  | user_id | email               |
+---------------------+---------+---------------------+
| 2019-03-13 00:00:00 | neo     | anderson@matrix.com |
| 2019-03-17 12:15:00 | Ross    | ross@126.com        |
| 2019-03-18 05:37:00 | ali     | ali@hotmail.com     |
| 2019-03-18 06:00:00 | shaw    | shawlu95@gmail.com  |
+---------------------+---------+---------------------+
4 rows in set (0.00 sec)
```

```
SELECT * FROM text;
+----+---------------------+---------+-----------+
| id | ts                  | user_id | action    |
+----+---------------------+---------+-----------+
|  1 | 2019-03-17 12:15:00 | Ross    | CONFIRMED |
|  2 | 2019-03-18 05:37:00 | Ali     | NULL      |
|  3 | 2019-03-18 14:00:00 | Ali     | CONFIRMED |
|  4 | 2019-03-18 06:00:00 | shaw    | NULL      |
|  5 | 2019-03-19 00:00:00 | shaw    | CONFIRMED |
+----+---------------------+---------+-----------+
5 rows in set (0.00 sec)

```

___
### Q1: Daily Signups 
This is a simple application of aggregate function. Note that the *DateTime* data type needs to be converted into *Date* before aggregation.
```
SELECT
  CAST(ts AS DATE) AS dt
  ,COUNT(*) AS signups
FROM Email
GROUP BY dt;

+------------+---------+
| dt         | signups |
+------------+---------+
| 2019-03-13 |       1 |
| 2019-03-17 |       1 |
| 2019-03-18 |       2 |
+------------+---------+
3 rows in set (0.00 sec)
```

### Q2: Confirmation Rate
The overall thought process is to take the latest action for each users (a user may fail to confirm many time, but confirmed in the last time). Left join the email table with the latest action, and see how many __NULL__ is in the right table.

__Aggregation__
```
SELECT user_id, ts, action
FROM text WHERE (user_id, ts) IN (
  SELECT user_id, MAX(ts) FROM text GROUP BY user_id
);

+---------+---------------------+-----------+
| user_id | ts                  | action    |
+---------+---------------------+-----------+
| Ross    | 2019-03-17 12:15:00 | CONFIRMED |
| Ali     | 2019-03-18 14:00:00 | CONFIRMED |
| shaw    | 2019-03-19 00:00:00 | CONFIRMED |
+---------+---------------------+-----------+
3 rows in set (0.01 sec)
```

__Left Join__
```
SELECT *
FROM Email AS e
LEFT JOIN (
  SELECT user_id, action
  FROM text WHERE (user_id, ts) IN (
    SELECT user_id, MAX(ts) FROM text GROUP BY user_id
  )
) AS c
ON e.user_id = c.user_id;

+---------------------+---------+---------------------+---------+-----------+
| ts                  | user_id | email               | user_id | action    |
+---------------------+---------+---------------------+---------+-----------+
| 2019-03-13 00:00:00 | neo     | anderson@matrix.com | NULL    | NULL      |
| 2019-03-17 12:15:00 | Ross    | ross@126.com        | Ross    | CONFIRMED |
| 2019-03-18 05:37:00 | ali     | ali@hotmail.com     | Ali     | CONFIRMED |
| 2019-03-18 06:00:00 | shaw    | shawlu95@gmail.com  | shaw    | CONFIRMED |
+---------------------+---------+---------------------+---------+-----------+
4 rows in set (0.00 sec)
```

__Calculate Confirmation Rate__
```
SELECT 
  ROUND(SUM(c.action IS NOT NULL) / COUNT(DISTINCT e.user_id), 2) AS rate
FROM Email AS e
LEFT JOIN (
  SELECT user_id, action
  FROM text WHERE (user_id, ts) IN (
    SELECT user_id, MAX(ts) FROM text GROUP BY user_id
  )
) AS c
ON e.user_id = c.user_id;

+------+
| rate |
+------+
| 0.75 |
+------+
1 row in set (0.00 sec)
```

Note that by inspection, the email column uniquely identifies user_id, since the same email cannot be registered by multiple user_id. So we know that every row in the *Email* table corresponds to a unique signup event. Counting the number of rows gives us the denominator.

Also note that each user can confirm text message __at most__ once, after which he will not attempt SMS text confirmation again. So by simply counting the occurence of "CONFIRMED" in the *Text* table, we get the number of confirmed users (the denominator).

Then we can calculate confirmation rate in one line. Make sure to double check the above assumptions before writing down the query.

```
SELECT ROUND((SELECT SUM(action = 'CONFIRMED') FROM text) / (SELECT COUNT(*) FROM Email), 2) AS rate;
+------+
| rate |
+------+
| 0.75 |
+------+
1 row in set (0.00 sec)
``` 

### Q3. Second-day Confirmation
To offset by one day, we can either hack the *JOIN* condition, or use *LAG()* function.

__Offset 1-day__
```
SELECT *
FROM Email AS e
LEFT JOIN Text AS t
ON e.user_id = t.user_id
  AND DATEDIFF(t.ts, e.ts) = 1;
+---------------------+---------+---------------------+------+---------------------+---------+-----------+
| ts                  | user_id | email               | id   | ts                  | user_id | action    |
+---------------------+---------+---------------------+------+---------------------+---------+-----------+
| 2019-03-18 06:00:00 | shaw    | shawlu95@gmail.com  |    5 | 2019-03-19 00:00:00 | shaw    | CONFIRMED |
| 2019-03-13 00:00:00 | neo     | anderson@matrix.com | NULL | NULL                | NULL    | NULL      |
| 2019-03-17 12:15:00 | Ross    | ross@126.com        | NULL | NULL                | NULL    | NULL      |
| 2019-03-18 05:37:00 | ali     | ali@hotmail.com     | NULL | NULL                | NULL    | NULL      |
+---------------------+---------+---------------------+------+---------------------+---------+-----------+
4 rows in set (0.00 sec)
```

__Extract Result__
```
SELECT
  e.user_id
FROM Email AS e
JOIN Text AS t
ON e.user_id = t.user_id
  AND DATEDIFF(t.ts, e.ts) = 1
WHERE t.action = 'CONFIRMED';
+---------+
| user_id |
+---------+
| shaw    |
+---------+
1 row in set (0.00 sec)
```


### Parting Thought
Window function is not convenient here, because each user can attempt text confirmation multiple times a day. To use *LEAD()* or *LAG()* function, we need to specify the fixed numebr of offset for all partitions. To do so we need to group by (date-user_id) key pair to extract one row per user per day in the text table... Already too complex! Forget about it...

Simply put, window function is good for studying the immediate next action. For example, we may use *LEAD()* to calculate how many hours elapse on average before user attempts a second confirmation.

```
SELECT
  user_id
  ,ts
  ,action
  ,LEAD(ts, 1) OVER (PARTITION BY user_id ORDER BY ts) AS next_ts
  ,LEAD(action, 1) OVER (PARTITION BY user_id ORDER BY ts) AS next_action
  ,TIMEDIFF(LEAD(ts, 1) OVER (PARTITION BY user_id ORDER BY ts), ts) AS time_diff
FROM Text

+---------+---------------------+-----------+---------------------+-------------+-----------+
| user_id | ts                  | action    | next_ts             | next_action | time_diff |
+---------+---------------------+-----------+---------------------+-------------+-----------+
| Ali     | 2019-03-18 05:37:00 | NULL      | 2019-03-18 14:00:00 | CONFIRMED   | 08:23:00  |
| Ali     | 2019-03-18 14:00:00 | CONFIRMED | NULL                | NULL        | NULL      |
| Ross    | 2019-03-17 12:15:00 | CONFIRMED | NULL                | NULL        | NULL      |
| shaw    | 2019-03-18 06:00:00 | NULL      | 2019-03-19 00:00:00 | CONFIRMED   | 18:00:00  |
| shaw    | 2019-03-19 00:00:00 | CONFIRMED | NULL                | NULL        | NULL      |
+---------+---------------------+-----------+---------------------+-------------+-----------+
5 rows in set (0.00 sec)
```

See solution [here](solution.sql).