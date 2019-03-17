-- using self join (cross join)
SELECT
  t1.name
  ,t1.grade AS 'CS106B'
  ,t2.grade AS 'CS229'
  ,t3.grade AS 'CS224N'
FROM CourseGrade AS t1
    ,CourseGrade AS t2
    ,CourseGrade AS t3
WHERE t1.name = t2.name
  AND t2.name = t3.name
  AND t1.course = 'CS106B'
  AND t2.course = 'CS229'
  AND t3.course = 'CS224N';

-- using self join (inner join)
SELECT
  t1.name
  ,t1.grade AS 'CS106B'
  ,t2.grade AS 'CS229'
  ,t3.grade AS 'CS224N'
FROM CourseGrade AS t1
JOIN CourseGrade AS t2
  ON t1.course = 'CS106B'
 AND t2.course = 'CS229'
 AND t1.name = t2.name
JOIN CourseGrade AS t3
  ON t3.course = 'CS224N'
 AND t2.name = t3.name;


-- using case statement and aggregation
SELECT
  name
  ,MAX(CASE WHEN course = 'CS106B' THEN grade ELSE NULL END) AS 'CS106B'
  ,MAX(CASE WHEN course = 'CS229' THEN grade ELSE NULL END) AS 'CS229'
  ,MAX(CASE WHEN course = 'CS224N' THEN grade ELSE NULL END) AS 'CS224N'
FROM CourseGrade
GROUP BY name;