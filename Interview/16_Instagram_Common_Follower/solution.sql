SELECT user_id, COUNT(*) AS followed_by FROM Instagram GROUP BY user_id ORDER BY followed_by;


SELECT follower_id, COUNT(*) AS following FROM Instagram GROUP BY follower_id ORDER BY following;

SELECT *
FROM
(SELECT DISTINCT user_id FROM Instagram) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Instagram) AS b 
ON a.user_id != b.user_id
JOIN Instagram AS af
ON a.user_id = af.user_id
JOIN Instagram AS bf
ON b.user_id = bf.user_id
AND af.follower_id = bf.follower_id;


SELECT
a.user_id
,b.user_id
,COUNT(*) AS common
FROM
(SELECT DISTINCT user_id FROM Instagram) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Instagram) AS b 
ON a.user_id != b.user_id
JOIN Instagram AS af
ON a.user_id = af.user_id
JOIN Instagram AS bf
ON b.user_id = bf.user_id
AND af.follower_id = bf.follower_id
GROUP BY 1, 2;