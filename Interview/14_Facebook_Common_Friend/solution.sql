WITH tmp AS (
SELECT user_id, friend_id FROM Friendship
UNION ALL
SELECT friend_id, user_id FROM Friendship
)
SELECT
	ab.user_id
	,ab.friend_id
	,COUNT(*) AS common_friend
FROM tmp AS ab
JOIN tmp AS af
	ON ab.user_id = af.user_id
JOIN tmp AS bf
	ON ab.friend_id = bf.user_id
	AND bf.friend_id = af.friend_id
GROUP BY ab.user_id, ab.friend_id
HAVING common_friend >= 3
ORDER BY common_friend DESC;