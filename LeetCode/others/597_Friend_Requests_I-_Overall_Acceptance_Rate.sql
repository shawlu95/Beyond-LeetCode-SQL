# Write your MySQL query statement below

/*
how to count friends for user 1

requester accepter
1  2
1  3
4  1
5  1

left join does not work, must use union
count how many times 1 appears in requester col, then accepter col */

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

-- IFNULL(value if not null, value if null)
-- to get a scalar value, envelope subquery with bracket 
-- to select from subquery, envelope with bracket
-- Every derived table must have its own alias: AS acc. AS req
SELECT 
    ROUND(
        IFNULL(
            (SELECT COUNT(*) FROM (SELECT DISTINCT requester_id, accepter_id FROM request_accepted) AS acc)
            /
            (SELECT COUNT(*) FROM (SELECT DISTINCT sender_id, send_to_id FROM friend_request) AS req)
            ,0)
    ,2) AS accept_rate;

-- use cross join
SELECT ROUND(
    IFNULL(
        COUNT(DISTINCT requester_id, accepter_id)/
        COUNT(DISTINCT sender_id, send_to_id)
        , 0)
    , 2) AS accept_rate
FROM request_accepted, friend_request

/*
1. if A sends two requests to B, B request the second, does the first request count?
2. duplicate requests are coutned once
*/

SELECT
  ROUND(
    IFNULL(
      (SELECT COUNT(DISTINCT requester_id, accepter_id) FROM request_accepted)
      /(SELECT COUNT(DISTINCT sender_id, send_to_id) FROM friend_request)
      , 0)
    ,2
    ) AS accept_rate;
    

SELECT
  ROUND(
    IFNULL(a.accept_tally / r.request_tally, 0)
    ,2
    ) AS accept_rate
FROM
(SELECT COUNT(DISTINCT requester_id, accepter_id) AS accept_tally FROM request_accepted) AS a,
(SELECT COUNT(DISTINCT sender_id, send_to_id) AS request_tally FROM friend_request) AS r;


SELECT
  ROUND(
    IF(r.request_tally = 0, 0, a.accept_tally / r.request_tally)
    ,2
    ) AS accept_rate
FROM
(SELECT COUNT(DISTINCT requester_id, accepter_id) AS accept_tally 
 FROM request_accepted) AS a,
(SELECT COUNT(DISTINCT sender_id, send_to_id) AS request_tally 
 FROM friend_request) AS r;