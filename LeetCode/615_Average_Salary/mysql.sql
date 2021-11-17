-- MySQL plain solution
SELECT  
  a.pay_month
  ,a.department_id, 
  CASE
    WHEN a.dept_avg_sal < b.corp_avg_sal THEN "lower"
    WHEN a.dept_avg_sal = b.corp_avg_sal THEN "same"
    ELSE "higher"
  END AS comparison
FROM
(SELECT 
  date_format(pay_date, '%Y-%m') as pay_month
 ,e.department_id
 ,AVG(amount) AS dept_avg_sal 
 FROM salary AS s
 JOIN employee AS e
    ON s.employee_id = e.employee_id
 GROUP BY pay_month, e.department_id
) AS a
JOIN
(SELECT 
  date_format(pay_date, '%Y-%m') as pay_month
  ,AVG(amount) AS corp_avg_sal 
  FROM salary GROUP BY pay_month
) AS b
ON a.pay_month = b.pay_month
ORDER BY pay_month, department_id;


/* MySQL Solution using CTE*/
WITH myCTE1 AS (
SELECT s.employee_id, s.amount, s.pay_date,e.department_id,
DATE_FORMAT(s.pay_date, "%Y-%m") as y_m, 
ROUND(AVG(amount) OVER(PARTITION BY DATE_FORMAT(s.pay_date, "%Y-%m")),2) 'company_avg'
FROM salary s join employee e 
ON s.employee_id = e.employee_id
),
myCTE2 as (
SELECT y_m as pay_period, department_id, company_avg, ROUND(AVG(amount),2) 'department_avg' 
FROM myCTE1 
GROUP  BY department_id, y_m
)
SELECT *, 
	CASE 
		WHEN company_avg < department_avg THEN 'higher'
        WHEN company_avg > department_avg THEN 'lower'
        ELSE 'lower'
	END as 'comparision'
FROM myCTE2 
ORDER BY pay_period desc, department_id

