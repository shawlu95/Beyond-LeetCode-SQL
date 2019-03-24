-- use self join three times (if month is not dense)
-- name table e, e1, e2, e3; cummulatively sum e1, e2, e3
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

-- use where clause instead of inequality join
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

-- use cross join, also correct
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

-- weird condition, non-standard SQL
SELECT
  e.Id
  ,e.Month
  ,IFNULL(e.Salary, 0) + IFNULL(e1.Salary, 0) + IFNULL(e2.Salary, 0) AS Salary
FROM
  Employee e
LEFT JOIN Employee e1 ON e.Id = e1.Id AND e.Month = e1.Month + 1
LEFT JOIN Employee e2 ON e.Id = e2.Id AND e.Month = e2.Month + 2
WHERE (e.Id, e.Month) != (SELECT Id, MAX(Month) FROM Employee WHERE Id = e.Id) AS x
ORDER BY e.Id ASC, e.Month DESC;

-- best solution (rely on consecutive month)
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