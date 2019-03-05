# Find Cumulative Salary of an Employee

## Description
The __Employee__ table holds the salary information in a year.

Write a SQL to get the cumulative sum of an employee's salary over a period of 3 months but exclude the most recent month.

The result should be displayed by 'Id' ascending, and then by 'Month' descending.

### Example
Load the database file [db.sql](db.sql) to localhost MySQL. Relevant tables will be created in the LeetCode database. 
```
mysql < db.sql -uroot -p
```

__Input__
```
| Id | Month | Salary |
|----|-------|--------|
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 1  | 2     | 30     |
| 2  | 2     | 30     |
| 3  | 2     | 40     |
| 1  | 3     | 40     |
| 3  | 3     | 60     |
| 1  | 4     | 60     |
| 3  | 4     | 70     |
```

__Output__
```
| Id | Month | Salary |
|----|-------|--------|
| 1  | 3     | 90     |
| 1  | 2     | 50     |
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 3  | 3     | 100    |
| 3  | 2     | 40     |
```

### Explanation
Employee '1' has 3 salary records for the following 3 months except the most recent month '4': salary 40 for month '3', 30 for month '2' and 20 for month '1'
So the cumulative sum of salary of this employee over 3 months is 90(40+30+20), 50(30+20) and 20 respectively.
```
| Id | Month | Salary |
|----|-------|--------|
| 1  | 3     | 90     |
| 1  | 2     | 50     |
| 1  | 1     | 20     |
```

Employee '2' only has one salary record (month '1') except its most recent month '2'.
```
| Id | Month | Salary |
|----|-------|--------|
| 2  | 1     | 20     |
```

Employ '3' has two salary records except its most recent pay month '4': month '3' with 60 and month '2' with 40. So the cumulative salary is as following.
```
| Id | Month | Salary |
|----|-------|--------|
| 3  | 3     | 100    |
| 3  | 2     | 40     |
```

## Observation
Make the following observation to interviewers. Confirm your observation is correct. Ask for clarification if necessary.
* Does every employee gets paid every month? (no skipping, no NULL) In this case, months are consecutive, with no missing pay.
* How to handle employee with only one month history? (in this solution, it is left out)

## On Correctness
 * The difficult part of this problem is to exclude current month from aggregation, and yet use current month's label in the output. For example, if most recent month is April, we don't want April and its aggregated column (cumulative sum) in out output. The naive way to approach this problem is to first find most recent payment month __for each__ employee, and exclude it from the output.
 
 * To get previous two months' salary, we can join the table with itself twice. Because we are comparing against older data, we should add to previous month to match against later month (equivalent to LAG function in MS SQL).
 
 * Also important is to properly handle __NULL__. Because adding any number to NULL results in NULL. We must check for NULL since we are using left join.
 
 * Corner case: if a user has only one row in history, he left join will return NULL on right hand side. However, his only row is also his most recent month (__max_month__), and so is excluded from the result. 

We can use a set to exclude *(Id, Month)* [pair](mysql_set.sql):
```
-- MySQL: set solution
SELECT
  e.Id
  ,e.Month
  ,IFNULL(e.Salary, 0) + IFNULL(e1.Salary, 0) + IFNULL(e2.Salary, 0) AS Salary
FROM Employee e
LEFT JOIN Employee e1 ON e.Id = e1.Id AND e.Month = e1.Month + 1
LEFT JOIN Employee e2 ON e.Id = e2.Id AND e.Month = e2.Month + 2
WHERE (e.Id, e.Month) NOT IN (
  SELECT 
    Id
    ,MAX(Month) AS max_month
  FROM Employee 
  GROUP BY Id)
ORDER BY e.Id ASC, e.Month DESC;
```

Or we can use a [temporary](mysql_join_tmp_table.sql) table, and filter the result either with non-equijoin, inner join or cross join. See how each version of the solution handles edge case, and gives the exact same result.

```
-- MySQL: non-equijoin
SELECT
  e.Id
  ,e.Month
  ,IFNULL(e.Salary, 0) + IFNULL(e1.Salary, 0) + IFNULL(e2.Salary, 0) AS Salary
FROM
(SELECT Id, MAX(Month) AS max_month
 FROM Employee 
 GROUP BY Id) AS e_max
-- if using left join, employee with only one record will see NULL returned after join
JOIN Employee e ON e_max.Id = e.Id AND e_max.max_month > e.Month
LEFT JOIN Employee e1 ON e.Id = e1.Id AND e.Month = e1.Month + 1
LEFT JOIN Employee e2 ON e.Id = e2.Id AND e.Month = e2.Month + 2
ORDER BY e.Id ASC, e.Month DESC;

----------------------------------------------------------------------------------------
-- alternatively, use where clause to filter result
SELECT
  e.Id
  ,e.Month
  ,IFNULL(e.Salary, 0) + IFNULL(e1.Salary, 0) + IFNULL(e2.Salary, 0) AS Salary
FROM
(SELECT Id, MAX(Month) AS max_month
 FROM Employee 
 GROUP BY Id) AS e_max
-- if using left join, employee with only one record will see NULL returned after join
JOIN Employee e ON e_max.Id = e.Id
LEFT JOIN Employee e1 ON e.Id = e1.Id AND e.Month = e1.Month + 1
LEFT JOIN Employee e2 ON e.Id = e2.Id AND e.Month = e2.Month + 2
WHERE e_max.max_month != e.Month
ORDER BY e.Id ASC, e.Month DESC;

----------------------------------------------------------------------------------------
-- alternatively, use cross join, also correct
SELECT
  e.Id
  ,e.Month
  ,IFNULL(e.Salary, 0) + IFNULL(e1.Salary, 0) + IFNULL(e2.Salary, 0) AS Salary
FROM
(SELECT Id, MAX(Month) AS max_month
 FROM Employee 
 GROUP BY Id) AS e_max,
Employee e
LEFT JOIN Employee e1 ON e.Id = e1.Id AND e.Month = e1.Month + 1
LEFT JOIN Employee e2 ON e.Id = e2.Id AND e.Month = e2.Month + 2
WHERE e.Id = e_max.Id AND e.Month != e_max.max_month
ORDER BY e.Id ASC, e.Month DESC;
```

## On Efficiency
Instead of building a temporary table, which has no index, we can accomplish the filtering in a [single join](mysql_single_join.sql). Observe the following pattern:
* when calculating the three month cumulative sum, the natural inclination is to add current month T, previous month T-1, and the month before previous month T-2.
* instead, we can add month T-1, T-2, T-3, and output T-1 as our month column. Month T is gracefully excluded.

Because SUM() ignore __NULL__ values, we don't need IFNULL() here.

```
-- MySQL: single join
SELECT
  e1.Id
  ,MAX(e2.Month) AS Month
  ,SUM(e2.Salary) AS Salary
FROM Employee e1
JOIN Employee e2
  ON e1.Id = e2.Id
  AND e1.Month - e2.Month BETWEEN 1 AND 3
GROUP BY e1.Id, e1.Month
ORDER BY e1.Id ASC, e1.Month DESC
```

By the way, we can use [window function](mssql_lag.sql) to retrieve older data. The logic is the same as above.

```
-- MS SQL: Lag window function
WITH cumulative AS (
SELECT
  Id
  ,LAG(Month, 1) OVER (PARTITION BY Id ORDER BY Month ASC) AS Month
  ,ISNULL(LAG(Salary, 1) OVER (PARTITION BY Id ORDER BY Month ASC), 0) 
  + ISNULL(LAG(Salary, 2) OVER (PARTITION BY Id ORDER BY Month ASC), 0) 
  + ISNULL(LAG(Salary, 3) OVER (PARTITION BY Id ORDER BY Month ASC), 0) AS Salary
FROM Employee)
SELECT *
FROM cumulative
WHERE Month IS NOT NULL
ORDER BY Id ASC, Month DESC;
```

In MySQL 8, we can add a window alias to make the code cleaner.
```
-- MySQL 8 also supports window function, and even window alias!
WITH cumulative AS (
SELECT
  Id
  ,LAG(Month, 1) OVER w AS Month
  ,IFNULL(LAG(Salary, 1) OVER w, 0) 
  + IFNULL(LAG(Salary, 2) OVER w, 0) 
  + IFNULL(LAG(Salary, 3) OVER w, 0) AS Salary
FROM Employee
WINDOW w AS (PARTITION BY Id ORDER BY Month ASC))
SELECT *
FROM cumulative
WHERE Month IS NOT NULL
ORDER BY Id ASC, Month DESC;
```

## Parting Thought
Functional-based join such as *e1.Month - e2.Month BETWEEN 1 AND 3* does not leverage the efficiency of index lookup. So it may not scale well. Always check query plan for estimated cost. Fortunately, we can move the index-join *e1.Id = e2.Id* to reduce the join size upfront.
