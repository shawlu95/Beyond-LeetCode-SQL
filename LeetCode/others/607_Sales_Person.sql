-- join version
/* for non-null values in grouped column
	null in matched columns are simgply ignored by
	COUNT, SUM, AVG, if there exists any non-null value.
	(exceot when using COUNT(*))

	If there exists no non-null value in matched row
	Aggregate output NULL. COUNT returns 0.
	*/
SELECT
    s.name
FROM salesperson AS s
LEFT JOIN orders AS o ON o.sales_id = s.sales_id
LEFT JOIN company AS c ON o.com_id = c.com_id
GROUP BY s.name
HAVING SUM(c.name = "RED") = 0 
    OR SUM(c.name = "RED") IS NULL
ORDER BY name;

-- subquery
SELECT 
    s.name 
FROM salesperson s
WHERE sales_id NOT IN (
    SELECT sales_id 
    FROM orders o
    LEFT JOIN company c
        ON o.com_id = c.com_id
    WHERE c.name = 'RED'
);



