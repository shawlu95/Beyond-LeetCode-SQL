SELECT a.name AS America,
       b.name AS Asia,
       c.name AS Europe
FROM
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM students) r
LEFT JOIN 
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM students WHERE continent = 'Asia') b USING(ID)
LEFT JOIN 
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM students WHERE continent = 'America') a USING(ID)
LEFT JOIN 
(SELECT ROW_NUMBER() OVER (ORDER BY name) AS ID, name FROM students WHERE continent = 'Europe') c USING(ID)
WHERE NOT(a.ID IS NULL AND b.ID IS NULL AND c.ID IS NULL)