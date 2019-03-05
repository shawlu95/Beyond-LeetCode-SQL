-- MySQL solution
WITH two_way_friendship AS
(SELECT 
  user_id
  ,friend_id
FROM Friendship
UNION
SELECT 
  friend_id
  ,user_id
FROM Friendship)
SELECT
  f.user_id
  ,p.page_id
  ,COUNT(*) AS friends_follower
FROM two_way_friendship AS f
LEFT JOIN PageFollow AS p
  ON f.friend_id = p.user_id
WHERE NOT EXISTS (
  SELECT 1 FROM PageFollow AS p2
  WHERE f.user_id = p2.user_id
    AND p.page_id = p2.page_id
)
GROUP BY f.user_id, p.page_id
ORDER BY f.user_id ASC, COUNT(*) DESC;