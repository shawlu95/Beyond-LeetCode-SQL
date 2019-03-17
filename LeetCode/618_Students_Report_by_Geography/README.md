# Students Report By Geography

A U.S graduate school has students from Asia, Europe and America. The students' location information are stored in table student as below.
 
```
| name   | continent |
|--------|-----------|
| Jack   | America   |
| Pascal | Europe    |
| Xi     | Asia      |
| Jane   | America   |
 ```

Pivot the continent column in this table so that each name is sorted alphabetically and displayed underneath its corresponding continent. The output headers should be America, Asia and Europe respectively. It is guaranteed that the student number from America is no less than either Asia or Europe.
 

For the sample input, the output is:
 
```
| America | Asia | Europe |
|---------|------|--------|
| Jack    | Xi   | Pascal |
| Jane    |      |        |
 ```

Follow-up: If it is unknown which continent has the most students, can you write a query to generate the student report?


## Solution
This is an exercise of pivoting table, though not a very good one. For more representative pivoting exercise, check this (link)[google.com]. The challenging part in this exercise is that the data are text, and cannot be aggregated over in the pivoted table. So you must assign it a proxy index, and join each column. 

Using session variable can solve the problem, but it is very error prone (see [here](mysql_session_vars.sql)). In this document, I present a solution utilizing *ROW_NUMBER* window function (available in MS SQL and MySQL8) and full join (not available in MySQL8). So this solution does not work in MySQL server.


#### Step 1. Build Temporary Tables
```
mysql> SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'America';
+----+------+
| ID | name |
+----+------+
|  1 | Jack |
|  2 | Jane |
+----+------+
2 rows in set (0.01 sec)

mysql> SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'Asia';
+----+------+
| ID | name |
+----+------+
|  1 | Xi   |
+----+------+
1 row in set (0.00 sec)

mysql> SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'Europe';
+----+--------+
| ID | name   |
+----+--------+
|  1 | Pascal |
+----+--------+
1 row in set (0.00 sec)
```

#### Step 2. Full Join
In MS SQL, use *FULL JOIN* to combine the three temporary tables, in any order. Note that when joining the third table, the *JOIN* condition could match to either the first table or the second table.

```
-- MS SQL
SELECT
  a.name AS America
  ,b.name AS Asia
  ,c.name AS Europe
FROM
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'America') a
FULL JOIN
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'Asia') b
ON a.ID = b.ID
FULL JOIN
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'Europe') c
ON c.ID = b.ID
OR c.ID = a.ID;
```

In a different order: we don't have to know in advance which group has most students.
```
-- MS SQL
SELECT
  a.name AS America
  ,b.name AS Asia
  ,c.name AS Europe
FROM
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'Europe') c
FULL JOIN
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'Asia') b
ON b.ID = c.ID
FULL JOIN
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'America') a
ON a.ID = b.ID
OR a.ID = c.ID;
```
