-- full solution
SELECT
  s1.user_id
  ,s2.user_id AS recommended
FROM Song AS s1
JOIN Song AS s2
  ON s1.user_id != s2.user_id
  AND s1.ts = s2.ts
  AND s1.song = s2.song
WHERE (s1.user_id, s2.user_id) NOT IN (
  SELECT user_id, friend_id FROM User
  UNION
  SELECT friend_id, user_id FROM User
)
GROUP BY s1.user_id, s2.user_id, s2.ts
HAVING COUNT(DISTINCT s2.song) >= 3;