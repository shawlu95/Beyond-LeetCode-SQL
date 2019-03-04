-- MS SQL: Lag window function
WITH cummulative AS (
SELECT
  Id
  ,LAG(Month, 1) OVER (PARTITION BY Id ORDER BY Month ASC) AS Month
  ,ISNULL(LAG(Salary, 1) OVER (PARTITION BY Id ORDER BY Month ASC), 0) 
  + ISNULL(LAG(Salary, 2) OVER (PARTITION BY Id ORDER BY Month ASC), 0) 
  + ISNULL(LAG(Salary, 3) OVER (PARTITION BY Id ORDER BY Month ASC), 0) AS Salary
FROM Employee)
SELECT *
FROM cummulative
WHERE Month IS NOT NULL
ORDER BY Id ASC, Month DESC;

-- MySQL 8 also supports window function, and even window alias!
WITH cummulative AS (
SELECT
  Id
  ,LAG(Month, 1) OVER w AS Month
  ,ISNULL(LAG(Salary, 1) OVER w, 0) 
  + ISNULL(LAG(Salary, 2) OVER w, 0) 
  + ISNULL(LAG(Salary, 3) OVER w, 0) AS Salary
FROM Employee
WINDOW w AS (PARTITION BY Id ORDER BY Month ASC))
SELECT *
FROM cummulative
WHERE Month IS NOT NULL
ORDER BY Id ASC, Month DESC;