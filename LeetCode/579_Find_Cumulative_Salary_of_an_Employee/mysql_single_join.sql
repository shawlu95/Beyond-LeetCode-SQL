-- MySQL: single join (rely on consecutive month)
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