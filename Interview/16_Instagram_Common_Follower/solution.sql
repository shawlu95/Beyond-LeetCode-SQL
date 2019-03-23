SELECT
a.user_id
,b.user_id
,COUNT(*) AS common
FROM
(SELECT DISTINCT user_id FROM Follow) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Follow) AS b 
ON a.user_id != b.user_id
JOIN Follow AS af
ON a.user_id = af.user_id
JOIN Follow AS bf
ON b.user_id = bf.user_id
AND af.follower_id = bf.follower_id
GROUP BY a.user_id, b.user_id
ORDER BY common DESC, a.user_id, b.user_id;