SELECT
  e.Name AS Employee
FROM Employee AS e
JOIN
  Employee AS m
WHERE e.ManagerId = m.Id
  AND e.Salary > m.Salary;