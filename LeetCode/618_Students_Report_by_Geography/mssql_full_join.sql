-- MS SQL
SELECT
  a.name AS America
  ,b.name AS Asia
  ,c.name AS Europe
FROM
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'America') a
FULL JOIN
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'Asia') b
ON a.ID = b.ID
FULL JOIN
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM student WHERE continent = 'Europe') c
ON c.ID = b.ID
OR c.ID = a.ID;