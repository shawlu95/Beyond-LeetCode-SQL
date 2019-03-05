-- MySQL solution
SELECT DISTINCT 
  s1.* 
FROM
  stadium AS s1
  ,stadium AS s2
  ,stadium AS s3
WHERE s1.people >= 100 
  AND s2.people >= 100 
  AND s3.people >= 100 
  AND ((s1.id = s2.id - 1 AND s1.id = s3.id - 2) -- start of window
    OR (s1.id = s2.id + 1 AND s1.id = s3.id - 1) -- middle of window
    OR (s1.id = s2.id + 2 AND s1.id = s3.id + 1)) -- end of window
ORDER BY s1.id; 