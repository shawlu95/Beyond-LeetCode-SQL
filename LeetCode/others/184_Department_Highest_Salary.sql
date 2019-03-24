

/* -------------
BEGINNER SOLUTION: CORRELATED (N+1)
*/
-- succinct but correlated
SELECT 
    d.Name AS 'Department'
    ,e.Name AS 'Employee'
    ,e.Salary
FROM Employee AS e
JOIN Department AS d
ON e.DepartmentId = d.Id
WHERE
    (SELECT COUNT(DISTINCT e2.Salary)
    FROM
        Employee e2
    WHERE
        e2.Salary > e.Salary
            AND e.DepartmentId = e2.DepartmentId
            ) = 0;

-- cleaner than above
SELECT 
    d.Name AS 'Department'
    ,e.Name AS 'Employee'
    ,e.Salary
FROM Employee AS e
JOIN Department AS d
ON e.DepartmentId = d.Id
WHERE NOT EXISTS
  (SELECT * FROM Employee e2
    WHERE e2.Salary > e.Salary
      AND e2.DepartmentId = e.DepartmentId);  

-- sample code from SQL Antipattern pdf book
-- BugsProducts: product_id, bug_id
-- Bugs: bug_id, date_reported
SELECT bp1.product_id, b1.date_reported AS latest, b1.bug_id
       FROM Bugs b1 JOIN BugsProducts bp1 USING (bug_id)
       WHERE NOT EXISTS
         (SELECT * FROM Bugs b2 JOIN BugsProducts bp2 USING (bug_id)
          WHERE bp1.product_id = bp2.product_id
            AND b1.date_reported < b2.date_reported);

/* -------------
INTERMEDOATE SOLUTION: NO CORRELATED SUBQUERY
*/
-- 
-- use departmentId and Salary to uniquely identify employee
-- assume no two employees in same dept shares same highest salary
SELECT
  d.Name AS Department
  ,e.Name AS Employee
  ,a.max_salary AS Salary
FROM
  Employee AS e
JOIN
  Department AS d
ON e.DepartmentId = d.Id
JOIN
  (SELECT
    DepartmentId
    ,MAX(Salary) AS max_salary
  FROM Employee
  GROUP BY DepartmentId) AS a
ON e.DepartmentId = a.DepartmentId
WHERE
  e.Salary = a.max_salary
  AND e.DepartmentId = a.DepartmentId;

-- use view to simplify code
CREATE VIEW latest_bug AS
SELECT -- in each group: product id is fixed, date_reported is aggreated, bug_id is ignored
  product_id
  ,MAX(date_reported) AS latest
FROM Bugs b JOIN BugsProducts bp
  ON b.bug_id = bp.bug_id -- primary key, one-to-one
GROUP BY product_id;

-- now we know the latest day when bug for each product_id occurs
-- use latest_day and product_id to retrieve bug_id
-- more than one bug_id may be returned if bug occured more than once on latest day
SELECT
  bp.product_id
  ,lb.latest
  ,bp.bug_id
FROM BugsProducts bp JOIN latest_bug lb
  ON bp.product_id = lb.product_id; -- product_id is unique in tmp table, not unique in left table
    AND lb.date_reported = lb.latest;  -- without this predicate, latest will be matched to all rows on left with same product id

DROP VIEW;

-- textbook version
SELECT m.product_id, m.latest, b1.bug_id
FROM Bugs b1 JOIN BugsProducts bp1 USING (bug_id)
  JOIN (SELECT bp2.product_id, MAX(b2.date_reported) AS latest
   FROM Bugs b2 JOIN BugsProducts bp2 USING (bug_id)
   GROUP BY bp2.product_id) m
  ON (bp1.product_id = m.product_id AND b1.date_reported = m.latest);

/* -------------
ULTIMATE SOLUTION: JOIN
*/

CREATE VIEW tmp_join AS
SELECT bp.product_id, b.bug_id, b.date_reported
FROM BugsProducts bp JOIN Bugs b
  WHERE bp.bug_id = b.bug_id;

-- left join with itself, matching every row to rows with same product_id and earlier date
-- those without a match is what we want (the latest)
SELECT
  t1.*
FROM tmp_join t1 
LEFT JOIN tmp_join t2
  ON t1.product_id = t2.product_id
    AND t1.date_reported < t2.date_reported -- latest date in left will match to null on right
WHERE t2.bug_id IS NULL;

-- textbook version
SELECT bp1.product_id, b1.date_reported AS latest, b1.bug_id
FROM Bugs b1 JOIN BugsProducts bp1 ON (b1.bug_id = bp1.bug_id)
LEFT OUTER JOIN (Bugs AS b2 JOIN BugsProducts AS bp2 ON (b2.bug_id = bp2.bug_id))
  ON (bp1.product_id = bp2.product_id AND (b1.date_reported < b2.date_reported
    OR b1.date_reported = b2.date_reported AND b1.bug_id < b2.bug_id))
WHERE b2.bug_id IS NULL;

