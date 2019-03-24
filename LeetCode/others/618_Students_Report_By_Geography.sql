-- knowing america is largest,
-- all other col's id is subset of america's
-- outer join with america is good enough
-- (one left join, one out join)
SELECT 
  America, Asia, Europe
FROM
  (SELECT @as:=0, @am:=0, @eu:=0) t,
  (SELECT @as:=@as + 1 AS asid, name AS Asia
  FROM student
  WHERE continent = 'Asia'
  ORDER BY Asia) AS t1
  RIGHT JOIN
  (SELECT @am:=@am + 1 AS amid, name AS America
  FROM student
  WHERE continent = 'America'
  ORDER BY America) AS t2 
  ON asid = amid
  LEFT JOIN
  (SELECT @eu:=@eu + 1 AS euid, name AS Europe
  FROM student
  WHERE continent = 'Europe'
  ORDER BY Europe) AS t3 
  ON amid = euid;

SELECT 
  am.name AS America
  ,asia.name AS Asia
  ,eu.name AS Europe
FROM
  (SELECT
    name
    ,ROW_NUMBER() OVER (ORDER BY name) AS id
  FROM student
  WHERE continent = 'America') AS am
LEFT JOIN
  (SELECT
    name
    ,ROW_NUMBER() OVER (ORDER BY name) AS id
  FROM student
  WHERE continent = 'Asia') AS asia
ON am.id = asia.id
LEFT JOIN
  (SELECT
    name
    ,ROW_NUMBER() OVER (ORDER BY name) AS id
  FROM student
  WHERE continent = 'Europe') AS eu
ON asia.id = eu.id
  OR am.id = eu.id -- IMPORTANT! columns may not be arranged in descending order
ORDER BY America;

SELECT
  america.name AS America
  ,asia.name as Asia
  ,europe.name as Europe
FROM
  (SELECT @a := 0, @b := 0, @c := 0) AS vars
  ,(SELECT @a := @a + 1 AS ID, name FROM student WHERE continent = "America" ORDER BY name) AS america
  LEFT JOIN
  (SELECT @b := @b + 1 AS ID, name FROM student WHERE continent = "Asia" ORDER BY name) AS asia
  ON america.ID = asia.ID
  LEFT JOIN
  (SELECT @c := @c + 1 AS ID, name FROM student WHERE continent = "Europe" ORDER BY name) AS europe
  ON asia.ID = europe.ID
  OR america.ID = europe.ID;
