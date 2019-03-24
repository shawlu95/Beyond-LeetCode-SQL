/* warning

NO need to handle null if tables are joined before aggregating.
NULL columns are simply not counted (return 0 if departmend has no student)

If studnets are counted before joining, only existing department
with at least 1 student are aggregated over with count. 

Left joining full dept tables (including empty dept) will result in NULL */

SELECT
  d.dept_name
  ,COUNT(s.student_name) AS student_number
FROM department AS d
LEFT JOIN student AS s
ON d.dept_id = s.dept_id
GROUP BY dept_name
ORDER BY student_number DESC, dept_name;

SELECT
  d.dept_name
  ,IFNULL(s.student_number, 0) AS student_number
FROM department AS d
LEFT JOIN (
    SELECT 
        dept_id
        ,COUNT(student_name) AS student_number
    FROM student
    GROUP BY dept_id
) AS s
ON d.dept_id = s.dept_id
ORDER BY student_number DESC, dept_name ASC;