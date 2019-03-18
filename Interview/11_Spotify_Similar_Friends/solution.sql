-- MySQL
SELECT DISTINCT
  u.user_id
  ,u.friend_id
FROM User AS u
JOIN Song AS s1 
  ON u.user_id = s1.user_id
JOIN Song AS s2
  ON u.friend_id = s2.user_id
WHERE s1.ts = s2.ts
  AND s1.song = s2.song
GROUP BY s1.ts, u.user_id, u.friend_id
HAVING COUNT(DISTINCT s1.song) >= 3;