# Pivoting Text Data

Different from the *Expenses* table from the earlier [note](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/Interview/05_Pivoting_Numeric_Data), this table contains text data, and cannot be summed or averaged over. A different approach is required tp reduce number of tables. Still, just as in pivoting numeric data, we need to go through two steps.

1. Adding columns using self-join or switch statement. We'll study both approaches in this notebook.
2. Reduce number of rows to the cardinality of *index* column.

Load the database file [db.sql](db.sql) to localhost MySQL. The *CourseGrade* table will be created in the Practice database. The table *CourseGrade* contains letter grade of five students on three courses. It has exactly |pivot column| * |index column| = 3 * 5 = 15 rows, and the info column, *grade* cannot be summed as we did before with numeric data.


```
mysql < db.sql -uroot -p
```

Different from the [LeetCode](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/LeetCode/618_Students_Report_by_Geography) problem, here we do have an *index* column *name* which determines the row number for the info column *grade*. So we do not have to reindex the table using *ROW_NUMBER()*.

```
mysql> select * from coursegrade;
+---------+--------+-------+
| name    | course | grade |
+---------+--------+-------+
| Alice   | CS106B | A     |
| Alice   | CS229  | A     |
| Alice   | CS224N | B     |
| Bob     | CS106B | C     |
| Bob     | CS229  | F     |
| Bob     | CS224N | F     |
| Charlie | CS106B | B     |
| Charlie | CS229  | B     |
| Charlie | CS224N | A     |
| David   | CS106B | C     |
| David   | CS229  | C     |
| David   | CS224N | D     |
| Elsa    | CS106B | B     |
| Elsa    | CS229  | B     |
| Elsa    | CS224N | A     |
+---------+--------+-------+
15 rows in set (0.00 sec)
```

---
### Pivot Using Self-join

Let's look at a subset of the data.
```
SELECT * FROM CourseGrade WHERE name IN ('Alice', 'Bob')
+-------+--------+-------+
| name  | course | grade |
+-------+--------+-------+
| Alice | CS106B | A     |
| Alice | CS229  | A     |
| Alice | CS224N | B     |
| Bob   | CS106B | C     |
| Bob   | CS229  | F     |
| Bob   | CS224N | F     |
+-------+--------+-------+
6 rows in set (0.00 sec)
```

Unconditional cross join produces 6 * 6 = 36 rows. Self-joining the table using the name results in 3 courses * 3 courses = 9 rows for each student. For each student, every class is matched to three other classes. 

```
WITH tmp AS (
SELECT * FROM CourseGrade WHERE name IN ('Alice', 'Bob')
)
SELECT
  *
FROM tmp AS t1, tmp AS t2
WHERE t1.name = t2.name;

+-------+--------+-------+-------+--------+-------+
| name  | course | grade | name  | course | grade |
+-------+--------+-------+-------+--------+-------+
| Alice | CS106B | A     | Alice | CS106B | A     |
| Alice | CS106B | A     | Alice | CS229  | A     |
| Alice | CS106B | A     | Alice | CS224N | B     |
| Alice | CS229  | A     | Alice | CS106B | A     |
| Alice | CS229  | A     | Alice | CS229  | A     |
| Alice | CS229  | A     | Alice | CS224N | B     |
| Alice | CS224N | B     | Alice | CS106B | A     |
| Alice | CS224N | B     | Alice | CS229  | A     |
| Alice | CS224N | B     | Alice | CS224N | B     |
| Bob   | CS106B | C     | Bob   | CS106B | C     |
| Bob   | CS106B | C     | Bob   | CS229  | F     |
| Bob   | CS106B | C     | Bob   | CS224N | F     |
| Bob   | CS229  | F     | Bob   | CS106B | C     |
| Bob   | CS229  | F     | Bob   | CS229  | F     |
| Bob   | CS229  | F     | Bob   | CS224N | F     |
| Bob   | CS224N | F     | Bob   | CS106B | C     |
| Bob   | CS224N | F     | Bob   | CS229  | F     |
| Bob   | CS224N | F     | Bob   | CS224N | F     |
+-------+--------+-------+-------+--------+-------+
18 rows in set (0.00 sec)
*/
```
For each student, we want one column for each course, so we can directly filter on the course name. Filtering one table's course name reduces the number of rows by a factor of 3. Filtering both tables reduces by a factor of 3 * 3.

```
WITH tmp AS (
SELECT * FROM CourseGrade WHERE name IN ('Alice', 'Bob')
)
SELECT
  *
FROM tmp AS t1, tmp AS t2
WHERE t1.name = t2.name
  AND t1.course = 'CS106B';

 +-------+--------+-------+-------+--------+-------+
| name  | course | grade | name  | course | grade |
+-------+--------+-------+-------+--------+-------+
| Alice | CS106B | A     | Alice | CS106B | A     |
| Alice | CS106B | A     | Alice | CS229  | A     |
| Alice | CS106B | A     | Alice | CS224N | B     |
| Bob   | CS106B | C     | Bob   | CS106B | C     |
| Bob   | CS106B | C     | Bob   | CS229  | F     |
| Bob   | CS106B | C     | Bob   | CS224N | F     |
+-------+--------+-------+-------+--------+-------+
6 rows in set (0.00 sec)

WITH tmp AS (
SELECT * FROM CourseGrade WHERE name IN ('Alice', 'Bob')
)
SELECT
  *
FROM tmp AS t1, tmp AS t2
WHERE t1.name = t2.name
  AND t1.course = 'CS106B'
  AND t2.course = 'CS229'
;

+-------+--------+-------+-------+--------+-------+
| name  | course | grade | name  | course | grade |
+-------+--------+-------+-------+--------+-------+
| Alice | CS106B | A     | Alice | CS229  | A     |
| Bob   | CS106B | C     | Bob   | CS229  | F     |
+-------+--------+-------+-------+--------+-------+
2 rows in set (0.00 sec)
```

We can easily generalize to three tables, and possibly more.
```
WITH tmp AS (
SELECT * FROM CourseGrade WHERE name IN ('Alice', 'Bob')
)
SELECT
  *
FROM tmp AS t1, tmp AS t2, tmp AS t3
WHERE t1.name = t2.name
  AND t2.name = t3.name
  AND t1.course = 'CS106B'
  AND t2.course = 'CS229'
  AND t3.course = 'CS224N';

 +-------+--------+-------+-------+--------+-------+-------+--------+-------+
| name  | course | grade | name  | course | grade | name  | course | grade |
+-------+--------+-------+-------+--------+-------+-------+--------+-------+
| Alice | CS106B | A     | Alice | CS229  | A     | Alice | CS224N | B     |
| Bob   | CS106B | C     | Bob   | CS229  | F     | Bob   | CS224N | F     |
+-------+--------+-------+-------+--------+-------+-------+--------+-------+
2 rows in set (0.00 sec)
```

Notice that by setting the filtering criteria, we are setting the __value__ of the additional columns! To make it clearer, simply rename the column title with the course title, and get rid of the *course* column, since it's redundant.

```
WITH tmp AS (
SELECT * FROM CourseGrade WHERE name IN ('Alice', 'Bob')
)
SELECT
  t1.name
  ,t1.grade AS 'CS106B'
  ,t2.grade AS 'CS229'
  ,t3.grade AS 'CS224N'
FROM tmp AS t1, tmp AS t2, tmp AS t3
WHERE t1.name = t2.name
  AND t2.name = t3.name
  AND t1.course = 'CS106B'
  AND t2.course = 'CS229'
  AND t3.course = 'CS224N';

 +-------+--------+-------+--------+
| name  | CS106B | CS229 | CS224N |
+-------+--------+-------+--------+
| Alice | A      | A     | B      |
| Bob   | C      | F     | F      |
+-------+--------+-------+--------+
2 rows in set (0.00 sec)
 ```

Now we can remove the temporary table and pivot the entire table.
 ```
SELECT
  t1.name
  ,t1.grade AS 'CS106B'
  ,t2.grade AS 'CS229'
  ,t3.grade AS 'CS224N'
FROM CourseGrade AS t1, CourseGrade AS t2, CourseGrade AS t3
WHERE t1.name = t2.name
  AND t2.name = t3.name
  AND t1.course = 'CS106B'
  AND t2.course = 'CS229'
  AND t3.course = 'CS224N';

+---------+--------+-------+--------+
| name    | CS106B | CS229 | CS224N |
+---------+--------+-------+--------+
| Alice   | A      | A     | B      |
| Bob     | C      | F     | F      |
| Charlie | B      | B     | A      |
| David   | C      | C     | D      |
| Elsa    | B      | B     | A      |
+---------+--------+-------+--------+
5 rows in set (0.00 sec)
```

To boost efficiency, we may replace cross join with inner join, and pre-filter on the course title before join.
```
SELECT
  t1.name
  ,t1.grade AS 'CS106B'
  ,t2.grade AS 'CS229'
  ,t3.grade AS 'CS224N'
FROM CourseGrade AS t1
JOIN CourseGrade AS t2
  ON t1.course = 'CS106B'
 AND t2.course = 'CS229'
 AND t1.name = t2.name
JOIN CourseGrade AS t3
  ON t3.course = 'CS224N'
 AND t2.name = t3.name;

+---------+--------+-------+--------+
| name    | CS106B | CS229 | CS224N |
+---------+--------+-------+--------+
| Alice   | A      | A     | B      |
| Bob     | C      | F     | F      |
| Charlie | B      | B     | A      |
| David   | C      | C     | D      |
| Elsa    | B      | B     | A      |
+---------+--------+-------+--------+
5 rows in set (0.00 sec)
 ```

---
### Bonus: Using Case Statement
We can use the case statement, as described in the previous [note](../05_Pivoting_Numeric_Data/). First, we add columns, using one case statement for each column.

```
SELECT
  *
  ,CASE WHEN course = 'CS106B' THEN grade ELSE NULL END AS 'CS106B'
  ,CASE WHEN course = 'CS229' THEN grade ELSE NULL END AS 'CS229'
  ,CASE WHEN course = 'CS224N' THEN grade ELSE NULL END AS 'CS224N'
FROM CourseGrade;

+---------+--------+-------+--------+-------+--------+
| name    | course | grade | CS106B | CS229 | CS224N |
+---------+--------+-------+--------+-------+--------+
| Alice   | CS106B | A     | A      | NULL  | NULL   |
| Alice   | CS229  | A     | NULL   | A     | NULL   |
| Alice   | CS224N | B     | NULL   | NULL  | B      |
| Bob     | CS106B | C     | C      | NULL  | NULL   |
| Bob     | CS229  | F     | NULL   | F     | NULL   |
| Bob     | CS224N | F     | NULL   | NULL  | F      |
| Charlie | CS106B | B     | B      | NULL  | NULL   |
| Charlie | CS229  | B     | NULL   | B     | NULL   |
| Charlie | CS224N | A     | NULL   | NULL  | A      |
| David   | CS106B | C     | C      | NULL  | NULL   |
| David   | CS229  | C     | NULL   | C     | NULL   |
| David   | CS224N | D     | NULL   | NULL  | D      |
| Elsa    | CS106B | B     | B      | NULL  | NULL   |
| Elsa    | CS229  | B     | NULL   | B     | NULL   |
| Elsa    | CS224N | A     | NULL   | NULL  | A      |
+---------+--------+-------+--------+-------+--------+
15 rows in set (0.00 sec)
```

Next, we reduce the numebr of rows to the cardinality of index column, using aggregate function. The redundant column *course* is dropped out. Since each group only contains one valid cell that is not NULL, using either *MAX()* or *MIN()* gives the same result. Just don't use *AVG()*, *SUM()* or *COUNT()*.

```
SELECT
  name
  ,MAX(CASE WHEN course = 'CS106B' THEN grade ELSE NULL END) AS 'CS106B'
  ,MAX(CASE WHEN course = 'CS229' THEN grade ELSE NULL END) AS 'CS229'
  ,MAX(CASE WHEN course = 'CS224N' THEN grade ELSE NULL END) AS 'CS224N'
FROM CourseGrade
GROUP BY name;
+---------+--------+-------+--------+
| name    | CS106B | CS229 | CS224N |
+---------+--------+-------+--------+
| Alice   | A      | A     | B      |
| Bob     | C      | F     | F      |
| Charlie | B      | B     | A      |
| David   | C      | C     | D      |
| Elsa    | B      | B     | A      |
+---------+--------+-------+--------+
5 rows in set (0.00 sec)

SELECT
  name
  ,MIN(CASE WHEN course = 'CS106B' THEN grade ELSE NULL END) AS 'CS106B'
  ,MIN(CASE WHEN course = 'CS229' THEN grade ELSE NULL END) AS 'CS229'
  ,MIN(CASE WHEN course = 'CS224N' THEN grade ELSE NULL END) AS 'CS224N'
FROM CourseGrade
GROUP BY name;
+---------+--------+-------+--------+
| name    | CS106B | CS229 | CS224N |
+---------+--------+-------+--------+
| Alice   | A      | A     | B      |
| Bob     | C      | F     | F      |
| Charlie | B      | B     | A      |
| David   | C      | C     | D      |
| Elsa    | B      | B     | A      |
+---------+--------+-------+--------+
5 rows in set (0.00 sec)
```

See solution [here](pivot.sql).
