# Average Salary: Departments VS Company

## Description

Given two tables as below, write a query to display the comparison result (higher/lower/same) of the average salary of employees in a department to the company's average salary.
 
Load the database file [db.sql](db.sql) to localhost MySQL. Relevant tables will be created in the LeetCode database. 
```
mysql < db.sql -uroot -p
```

Table: salary
```
| id | employee_id | amount | pay_date   |
|----|-------------|--------|------------|
| 1  | 1           | 9000   | 2017-03-31 |
| 2  | 2           | 6000   | 2017-03-31 |
| 3  | 3           | 10000  | 2017-03-31 |
| 4  | 1           | 7000   | 2017-02-28 |
| 5  | 2           | 6000   | 2017-02-28 |
| 6  | 3           | 8000   | 2017-02-28 |
 ```

The employee_id column refers to the employee_id in the following table employee.
 
```
| employee_id | department_id |
|-------------|---------------|
| 1           | 1             |
| 2           | 2             |
| 3           | 2             |
 ```

So for the sample data above, the result is:
 
```
| pay_month | department_id | comparison  |
|-----------|---------------|-------------|
| 2017-03   | 1             | higher      |
| 2017-03   | 2             | lower       |
| 2017-02   | 1             | same        |
| 2017-02   | 2             | same        |
 ```

Explanation
 

In March, the company's average salary is (9000+6000+10000)/3 = 8333.33...
 

The average salary for department '1' is 9000, which is the salary of employee_id '1' since there is only one employee in this department. So the comparison result is 'higher' since 9000 > 8333.33 obviously.
 

The average salary of department '2' is (6000 + 10000)/2 = 8000, which is the average of employee_id '2' and '3'. So the comparison result is 'lower' since 8000 < 8333.33.
 

With he same formula for the average salary comparison in February, the result is 'same' since both the department '1' and '2' have the same average salary with the company, which is 7000.

---
## Observation
Make the following observation to interviewers. Confirm your observation is correct. Ask for clarification if necessary.
* Ask whether every employee will be in a department (no NULL in the department_id column). If there is NULL, how to display it.
* Note that people get paid on __different__ day of the same months, meaning that you must process the date label before averaging, otherwise you __will not__ get the correct average.

---
## Solution
The overall strategy is to build two temporary tables, one aggregated over the pay month, one aggregated over the (pay month, department) key pair. After aggregating, joining the two temporary tables. Because every distinct pay month must exist in both table, inner join is enough.

#### Step 1. Company Monthly Average
```sql
mysql> SELECT 
    ->   date_format(pay_date, '%Y-%m') as pay_month
    ->   ,AVG(amount) AS corp_avg_sal 
    ->   FROM salary GROUP BY pay_month;
```
```
+-----------+--------------+
| pay_month | corp_avg_sal |
+-----------+--------------+
| 2017-02   |    6666.6667 |
| 2017-03   |    8333.3333 |
+-----------+--------------+
2 rows in set (0.00 sec)
```

Notice what happens if you don't process pay_date column before aggregating: you get the wrong average, and your final result will be wrong.

```sql
mysql> SELECT 
    ->   pay_date
    ->   ,AVG(amount) AS corp_avg_sal 
    ->   FROM salary GROUP BY pay_date;
```
```
+------------+--------------+
| pay_date   | corp_avg_sal |
+------------+--------------+
| 2017-02-25 |    6000.0000 |
| 2017-02-28 |    7000.0000 |
| 2017-03-31 |    8333.3333 |
+------------+--------------+
3 rows in set (0.00 sec)
```

#### Step 2. Department Monthly Average
Similarly, process pay_date before aggregating.

```sql
mysql> SELECT 
    ->   date_format(pay_date, '%Y-%m') as pay_month
    ->  ,e.department_id
    ->  ,AVG(amount) AS dept_avg_sal 
    ->  FROM salary AS s
    ->  JOIN employee AS e
    ->     ON s.employee_id = e.employee_id
    ->  GROUP BY pay_month, e.department_id;
```
```
+-----------+---------------+--------------+
| pay_month | department_id | dept_avg_sal |
+-----------+---------------+--------------+
| 2017-02   |             1 |    6000.0000 |
| 2017-02   |             2 |    7000.0000 |
| 2017-03   |             1 |    9000.0000 |
| 2017-03   |             2 |    8000.0000 |
+-----------+---------------+--------------+
4 rows in set (0.00 sec)
```

#### Step 3. Join and Present Results
Can use inner join, or cross join with where clause, or left join. The results are the same. On LeetCode, the efficiency is quite different: cross join (167ms) < inner join (185ms) < left join (205ms).

Remember to give alias to derived tables. See full solution [here](mysql_session_vars.sql).

```sql
mysql> SELECT  
    ->   a.pay_month
    ->   ,a.department_id, 
    ->   CASE
    ->     WHEN a.dept_avg_sal < b.corp_avg_sal THEN "lower"
    ->     WHEN a.dept_avg_sal = b.corp_avg_sal THEN "same"
    ->     ELSE "higher"
    ->   END AS comparison
    -> FROM
    -> (SELECT 
    ->   date_format(pay_date, '%Y-%m') as pay_month
    ->  ,e.department_id
    ->  ,AVG(amount) AS dept_avg_sal 
    ->  FROM salary AS s
    ->  JOIN employee AS e
    ->     ON s.employee_id = e.employee_id
    ->  GROUP BY pay_month, e.department_id
    -> ) AS a
    -> JOIN
    -> (SELECT 
    ->   date_format(pay_date, '%Y-%m') as pay_month
    ->   ,AVG(amount) AS corp_avg_sal 
    ->   FROM salary GROUP BY pay_month
    -> ) AS b
    -> ON a.pay_month = b.pay_month
    -> ORDER BY pay_month, department_id;
```
```
+-----------+---------------+------------+
| pay_month | department_id | comparison |
+-----------+---------------+------------+
| 2017-02   |             1 | same       |
| 2017-02   |             2 | same       |
| 2017-03   |             1 | higher     |
| 2017-03   |             2 | lower      |
+-----------+---------------+------------+
4 rows in set (0.00 sec)
```
