SELECT ROUND(MIN(SQRT(POWER(p1.x - p2.x, 2) + POWER(p1.y - p2.y, 2))), 2) AS shortest 
FROM point_2d p1, point_2d p2
WHERE p1.x != p2.x
  OR p1.y != p2.y;

SELECT
  MIN(ROUND(
  SQRT(POW(p1.x - p2.x, 2) + POW(p1.y - p2.y, 2)), 2)) AS shortest
FROM point_2d p1, point_2d p2 
WHERE NOT (p1.x = p2.x AND p1.y = p2.y);