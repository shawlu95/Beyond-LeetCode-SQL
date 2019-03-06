-- MS SQL: Boosting effiency with pre-filtering
WITH department_ranking AS (
SELECT
  e.Name AS Employee
  ,e.Salary
  ,e.DepartmentId
  ,DENSE_RANK() OVER (PARTITION BY e.DepartmentId ORDER BY e.Salary DESC) AS rnk
FROM Employee AS e
)
-- pre-filter table to reduce join size
,top_three AS (
SELECT
  Employee
  ,Salary
  ,DepartmentId
FROM department_ranking 
WHERE rnk <= 3
)
SELECT
  d.Name AS Department
  ,e.Employee
  ,e.Salary
FROM top_three AS e
JOIN Department AS d
ON e.DepartmentId = d.Id
ORDER BY d.Name ASC, e.Salary DESC;

-- MS SQL: cleaner version
WITH department_ranking AS (
SELECT
  e.Name AS Employee
  ,e.Salary
  ,e.DepartmentId
  ,DENSE_RANK() OVER (PARTITION BY e.DepartmentId ORDER BY e.Salary DESC) AS rnk
FROM Employee AS e
)
SELECT
  d.Name AS Department
  ,r.Employee
  ,r.Salary
FROM department_ranking AS r
JOIN Department AS d
  ON r.DepartmentId = d.Id
  AND r.rnk <= 3
ORDER BY d.Name ASC, r.Salary DESC;