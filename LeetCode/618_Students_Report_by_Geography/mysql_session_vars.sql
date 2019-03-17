-- MySQL
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