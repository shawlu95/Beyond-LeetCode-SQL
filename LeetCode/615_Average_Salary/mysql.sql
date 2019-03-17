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