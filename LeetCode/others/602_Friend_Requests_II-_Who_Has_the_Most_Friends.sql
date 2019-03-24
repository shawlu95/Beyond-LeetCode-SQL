/*
how to count friends for user 1

requester accepter
1  2
1  3
4  1
5  1

left join does not work, must use union
count how many times 1 appears in requester col, then accepter col 

friendship is mutual

cannot have 1, 2 in on row, then 2, 1 in a nother row */

SELECT 
  requester_id AS id
  ,SUM(tally) AS num
FROM
(SELECT
  requester_id
  ,COUNT(*) AS tally
  FROM request_accepted
  GROUP BY requester_id
UNION ALL
SELECT
  accepter_id
  ,COUNT(*)
  FROM request_accepted
  GROUP BY accepter_id) a -- alias!
GROUP BY id
ORDER BY num DESC -- sort order!
LIMIT 1;

# Write your MySQL query statement below

SELECT id, COUNT(*) AS num FROM (
    SELECT accepter_id AS id FROM request_accepted
    UNION ALL
    SELECT requester_id AS id FROM request_accepted
) AS c 
GROUP BY 1
ORDER BY num DESC 
LIMIT 1;
