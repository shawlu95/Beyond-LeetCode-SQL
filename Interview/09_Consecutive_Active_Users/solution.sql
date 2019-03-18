-- self join method
SET @now = "2019-02-14";
WITH tmp AS (
  SELECT DISTINCT user_id, ts FROM Login)
SELECT *
FROM tmp AS d0
JOIN tmp AS d1
  ON d0.ts = @now
  AND DATEDIFF(@now, d1.ts) = 1
  AND d0.user_id = d1.user_id
JOIN tmp AS d2
  ON DATEDIFF(@now, d2.ts) = 2
  AND d2.user_id = d1.user_id;

-- window method
SET @now = "2019-02-14";
WITH tmp AS (
SELECT
  user_id
  ,ts
  ,DATEDIFF(@now, LAG(ts, 1) OVER w) AS day_from_pre1
  ,DATEDIFF(@now, LAG(ts, 2) OVER w) AS day_from_pre2
FROM Login
WINDOW w AS (PARTITION BY user_id ORDER BY ts)
)
SELECT user_id
FROM tmp
WHERE ts = @now
  AND day_from_pre1 = 1
  AND day_from_pre2 = 2;