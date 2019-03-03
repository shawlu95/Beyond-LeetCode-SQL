-- MySQL: simple join version
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
