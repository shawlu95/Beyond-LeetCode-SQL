SELECT
  m.Name
FROM Employee AS e
JOIN Employee AS m
ON e.ManagerId = m.Id 
GROUP BY m.Name
HAVING COUNT(*) >= 5
ORDER BY m.Name;