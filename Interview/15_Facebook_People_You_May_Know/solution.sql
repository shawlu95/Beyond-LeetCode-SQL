WITH tmp AS (
SELECT user_id, friend_id FROM Friendship
UNION ALL
SELECT friend_id, user_id FROM Friendship
)

SELECT 
	a.user_id
	,b.user_id
	,COUNT(*) AS common_friend
FROM
(SELECT DISTINCT user_id FROM tmp) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM tmp) AS b
	ON a.user_id != b.user_id
	AND (a.user_id, b.user_id) NOT IN (SELECT user_id, friend_id FROM tmp)
JOIN tmp AS af
	ON a.user_id = af.user_id
JOIN tmp AS bf
	ON b.user_id = bf.user_id
	AND bf.friend_id = af.friend_id
GROUP BY a.user_id, b.user_id
HAVING COUNT(*) >= 3
ORDER BY common_friend DESC;