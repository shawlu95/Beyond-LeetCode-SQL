
-- Q1: find monthly active users
SET @today := "2019-03-01";
SELECT
  MAX(u.name) -- functionally dependent on user_id
  ,MAX(u.phone_num) -- functionally dependent on user_id
  ,MAX(h.date) AS recent_date
FROM User AS u
JOIN UserHistory AS h
  ON u.user_id = h.user_id
WHERE h.action = "logged_on"
  AND DATEDIFF(@today, h.date) <= 30
GROUP BY u.user_id
ORDER BY recent_date;


-- Q2: find inactive users (all-time)
SELECT *
FROM User AS u
LEFT JOIN UserHistory AS h
  ON u.user_id = h.user_id
WHERE h.user_id IS NULL;