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