-- do a small example, and observe pattern
SELECT
  t1.Id,
  CASE
   WHEN COUNT(t1.p_id) = 0 THEN "Root"
   WHEN COUNT(t2.id) = 0 THEN "Leaf"
   ELSE "Inner"
  END AS Type
FROM tree t1
LEFT JOIN tree t2
ON t1.Id = t2.p_id
GROUP BY t1.Id
ORDER BY t1.Id;