-- filter out banned users (dirver and clients)
-- calculate rate


SELECT
  t.Request_at AS Day
  ,ROUND(SUM(t.Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM Trips t
JOIN Users d ON t.Driver_Id = d.Users_Id
JOIN Users c ON t.Client_Id = c.Users_Id
WHERE d.Banned = "No"
  AND c.Banned = "No"
  AND t.Request_at BETWEEN "2013-10-01" AND "2013-10-03"
GROUP BY t.Request_at
ORDER BY t.Request_at;

WITH valid_user AS (
  SELECT * 
  FROM Users
  WHERE Banned = "No"
)
, valid_trips AS (
  SELECT *
  FROM Trips
  WHERE Request_at BETWEEN "2013-10-01" AND "2013-10-03"
)
SELECT
  t.Request_at AS Day
  ,ROUND(SUM(t.Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM valid_trips t
JOIN valid_user d ON t.Driver_Id = d.Users_Id
JOIN valid_user c ON t.Client_Id = c.Users_Id
GROUP BY t.Request_at
ORDER BY t.Request_at;

SELECT
  t.Request_at AS Day
  ,ROUND(SUM(t.Status != "completed") / COUNT(*), 2) AS "Cancellation Rate"
FROM Trips t
JOIN (SELECT * FROM Users WHERE Banned = "No") d ON t.Driver_Id = d.Users_Id
JOIN (SELECT * FROM Users WHERE Banned = "No") c ON t.Client_Id = c.Users_Id
WHERE t.Request_at BETWEEN "2013-10-01" AND "2013-10-03"
GROUP BY t.Request_at
ORDER BY t.Request_at;

SELECT 
  Request_at as Day,
  ROUND(SUM(Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM Trips
WHERE Request_at BETWEEN '2013-10-01' AND '2013-10-03'
  AND Client_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
  AND Driver_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
GROUP BY Request_at;

SELECT
  Request_at AS Day
  ,ROUND(SUM(Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM Trips
WHERE Request_at BETWEEN "2013-10-01" AND "2013-10-03"
  AND Driver_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
  AND Client_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
GROUP BY Request_at;