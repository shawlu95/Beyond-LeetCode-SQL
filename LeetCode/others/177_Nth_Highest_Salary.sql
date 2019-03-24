CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  DECLARE M INT DEFAULT N - 1;
  RETURN (
    SELECT DISTINCT Salary FROM Employee ORDER BY Salary DESC LIMIT 1 OFFSET M
  );
END

SELECT * /*This is the outer query part */
FROM Employee Emp1
WHERE (N-1) = ( /* Subquery starts here */
  SELECT COUNT(DISTINCTEmp2.Salary)
  FROM Employee Emp2
  WHERE Emp2.Salary > Emp1.Salary)