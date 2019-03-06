# Human Traffic of Stadium

## Description
X city built a new stadium, each day many people visit it and the stats are saved as these columns: id, visit_date, people

Please write a query to display the records which have 3 or more consecutive rows and the amount of people more than 100(inclusive).

Load the database file [db.sql](db.sql) to localhost MySQL. Relevant tables will be created in the LeetCode database. 
```
mysql < db.sql -uroot -p
```

For example, the table stadium:
```
+------+------------+-----------+
| id   | visit_date | people    |
+------+------------+-----------+
| 1    | 2017-01-01 | 10        |
| 2    | 2017-01-02 | 109       |
| 3    | 2017-01-03 | 150       |
| 4    | 2017-01-04 | 99        |
| 5    | 2017-01-05 | 145       |
| 6    | 2017-01-06 | 1455      |
| 7    | 2017-01-07 | 199       |
| 8    | 2017-01-08 | 188       |
+------+------------+-----------+
```
For the sample data above, the output is:
```
+------+------------+-----------+
| id   | visit_date | people    |
+------+------------+-----------+
| 5    | 2017-01-05 | 145       |
| 6    | 2017-01-06 | 1455      |
| 7    | 2017-01-07 | 199       |
| 8    | 2017-01-08 | 188       |
+------+------------+-----------+
```
Note:
Each day only have one row record, and the dates are increasing with id increasing.

## Observation
Make the following observation to interviewers. Confirm your observation is correct. Ask for clarification if necessary.
* Every day has a record. If two dates differs by 1, their id differs by 1. Therefore, instead of joining by *visit_date* we can join by *id*, which is more efficient.
* We are scanning three-day consecutive window here. A valid row can either be positioned at the beginning of the window, at the middle, or end of the window.

## On Correctness
The key is to remove duplicates. Consider four days in a row, each day with over 100 people. In the first window, all three days will be returned. In the next window, day 2, 3, 4 will all be returned, resulting in duplicate day 2 and 3. To remove duplicate, use *DISTINCT* keyword, with three [self-joins]( mysql_simple.sql):.

| window 1 | window 2 | 
|----|-----------|
| day 1|           |
| day 2| day 2 |
| day 3| day 3 |
|          | day 4 |

```
-- MySQL solution
SELECT DISTINCT 
  s1.* 
FROM
  stadium AS s1
  ,stadium AS s2
  ,stadium AS s3
WHERE s1.people >= 100 
  AND s2.people >= 100 
  AND s3.people >= 100 
  AND ((s1.id = s2.id - 1 AND s1.id = s3.id - 2) -- start of window
    OR (s1.id = s2.id + 1 AND s1.id = s3.id - 1) -- middle of window
    OR (s1.id = s2.id + 2 AND s1.id = s3.id + 1)) -- end of window
ORDER BY s1.id; 
```


## On Efficiency
Joining the table three times resulting in a huge cartesian product. One way to improve efficiency is simply [pre-filter](mssql_pre_filter.sql) the table, so only days with over 100 people are joined. 

```
-- MySQL: pre-filtering
SELECT DISTINCT 
  s1.* 
FROM
  (SELECT * FROM stadium WHERE people >= 100) AS s1
  ,(SELECT * FROM stadium WHERE people >= 100) AS s2
  ,(SELECT * FROM stadium WHERE people >= 100) AS s3
WHERE (s1.id = s2.id - 1 AND s1.id = s3.id - 2) 
  OR (s1.id = s2.id + 1 AND s1.id = s3.id - 1) 
  OR (s1.id = s2.id + 2 AND s1.id = s3.id + 1)
ORDER BY s1.id;
```

If using MS SQL, we only need to define the temporary table once, making it much easier to maintain.

```
-- MS SQL: cleaner code
WITH good_day AS (
  SELECT * FROM stadium WHERE people >= 100
)
SELECT DISTINCT s1.* FROM
good_day AS s1,
good_day AS s2,
good_day AS s3
WHERE (s1.id = s2.id - 1 AND s1.id = s3.id - 2) 
  OR (s1.id = s2.id + 1 AND s1.id = s3.id - 1) 
  OR (s1.id = s2.id + 2 AND s1.id = s3.id + 1)
ORDER BY s1.id;
```

Using either MySQL or MS SQL, we can do away with temporary table, by merging predicates into the JOIN clause. This small change achieves the same filtering effect.

```
SELECT DISTINCT s1.* 
FROM stadium AS s1
LEFT JOIN stadium AS s2
  ON s1.people >= 100
  AND s2.people >= 100
LEFT JOIN stadium AS s3
  ON s3.people >= 100
WHERE (s1.id = s2.id - 1 AND s1.id = s3.id - 2) 
  OR (s1.id = s2.id + 1 AND s1.id = s3.id - 1) 
  OR (s1.id = s2.id + 2 AND s1.id = s3.id + 1)
ORDER BY s1.id;
```

## Window function
In MS SQL, the problem can be solved with [window function](mssql_window.sql). Be careful that you __cannot__ use window column in the predicates. You must save the expanded table with window columns in a temporary table.

```
-- MS SQL: window
WITH long_table AS (
SELECT
  *
  ,LAG(people, 2) OVER (ORDER BY id ASC) AS pre2
  ,LAG(people, 1) OVER (ORDER BY id ASC) AS pre1
  ,LEAD(people, 1) OVER (ORDER BY id ASC) AS nxt1
  ,LEAD(people, 2) OVER (ORDER BY id ASC) AS nxt2
FROM stadium
)
SELECT
  id
  ,visit_date
  ,people
FROM long_table
WHERE people >= 100
  AND ((pre2 >= 100 AND pre1 >= 100) 
  OR (pre1 >= 100 AND nxt1 >= 100) 
  OR (nxt1 >= 100 AND nxt2 >= 100))
ORDER BY id;
```

For the sake of completion, MySQL8 supports window function too, and can be written with window alias.

```
-- MySQL 8 equivalent
WITH long_table AS (
SELECT
  *
  ,LAG(people, 2) OVER w AS pre2
  ,LAG(people, 1) OVER w AS pre1
  ,LEAD(people, 1) OVER w AS nxt1
  ,LEAD(people, 2) OVER w AS nxt2
FROM stadium
WINDOW w AS (ORDER BY id ASC)
)
SELECT
  id
  ,visit_date
  ,people
FROM long_table
WHERE people >= 100
  AND ((pre2 >= 100 AND pre1 >= 100) 
  OR (pre1 >= 100 AND nxt1 >= 100) 
  OR (nxt1 >= 100 AND nxt2 >= 100))
ORDER BY id;
```

## Parting Thought
Window function is more efficient than join when the table is large. In this example, we are sorting by index *id* in the window, further boosting efficiency. Furthermore, window solution gets rid of the *DISTINCT* keyword, which establishes a hash set (inefficient). The test case in LeetCode, however, does not show its superiority.

