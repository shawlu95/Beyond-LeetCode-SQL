# Unpivoting Table

This is the reverse process of pivoting. In effect, we are reducing the number of columns, and increasing the number of rows. The key is to define an auxillary table. In this notebook, we will un-pivot both the numeric pivot [table](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/Interview/05_Pivoting_Numeric_Data) and the text pivot [table](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/Interview/06_Pivoting_Text_Data).

> An auxillary table is a temporary table that contains a single columns containing the name of the columns to be dropped from the pivot table.

The reversal is accomplished by cross joining with an auxillary table, to inrease the number of rows. Then we apply a case statement on the auxillary table's value, and select the to-be-dropped columns correspondingly.

In this notebook, we'll go over two examples: unpivoting the numeric table and text table we accomplished in the earlier notebooks. You'll see that, by aggregating over numeric data, we have permanently lost information, and cannot fully un-pivot back to the original state.

Before getting started, load the pivot table by running the following [script](pivot_table.sql).
```bash
mysql < pivot_table.sql -uroot -p
```

---
### Unpivoting Text Data
#### Step 1. Build the Auxillary Table
Different SQL server gives you different syntax in building auxillary table. In MySQL, the process is rather verbose.

```sql
SELECT * FROM (
  SELECT 'CS106B' AS course_name
  UNION ALL
  SELECT 'CS229'
  UNION ALL
  SELECT 'CS224N' year
       ) aux;
```
```
+-------------+
| course_name |
+-------------+
| CS106B      |
| CS229       |
| CS224N      |
+-------------+
3 rows in set (0.00 sec)
```

#### Step 2. Cross Join with Pivot Table
Notice that this will uncover the numebr of rows to 15 (5 students * 3 courses), which is where we started with.

```sql
SELECT * FROM 
course_grade_pivoted,
(
  SELECT 'CS106B' AS course
  UNION ALL
  SELECT 'CS229'
  UNION ALL
  SELECT 'CS224N' year
       ) aux;
```
```
+---------+--------+-------+--------+-------------+
| name    | CS106B | CS229 | CS224N | course |
+---------+--------+-------+--------+-------------+
| Alice   | A      | A     | B      | CS106B      |
| Alice   | A      | A     | B      | CS229       |
| Alice   | A      | A     | B      | CS224N      |
| Bob     | C      | F     | F      | CS106B      |
| Bob     | C      | F     | F      | CS229       |
| Bob     | C      | F     | F      | CS224N      |
| Charlie | B      | B     | A      | CS106B      |
| Charlie | B      | B     | A      | CS229       |
| Charlie | B      | B     | A      | CS224N      |
| David   | C      | C     | D      | CS106B      |
| David   | C      | C     | D      | CS229       |
| David   | C      | C     | D      | CS224N      |
| Elsa    | B      | B     | A      | CS106B      |
| Elsa    | B      | B     | A      | CS229       |
| Elsa    | B      | B     | A      | CS224N      |
+---------+--------+-------+--------+-------------+
15 rows in set (0.00 sec)
```

We're simply multiplying each row in the pivot table three times, with each of the three courses. This step results in redundant data. For each student, the CS206B, CS229, CS224N columns are all identical. But notice that we have recovered back to 15 rows, and the original course column!

```
SELECT * FROM CourseGrade;
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

The only thing we need to do know is to combine the three columns to one, extracting where the *column title* matches the row value of the *course* column. For each student, this is precisely the diagonal line of the square mateix!

| name    | CS106B | CS229 | CS224N | course      |
|---------|--------|-------|--------|-------------|
| Alice   | __A__      | A     | B      | CS106B      |
| Alice   | A      | __A__     | B      | CS229       |
| Alice   | A      | A     | __B__      | CS224N      |


We can use a case statement to condition on the value of the course column, and extract the corresponding value from the matching columns.
```sql
SELECT 
  name
  ,aux.course
  ,CASE aux.course
  WHEN 'CS106B' THEN CS106B
  WHEN 'CS229' THEN CS229
  WHEN 'CS224N' THEN CS224N
  END AS grade
FROM  course_grade_pivoted,
(
  SELECT 'CS106B' AS course
  UNION ALL
  SELECT 'CS229'
  UNION ALL
  SELECT 'CS224N' year
       ) aux;
```
```
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
### Unpivoting Numeric Data
To unpivote the table from this [notebook](../05_Pivoting_Numeric_Data/), we apply the same two-step technique. However, because the pivot table was constructed by summing over groups, we are unable to uncover the 1083 rows. Instead, we can only recover 25 categories * 12 months = 300 rows. Here we show 24 rows, for 'Social' and 'Book' categories.

```sql
SELECT 
  category
  ,aux.month
  ,CASE aux.month
  WHEN 'Jan' THEN Jan
  WHEN 'Feb' THEN Feb
  WHEN 'Mar' THEN Mar
  WHEN 'Apr' THEN Apr
  WHEN 'May' THEN May
  WHEN 'Jun' THEN Jun
  WHEN 'Jul' THEN Jul
  WHEN 'Aug' THEN Aug
  WHEN 'Sep' THEN Sep
  WHEN 'Oct' THEN Oct
  WHEN 'Nov' THEN Nov
  WHEN 'Dec' THEN Dec_
  END AS month
FROM expenses_pivoted,
(
  SELECT 'Jan' AS month
  UNION ALL
  SELECT 'Feb'
  UNION ALL
  SELECT 'Mar'
  UNION ALL
  SELECT 'Apr'
  UNION ALL
  SELECT 'May'
  UNION ALL
  SELECT 'Jun'
  UNION ALL
  SELECT 'Jul'
  UNION ALL
  SELECT 'Aug'
  UNION ALL
  SELECT 'Sep'
  UNION ALL
  SELECT 'Oct'
  UNION ALL
  SELECT 'Nov'
  UNION ALL
  SELECT 'Dec'
       ) AS aux
LIMIT 24;
```
```
+----------+-------+--------+
| category | month | month  |
+----------+-------+--------+
| Social   | Jan   | 279.38 |
| Social   | Feb   |  71.38 |
| Social   | Mar   | 185.25 |
| Social   | Apr   | 228.65 |
| Social   | May   | 109.33 |
| Social   | Jun   | 286.32 |
| Social   | Jul   |  49.41 |
| Social   | Aug   | 165.50 |
| Social   | Sep   | 167.03 |
| Social   | Oct   | 120.58 |
| Social   | Nov   | 265.27 |
| Social   | Dec   |  86.14 |
| Book     | Jan   | 110.61 |
| Book     | Feb   | 511.56 |
| Book     | Mar   |   0.00 |
| Book     | Apr   |  52.72 |
| Book     | May   |  29.09 |
| Book     | Jun   |   0.00 |
| Book     | Jul   |  24.57 |
| Book     | Aug   |  20.04 |
| Book     | Sep   |   0.00 |
| Book     | Oct   |   0.00 |
| Book     | Nov   |  20.58 |
| Book     | Dec   |   8.93 |
+----------+-------+--------+
24 rows in set (0.00 sec)
```

In case you're wondering why I write 'Dec_' instead of 'Dec'. It turns out that 'Dec' is a reserved keyword. It is a function that converts a binary string argument into a numeric value.

See full solution [here](un_pivot_table.sql).