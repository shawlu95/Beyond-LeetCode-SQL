SELECT
  e.name
  ,b.bonus
FROM Employee AS e
LEFT JOIN Bonus AS b
ON e.empId = b.empId
WHERE b.bonus < 1000
  OR b.bonus IS NULL
ORDER BY e.name;