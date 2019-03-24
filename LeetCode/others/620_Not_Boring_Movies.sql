SELECT *
FROM cinema
WHERE description NOT LIKE "%boring%"
  AND id % 2 = 1
ORDER BY rating DESC;