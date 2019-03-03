-- MySQL: set version
SELECT
  Request_at AS Day
  ,ROUND(SUM(Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM Trips
WHERE Request_at BETWEEN "2013-10-01" AND "2013-10-03"
  AND Driver_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
  AND Client_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
GROUP BY Request_at;