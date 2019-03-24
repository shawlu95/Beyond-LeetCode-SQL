WITH full_table AS
(SELECT 
 s.*
 ,e.department_id
 FROM salary AS s
 JOIN employee AS e
 ON s.employee_id = e.employee_id)
 
,department_monthly AS
(SELECT 
  department_id
 ,pay_date
 ,AVG(amount) AS dept_avg
 FROM full_table
 GROUP BY department_id, pay_date)
 
,company_monthly AS
(SELECT 
 pay_date
 ,AVG(amount) AS company_avg
 FROM full_table
 GROUP BY pay_date)

SELECT
  DISTINCT 
  DATE_FORMAT(d.pay_date, '%Y-%m')  AS pay_month
  ,d.departmend_id
  ,CASE
    WHEN d.dept_avg < c.company_avg THEN "lower"
    WHEN d.dept_avg = c.company_avg THEN "same"
    WHEN d.dept_avg > c.company_avg THEN "higher"
  END AS comparison
FROM department_monthly d
JOIN company_monthly c
ON d.pay_date = c.pay_date
ORDER BY d.pay_date DESC, d.department_id ASC;

-- complication: employees can have different pay-dates
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
ORDER BY pay_month, a.department_id;