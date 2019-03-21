

SELECT * FROM
(SELECT DISTINCT user_id FROM Friendship) AS a,
(SELECT DISTINCT user_id FROM Friendship) AS b

SELECT * FROM
(SELECT DISTINCT user_id FROM Friendship) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Friendship) AS b
ON a.user_id != b.user_id;

SELECT * FROM
(SELECT DISTINCT user_id FROM Friendship) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Friendship) AS b
ON a.user_id != b.user_id
AND (a.user_id, b.user_id) NOT IN (SELECT user_id, friend_id FROM Friendship)
AND (b.user_id, a.user_id) NOT IN (SELECT user_id, friend_id FROM Friendship);

WITH tmp AS (
SELECT user_id, friend_id FROM Friendship
UNION ALL
SELECT friend_id, user_id FROM Friendship
)
SELECT 
	a.user_id
	,b.user_id
	,af.friend_id AS common_friend
FROM
(SELECT DISTINCT user_id FROM Friendship) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Friendship) AS b
	ON a.user_id != b.user_id
	AND (a.user_id, b.user_id) NOT IN (SELECT user_id, friend_id FROM tmp)
JOIN tmp AS af
	ON a.user_id = af.user_id
JOIN tmp AS bf
	ON b.user_id = bf.user_id
	AND bf.friend_id = af.friend_id;

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
(SELECT DISTINCT user_id FROM Friendship) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Friendship) AS b
	ON a.user_id != b.user_id
	AND (a.user_id, b.user_id) NOT IN (SELECT user_id, friend_id FROM tmp)
JOIN tmp AS af
	ON a.user_id = af.user_id
JOIN tmp AS bf
	ON b.user_id = bf.user_id
	AND bf.friend_id = af.friend_id
GROUP BY a.user_id, b.user_id
ORDER BY common_friend DESC;

