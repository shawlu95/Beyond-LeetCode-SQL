/*
shift down
1 N
2 1
3 2

shift up
1 2
2 3
3 N

join
1 N 2
2 1 3
3 2 N

*/

SELECT 
  m.seat_id
FROM cinema AS m
LEFT JOIN cinema AS d ON m.seat_id = d.seat_id + 1
LEFT JOIN cinema AS u ON m.seat_id = u.seat_id - 1
WHERE m.free = 1
  AND (d.free = 1 OR u.free = 1)
ORDER BY seat_id;

-- if three consecutive seats are free
-- middle seat will be returned twice
SELECT DISTINCT a.seat_id AS seat_id 
FROM cinema a 
JOIN cinema b
    ON a.free = 1 
        AND b.free = 1
        AND abs(a.seat_id - b.seat_id) = 1
ORDER BY seat_id;