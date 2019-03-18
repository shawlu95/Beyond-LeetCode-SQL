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

-- cross join
SELECT DISTINCT
  u.user_id, u.friend_id
FROM
  User u, Song s1, Song s2
WHERE
  u.user_id = s1.user_id
  AND u.friend_id = s2.user_id
  AND s1.song = s2.song
  AND s1.ts = s2.ts
GROUP BY 1, 2, s1.ts
HAVING COUNT(DISTINCT s1.song) >= 3;

-- prefiltering pipeline
WITH active_user_id AS (
  SELECT
    u.user_id
    ,s.ts
    ,COUNT(*) AS song_tally
  FROM user AS u
  JOIN song AS s
  ON u.user_id = s.user_id
  GROUP BY user_id, ts
  HAVING COUNT(*) >= 3
)
,active_friend_id AS (
  SELECT
    u.friend_id
    ,s.ts
    ,COUNT(*) AS song_tally
  FROM user AS u
  JOIN song AS s
  ON u.friend_id = s.user_id
  GROUP BY friend_id, ts
  HAVING COUNT(*) >= 3
)
,possible_match AS (
  SELECT
    u.user_id
    ,f.friend_id
    ,f.ts
  FROM active_user_id AS u
  JOIN active_friend_id AS f
  ON u.ts = f.ts
)
SELECT DISTINCT 
  p.user_id
  ,p.friend_id
FROM possible_match AS p
JOIN song AS s1
  ON p.ts = s1.ts
  AND p.user_id = s1.user_id
JOIN song AS s2
ON p.ts = s2.ts
  AND p.friend_id = s2.user_id
WHERE s2.song = s1.song
GROUP BY p.user_id, p.friend_id, s1.ts
HAVING COUNT(DISTINCT s1.song) >= 3;