/*
A B C
A B D
B C N
B D E
D E N
*/

-- ask about DISTINCT!!!!
-- not that we are grouping by first degree follower, not followeee
SELECT
  f1.follower
  ,COUNT(DISTINCT f2.follower) AS num
FROM
  follow f1
JOIN
  follow f2
ON f1.follower = f2.followee
GROUP BY f1.follower
ORDER BY f1.follower;