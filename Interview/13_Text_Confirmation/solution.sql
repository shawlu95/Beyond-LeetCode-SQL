-- Q1
SELECT
  CAST(ts AS DATE) AS dt
  ,COUNT(*) AS signups
FROM Email
GROUP BY dt;

-- Q2: one line
SELECT ROUND((SELECT SUM(action = 'CONFIRMED') FROM text) / (SELECT COUNT(*) FROM Email), 2) AS rate;

-- Q2: Window
WITH confirmed AS (
SELECT user_id, action
FROM text WHERE (user_id, ts) IN (SELECT user_id, MAX(ts) FROM text GROUP BY user_id)
)
SELECT 
  ROUND(SUM(c.action IS NOT NULL) / COUNT(DISTINCT e.user_id), 2) AS rate
FROM Email AS e
LEFT JOIN confirmed AS c
ON e.user_id = c.user_id;

-- Q2: plain
SELECT 
  ROUND(SUM(c.action IS NOT NULL) / COUNT(DISTINCT e.user_id), 2) AS rate
FROM Email AS e
LEFT JOIN (
  SELECT user_id, action
  FROM text WHERE (user_id, ts) IN (
    SELECT user_id, MAX(ts) FROM text GROUP BY user_id
  )
) AS c
ON e.user_id = c.user_id;

-- Q3
SELECT
  e.user_id
FROM Email AS e
JOIN Text AS t
ON e.user_id = t.user_id
  AND DATEDIFF(t.ts, e.ts) = 1
WHERE t.action = 'CONFIRMED';

-- for reference
SELECT
  user_id
  ,ts
  ,action
  ,LEAD(ts, 1) OVER (PARTITION BY user_id ORDER BY ts) AS next_ts
  ,LEAD(action, 1) OVER (PARTITION BY user_id ORDER BY ts) AS next_action
  ,TIMEDIFF(LEAD(ts, 1) OVER (PARTITION BY user_id ORDER BY ts), ts) AS time_diff
FROM Text
ON e.user_id = t.user_id