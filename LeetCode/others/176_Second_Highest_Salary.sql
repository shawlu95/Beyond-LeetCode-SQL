-- check if NULL (only row row in table)
-- check if distinct is necessary (disallow duplicate)
SELECT
  IFNULL(
    (SELECT 
      DISTINCT Salary
    FROM Employee 
    ORDER BY Salary DESC
    LIMIT 1 OFFSET 1)
    , NULL) AS SecondHighestSalary;