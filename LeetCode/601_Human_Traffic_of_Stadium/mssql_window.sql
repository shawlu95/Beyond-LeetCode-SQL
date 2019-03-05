-- MS SQL: window
WITH long_table AS (
SELECT
  *
  ,LAG(people, 2) OVER (ORDER BY id ASC) AS pre2
  ,LAG(people, 1) OVER (ORDER BY id ASC) AS pre1
  ,LEAD(people, 1) OVER (ORDER BY id ASC) AS nxt1
  ,LEAD(people, 2) OVER (ORDER BY id ASC) AS nxt2
FROM stadium
)
SELECT
  id
  ,visit_date
  ,people
FROM long_table
WHERE people >= 100
  AND ((pre2 >= 100 AND pre1 >= 100) 
  OR (pre1 >= 100 AND nxt1 >= 100) 
  OR (nxt1 >= 100 AND nxt2 >= 100))
ORDER BY id;

-- MySQL 8 equivalent
WITH long_table AS (
SELECT
  *
  ,LAG(people, 2) OVER w AS pre2
  ,LAG(people, 1) OVER w AS pre1
  ,LEAD(people, 1) OVER w AS nxt1
  ,LEAD(people, 2) OVER w AS nxt2
FROM stadium
WINDOW w AS (ORDER BY id ASC)
)
SELECT
  id
  ,visit_date
  ,people
FROM long_table
WHERE people >= 100
  AND ((pre2 >= 100 AND pre1 >= 100) 
  OR (pre1 >= 100 AND nxt1 >= 100) 
  OR (nxt1 >= 100 AND nxt2 >= 100))
ORDER BY id;