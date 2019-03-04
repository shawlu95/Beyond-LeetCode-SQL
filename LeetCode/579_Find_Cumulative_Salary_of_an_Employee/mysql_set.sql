-- MySQL: set solution
SELECT
	e.Id
	,e.Month
	,IFNULL(e.Salary, 0) + IFNULL(e1.Salary, 0) + IFNULL(e2.Salary, 0) AS Salary
FROM Employee e
LEFT JOIN Employee e1 ON e.Id = e1.Id AND e.Month = e1.Month + 1
LEFT JOIN Employee e2 ON e.Id = e2.Id AND e.Month = e2.Month + 2
WHERE (e.Id, e.Month) NOT IN (
	SELECT 
		Id
		,MAX(Month) AS max_month
	FROM Employee 
	GROUP BY Id)
ORDER BY e.Id ASC, e.Month DESC;