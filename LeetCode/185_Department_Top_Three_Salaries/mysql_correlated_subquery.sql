# Use correlated subquery, and aggregate over subquery
SELECT
  d.Name AS 'Department'
  ,e.Name AS 'Employee'
  ,e.Salary
FROM Employee e
JOIN Department d
  ON e.DepartmentId = d.Id
WHERE
  (SELECT COUNT(DISTINCT e2.Salary)
  FROM
    Employee e2
  WHERE
    e2.Salary > e.Salary
      AND e.DepartmentId = e2.DepartmentId
      ) < 3;
